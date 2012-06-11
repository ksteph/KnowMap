#!/usr/bin/ruby

require "csv"

if (ARGV.size != 3) || (ARGV[0] =~ /help/i)
  print " Usage: #{$0} <concepts csv file> <groups csv file> <output header>"
  puts ""
  puts ""
  puts " This script will take the CSV files of the from the Google"
  puts " spreadsheet: CS161 Knowledge Map Data and create a graph using"
  puts " graphiz. After creating a sample graph and the large map of everything"
  puts " it will create the groups."
  puts " "
  puts " In graphviz groups cannot overlap so groups will be self contained "
  puts " and nodes will repeat when necessary."
  puts ""
  puts "   Expected format of <concepts csv file>:"
  puts "     <node id> <node title> <csv: related nodes> <csv: prereq nodes> <csv: next nodes> <content>"
  puts ""
  puts "   Expected format of <groups csv file>:"
  puts "     <group id> <group title> <csv: group ids> <csv: concept ids> <content>"
  puts ""
  puts "   Output:"
  puts "     <output header>.map - graphiz input text file"
  puts "     <output header>.pdf - graphiz output map"
  exit
end

conceptFilename = ARGV[0]
groupFilename = ARGV[1]
outHeader = ARGV[2]

NodeInfo = Struct.new(:id, :title, :content, :nodeStr)
GroupInfo = Struct.new(:id, :title, :content)
RelatedEdge = Struct.new(:id1, :id2)

EDGE_TYPE_RELATED = 0
EDGE_TYPE_PREREQ = 1
EDGE_TYPE_NEXT = 2

GROUP_TYPE_GROUP = 0
GROUP_TYPE_NODE = 1

@hshNode = Hash.new
@hshGroup = Hash.new
@aryRelatedEdge = Array.new
@hshRelatedEdge = Hash.new{|h,k| h[k] = Array.new}
@hshNextId2AryId = Hash.new{|h,k| h[k] = Array.new}
@hshGId2Hsh2AryId = Hash.new{|h,k| h[k] = Array.new}
aryGroupWParent = Array.new

def str2Ary(str)
  ary = Array.new
  str.split(',').each{|s|
    ary.push s.to_i
  }
  return ary
end

puts "Processing concepts csv file: #{conceptFilename}"
CSV.foreach(conceptFilename){|row|
  if row[0] =~ /^\d*$/
    i = -1
    id = (row[i+=1]).to_i
    title = row[i+=1]
    strRelatedN = row[i+=1] || ""
    strPrereqN = row[i+=1] || ""
    strNextN = row[i+=1] || ""
    content = row[i+=1]

    if @hshNode.has_key?(id)
      puts "WARNING: node id already exists #{id}"
      print "row: "
      row.each{|e| print "#{e},"}
      puts ""
    else
      @hshNode[id] = NodeInfo.new(id, title, content, "node#{id}")
#      hshNId2HshEdge2AryNId[id][EDGE_TYPE_RELATED] = str2Ary(strRelatedN)
      str2Ary(strRelatedN).each{|id2|
        if !@hshRelatedEdge[id].include?(id2)
          @hshRelatedEdge[id].push id2
        end
        if !@hshRelatedEdge[id2].include?(id)
          @hshRelatedEdge[id2].push id
        end

        rEdge = nil
        if (id < id2) 
          rEdge = RelatedEdge.new(id, id2)
        else
          rEdge = RelatedEdge.new(id2, id)
        end

        if !@aryRelatedEdge.include?(rEdge)
          @aryRelatedEdge.push rEdge
        end
      }

#      hshNId2HshEdge2AryNId[id][EDGE_TYPE_PREREQ] = str2Ary(strPrereqN)
      str2Ary(strPrereqN).each{|id2|
        if !@hshNextId2AryId[id2].include?(id)
          @hshNextId2AryId[id2].push id
        end
      }

#      hshNId2HshEdge2AryNId[id][EDGE_TYPE_NEXT] = str2Ary(strNextN)
      str2Ary(strNextN).each{|id2|
        if !@hshNextId2AryId[id].include?(id2)
          @hshNextId2AryId[id].push id2
        end
      }
    end
  end
}
puts "  Total nodes: #{@hshNode.size}"
puts "  Total related edges: #{@aryRelatedEdge.size}"
cDirEdge = 0
@hshNextId2AryId.each{|id,ary| cDirEdge += ary.size}
puts "  Total directed edges: #{cDirEdge}"

puts "Processing groups csv file: #{groupFilename}"
CSV.foreach(groupFilename){|row|
  if row[0] =~ /^\d*$/
    i = -1
    id = (row[i+=1]).to_i
    title = row[i+=1]
    strGroupId = row[i+=1] || ""
    strNodeId = row[i+=1] || ""
    content = row[i+=1]

    if @hshGroup.has_key?(id)
      puts "WARNING: group id already exists #{id}"
      print "row: "
      row.each{|e| print "#{e},"}
      puts ""
    else
      @hshGroup[id] = GroupInfo.new(id, title, content)
      aryGroups = str2Ary(strGroupId)
      @hshGId2Hsh2AryId[id][GROUP_TYPE_GROUP] = aryGroups
      aryGroupWParent = aryGroupWParent | aryGroups
      @hshGId2Hsh2AryId[id][GROUP_TYPE_NODE] = str2Ary(strNodeId)
    end
  end
}
puts "    Total groups: #{@hshGroup.size}"

