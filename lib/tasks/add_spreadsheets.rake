namespace :csv do
  desc "Adds csv spreadsheet to database"
  task :populate, [:nodefile, :graphfile] => :environment do |t,args|
    args.with_defaults(nodefile: 'spreadsheets/concepts.csv',
                       graphfile: 'spreadsheets/groups.csv')
    puts "You gave node file: #{args.nodefile}"
    puts "You gave group file: #{args.graphfile}"

    require "csv"

    # Handle the nodes
    hshId2Node = Hash.new
    hshId2Hsh2AryNeighbors = Hash.new{|h,k|
      tmp = Hash.new
      tmp["related"] = Array.new
      tmp["prereq"] = Array.new
      tmp["next"] = Array.new
      h[k] = tmp
    }

    CSV.foreach(args.nodefile){|row|
      if row[0] =~ /^\d*$/
        id = row[0].to_i
        strRelatedN = row[2] || ""
        strPrereqN = row[3] || ""
        strNextN = row[4] || ""

        n = Node.find_by_title(row[1])
        if n == nil
          n = Node.create({ title: row[1], content: row[5]})
        end
        hshId2Node[id] = n
        strRelatedN.split(',').each{|s|
          hshId2Hsh2AryNeighbors[id]["related"].push s.to_i
        }
        strPrereqN.split(',').each{|s|
          hshId2Hsh2AryNeighbors[id]["prereq"].push s.to_i
        }
        strNextN.split(',').each{|s|
          hshId2Hsh2AryNeighbors[id]["next"].push s.to_i
        }
      end
    }

    hshId2Hsh2AryNeighbors.each{|id,hsh2AryNeighbors|
      nodeId = hshId2Node[id].id
      hsh2AryNeighbors["related"].each{|id2|
        id1 = id
        nodeId1 = nodeId
        nodeId2 = hshId2Node[id2].id

        # Enforcing convention of node A has the lower id number
        if nodeId1 > nodeId2
          tmp = nodeId1
          nodeId1 = nodeId2
          nodeId2 = tmp
        end

        # Double check for both possibilities regardless though.
        ary1to2 = RelatedEdge.find_by_sql("select * from edges"+
                                   " where \"node_id_A\"=#{nodeId1}"+
                                   " and \"node_id_B\"=#{nodeId2}")
        ary2to1 = RelatedEdge.find_by_sql("select * from edges"+
                                   " where \"node_id_A\"=#{nodeId2}"+
                                   " and \"node_id_B\"=#{nodeId1}")

        # If the edge doesn't exist add
        if (ary1to2.size == 0) && (ary2to1.size == 0)
          RelatedEdge.create({node_id_A: nodeId1, node_id_B: nodeId2})
        end
      }

      hsh2AryNeighbors["prereq"].each{|id2|
        id1 = id
        nodeId1 = nodeId
        nodeId2 = hshId2Node[id2].id
        aryEdgeDep = DependentEdge.find_by_sql("select * from edges"+
                                   " where \"node_id_A\"=#{nodeId2}"+
                                   " and \"node_id_B\"=#{nodeId1}")

        # If the edge doesn't exist add
        if (aryEdgeDep.size == 0)
          DependentEdge.create({node_id_A: nodeId2, node_id_B: nodeId1})
        end
      }

      # I know it's repetative, but I don't care right now.
      hsh2AryNeighbors["next"].each{|id2|
        id1 = id
        nodeId1 = nodeId
        nodeId2 = hshId2Node[id2].id
        aryEdgeDep = DependentEdge.find_by_sql("select * from edges"+
                                   " where \"node_id_A\"=#{nodeId1}"+
                                   " and \"node_id_B\"=#{nodeId2}")

        # If the edge doesn't exist add
        if (aryEdgeDep.size == 0)
          DependentEdge.create({node_id_A: nodeId1, node_id_B: nodeId2})
        end
      }
    }


    # Handle the graphs
    hshId2Graph = Hash.new
    hshId2Hsh2AryMembers = Hash.new{|h,k|
      tmp = Hash.new
      tmp["graph"] = Array.new
      tmp["node"] = Array.new
      h[k] = tmp
    }

    CSV.foreach(args.graphfile){|row|
      if row[0] =~ /^\d*$/
        id = row[0].to_i
        title = row[1]
        strGraphIds = row[2] || ""
        strNodeIds = row[3] || ""
        content = row[4]

        g = Graph.find_by_name(title)
        if g == nil
          g = Graph.create({name: title, content: content})
        end

        hshId2Graph[id] = g

        strGraphIds.split(',').each{|s|
          hshId2Hsh2AryMembers[id]["graph"].push s.to_i
        }
        strNodeIds.split(',').each{|s|
          hshId2Hsh2AryMembers[id]["node"].push s.to_i
        }
      end
    }

    hshId2Hsh2AryMembers.each{|id,hsh2AryMembers|
      graphId1 = hshId2Graph[id].id
      hsh2AryMembers["graph"].each{|id2|
        graphId2 = hshId2Graph[id2].id
        arySubgraph = GraphMembershipGraph
          .find_by_sql("select * from graph_membership_graphs"+
                       " where graph_id=#{graphId1}"+
                       " and subgraph_id=#{graphId2}")

        if arySubgraph.size == 0
          GraphMembershipGraph.create({graph_id: graphId1,
                                        subgraph_id: graphId2})
        end
      }

      hsh2AryMembers["node"].each{|id2|
        if hshId2Node.include?(id2)
          nodeId = hshId2Node[id2].id
          aryNode = GraphMembershipNode
            .find_by_sql("select * from graph_membership_nodes"+
                         " where graph_id=#{graphId1}"+
                         " and node_id=#{nodeId}")
          
          if aryNode.size == 0
            GraphMembershipNode.create({graph_id: graphId1,
                                         node_id: nodeId})
          end
        end
      }

    }
    puts "Total nodes added: #{hshId2Node.size}"
  end
end

