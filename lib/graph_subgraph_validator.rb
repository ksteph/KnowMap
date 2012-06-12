class GraphSubgraphValidator < ActiveModel::Validator
  def validate(record)
    record.errors.add :base, "This will cause a cycle" if Graph.find(record.subgraph_id).all_subgraphs.include? Graph.find(record.graph_id)
  end
end
