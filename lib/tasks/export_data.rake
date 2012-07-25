namespace :csv do
  desc "Exports data from database to csv spreadsheet"
  task :export, [:nodefile, :graphfile] => :environment do |t,args|
    args.with_defaults(nodefile: "spreadsheets/export/concepts_#{Time.now.strftime("%Y-%m-%d-%H%M%S")}.csv",
                       graphfile: "spreadsheets/export/groups_#{Time.now.strftime("%Y-%m-%d-%H%M%S")}.csv",
                       coorfile: "spreadsheets/export/coordinates_#{Time.now.strftime("%Y-%m-%d-%H%M%S")}.csv")
    puts "Exporting nodes to: #{args.nodefile}"
    puts "Exporting graphs to: #{args.graphfile}"
    puts "Exporting coordinates to: #{args.coorfile}"

    graphfile = File.open args.graphfile, 'w'
    graphfile.write "Node Id,Node Title,Group Ids,Concept Ids,Content\n"
    Graph.all.each do |graph|
      group_ids = concept_ids = ""
      graph.subgraphs.each { |s| group_ids += group_ids == "" ? "#{s.id}" : ",#{s.id}" }
      graph.nodes.each { |c| concept_ids += concept_ids == "" ? "#{c.id}" : ",#{c.id}" }
      
      graphfile.write "#{graph.id},\"#{graph.name.gsub('"','""')}\",\"#{group_ids}\",\"#{concept_ids}\""
      graphfile.write ",\"#{graph.content.gsub('"','""')}\"" if graph.content
      graphfile.write "\n"
    end
    
    nodefile = File.open args.nodefile, 'w'
    nodefile.write "Node Id,Node Title,Group Ids,Concept Ids,Content\n"
    coorfile = File.open args.coorfile, 'w'
    coorfile.write "Node Title,Pos_X,Pos_Y\n"
    Node.all.each do |node|
      related_nodes = previous_nodes = next_nodes = ""
      node.related_nodes.each{|n| related_nodes += related_nodes == "" ? "#{n.id}" : ",#{n.id}"}
      node.previous_nodes.each{|n| previous_nodes += previous_nodes == "" ? "#{n.id}" : ",#{n.id}"}
      node.next_nodes.each{|n| next_nodes += next_nodes == "" ? "#{n.id}" : ",#{n.id}"}
      
      nodefile.write "#{node.id},\"#{node.title.gsub('"','""')}\",\"#{related_nodes}\",\"#{previous_nodes}\",\"#{next_nodes}\""
      nodefile.write ",\"#{node.content.gsub('"','""')}\"" if node.content
      nodefile.write "\n"
      
      coorfile.write "\"#{node.title.gsub('"','""')}\",#{node.pos_x},#{node.pos_y}\n"
    end
  end
end

