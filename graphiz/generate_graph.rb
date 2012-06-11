#!/usr/bin/ruby

require "csv"

if (ARGV.size != 3) || (ARGV[0] =~ /help/i)
  print " Usage: #{$0} <concepts csv file> <groups csv file> <output header>"
  puts ""
  puts ""
  puts " This script will take the CSV files of the from the Google"
  puts " spreadsheet: CS161 Knowledge Map Data and create a graph using"
  puts " graphiz."
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

hshNode = Hash.new
hshGroup = Hash.new
#hshNId2HshEdge2AryNId = Hash.new{|h,k| h[k] = Hash.new}
aryRelatedEdge = Array.new
hshNextId2AryId = Hash.new{|h,k| h[k] = Array.new}
hshGId2Hsh2AryId = Hash.new{|h,k| h[k] = Array.new}

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

    if hshNode.has_key?(id)
      puts "WARNING: node id already exists #{id}"
      print "row: "
      row.each{|e| print "#{e},"}
      puts ""
    else
      hshNode[id] = NodeInfo.new(id, title, content, "node#{id}")
#      hshNId2HshEdge2AryNId[id][EDGE_TYPE_RELATED] = str2Ary(strRelatedN)
      str2Ary(strRelatedN).each{|id2|
        rEdge = nil
        if (id < id2) 
          rEdge = RelatedEdge.new(id, id2)
        else
          rEdge = RelatedEdge.new(id2, id)
        end

        if !aryRelatedEdge.include?(rEdge)
          aryRelatedEdge.push rEdge
        end
      }

#      hshNId2HshEdge2AryNId[id][EDGE_TYPE_PREREQ] = str2Ary(strPrereqN)
      str2Ary(strPrereqN).each{|id2|
        if !hshNextId2AryId[id2].include?(id)
          hshNextId2AryId[id2].push id
        end
      }

#      hshNId2HshEdge2AryNId[id][EDGE_TYPE_NEXT] = str2Ary(strNextN)
      str2Ary(strNextN).each{|id2|
        if !hshNextId2AryId[id].include?(id2)
          hshNextId2AryId[id].push id2
        end
      }
    end
  end
}
puts "  Total nodes: #{hshNode.size}"
puts "  Total related edges: #{aryRelatedEdge.size}"
cDirEdge = 0
hshNextId2AryId.each{|id,ary| cDirEdge += ary.size}
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

    if hshGroup.has_key?(id)
      puts "WARNING: group id already exists #{id}"
      print "row: "
      row.each{|e| print "#{e},"}
      puts ""
    else
      hshGroup[id] = GroupInfo.new(id, title, content)
      hshGId2Hsh2AryId[id][GROUP_TYPE_GROUP] = str2Ary(strGroupId)
      hshGId2Hsh2AryId[id][GROUP_TYPE_NODE] = str2Ary(strNodeId)
    end
  end
}
puts "    Total groups: #{hshGroup.size}"

puts "Creating graph"
outMap = File.new("#{outHeader}.map", "w+")

strSampleFormat = "color=\"grey\""
strRelateEdgeFormat = "dir=\"none\", style=\"dashed\""
strNextEdgeFormat = ""

outMap.puts "digraph g {"
outMap.puts "  relateA [label=\"A (related to B)\", #{strSampleFormat}]"
outMap.puts "  relateB [label=\"B (related to A)\", #{strSampleFormat}]"
outMap.puts "  prereq [label=\"Prereq\", #{strSampleFormat}]"
outMap.puts "  nodeN [label=\"Node\", #{strSampleFormat}]"
outMap.puts "  next [label=\"Next\", #{strSampleFormat}]"
outMap.puts "  relateA -> relateB [#{strRelateEdgeFormat}, #{strSampleFormat}]"
outMap.puts "  prereq -> nodeN [#{strNextEdgeFormat}"+
  "#{if strNextEdgeFormat == "" then '' else ',' end} "+
  "#{strSampleFormat}]"
outMap.puts "  nodeN -> next [#{strNextEdgeFormat}"+
  "#{if strNextEdgeFormat == "" then "" else "," end} "+
  "#{strSampleFormat}]"
hshNode.each{|id, node|
  outMap.puts "  #{node.nodeStr} [label=\"#{node.title}\"]"
}

aryRelatedEdge.each{|rEdge|
  node1 = hshNode[rEdge.id1]
  node2 = hshNode[rEdge.id2]
  outMap.puts "  #{node1.nodeStr} -> #{node2.nodeStr} #{strRelateEdgeFormat}"
}

hshNextId2AryId.each{|id1,ary|
  node1 = hshNode[id1]
  ary.each{|id2|
    node2 = hshNode[id2]
    outMap.puts "  #{node1.nodeStr} -> #{node2.nodeStr} #{strNextEdgeFormat}"
  }
}

outMap.puts "}"

outMap.close

graphizOutput = `dot -Tpdf #{outHeader}.map -o #{outHeader}.pdf`
puts "Graphiz output: #{graphizOutput}"

puts "DONE"
