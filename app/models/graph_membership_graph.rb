class GraphMembershipGraph < ActiveRecord::Base
  attr_accessible :graph_id, :subgraph_id
  belongs_to :graph
  belongs_to :subgraph, :class_name => "Graph", :foreign_key => "subgraph_id"
end