puts "Creating graph"

#def printSubGraph(output, @hshNode, @hshGroup, @hshGId2Hsh2AryId, gId, tag)
strSampleFormat = "color=grey"
@strRelateEdgeFormat = "dir=\"none\", style=\"dashed\""
@strNextEdgeFormat = ""

def printSubGraph(output, gId, tag)
  group = @hshGroup[gId]
  aryNode = @hshGId2Hsh2AryId[gId][GROUP_TYPE_NODE]
  aryGroup = @hshGId2Hsh2AryId[gId][GROUP_TYPE_GROUP]
  tag = "#{tag}_#{gId}"
  output.puts "subgraph cluster_#{tag} {"
  output.puts "  label=\"#{gId}-#{group.title}\""
  aryNode.each{|id1|
    node1 = @hshNode[id1]
    output.puts "  #{node1.nodeStr}_#{tag} [label=\"#{id1}-#{node1.title}\"]"
    @hshRelatedEdge[node1.id].each{|id2|
      if aryNode.include?(id2) && (id2 < id1)
        node2 = @hshNode[id2]
        output.puts "  #{node1.nodeStr}_#{tag} -> #{node2.nodeStr}_#{tag} [#{@strRelateEdgeFormat}]"
      end
    }
  }
  aryNode.each{|nId|
    node1 = @hshNode[nId]
    @hshNextId2AryId[nId].each{|nId2|
      if aryNode.include?(nId2)
        node2 = @hshNode[nId2]
        output.puts "  #{node1.nodeStr}_#{tag} -> #{node2.nodeStr}_#{tag} [#{@strNextEdgeFormat}]"
      end
    }
  }
  aryGroup.each{|gId2|
    printSubGraph(output, gId2, tag)
  }
  output.puts "}"
end

outMap = File.new("#{outHeader}.map", "w+")

outMap.puts "digraph g {"
outMap.puts "  relateA [label=\"A\", group=\"sample\", #{strSampleFormat}]"
outMap.puts "  relateB [label=\"B\", group=\"sample\", #{strSampleFormat}]"
outMap.puts "  prereq [label=\"Prereq\", group=\"sample\", #{strSampleFormat}]"
outMap.puts "  nodeN [label=\"Node\", group=\"sample\", #{strSampleFormat}]"
outMap.puts "  next [label=\"Next\", group=\"sample\", #{strSampleFormat}]"

outMap.puts "  subgraph cluster_sample {"
outMap.puts "    subgraph cluster_relate {"
outMap.puts "      label = \"SubGraph: Related Nodes\""
outMap.puts "      relateA"
outMap.puts "      relateB"
outMap.puts "    }"
outMap.puts "    subgraph cluster_sgO {"
outMap.puts "      label = \"SubGraph: Outer\""
outMap.puts "      prereq"
outMap.puts "      nodeN"
outMap.puts "      subgraph cluster_sgI {"
outMap.puts "        label = \"SubGraph: Inner\""
outMap.puts "        next"
outMap.puts "      }"
outMap.puts "    }"
outMap.puts "  }"

outMap.puts "  relateA -> relateB [#{@strRelateEdgeFormat}, #{strSampleFormat}]"
outMap.puts "  prereq -> nodeN [#{@strNextEdgeFormat}"+
  "#{if @strNextEdgeFormat == "" then '' else ',' end} "+
  "#{strSampleFormat}]"
outMap.puts "  nodeN -> next [#{@strNextEdgeFormat}"+
  "#{if @strNextEdgeFormat == "" then "" else "," end} "+
  "#{strSampleFormat}]"
@hshNode.each{|id, node|
  outMap.puts "  #{node.nodeStr} [label=\"#{node.title}\"]"
}

@aryRelatedEdge.each{|rEdge|
  node1 = @hshNode[rEdge.id1]
  node2 = @hshNode[rEdge.id2]
  outMap.puts "  #{node1.nodeStr} -> #{node2.nodeStr} [#{@strRelateEdgeFormat}]"
}

@hshNextId2AryId.each{|id1,ary|
  node1 = @hshNode[id1]
  ary.each{|id2|
    node2 = @hshNode[id2]
    outMap.puts "  #{node1.nodeStr} -> #{node2.nodeStr} [#{@strNextEdgeFormat}]"
  }
}

outMap.puts "}"

outMap.close

outMap = File.new("#{outHeader}.group.map", "w+")

outMap.puts "digraph g {"
outMap.puts "  rankdir=\"LR\""
@hshGroup.each{|gId, group|
  if !aryGroupWParent.include?(gId)
    printSubGraph(outMap, gId, "")
  end
}
#printSubGraph(outMap, 5, "")
#printSubGraph(outMap, 13, "")
outMap.puts "}"
outMap.close

graphizOutput = `dot -Tpdf #{outHeader}.map -o #{outHeader}.pdf`
puts "Graphiz node output: #{graphizOutput}"
graphizOutput = `dot -Tpdf #{outHeader}.group.map -o #{outHeader}.group.pdf`
puts "Graphiz group output: #{graphizOutput}"

puts "DONE"
