class GraphSubgraphValidator < ActiveModel::Validator
  def validate(record)
    graph = Graph.find record.graph_id
    subgraph = Graph.find record.subgraph_id
    record.errors.add :subgraph_id, "^Adding the subgraph #{subgraph.name} will cause a cycle" if subgraph.all_subgraphs.include? graph
  end
end
