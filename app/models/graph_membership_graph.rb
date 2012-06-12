class GraphMembershipGraph < ActiveRecord::Base
  attr_accessible :graph_id, :subgraph_id
  belongs_to :graph
  belongs_to :subgraph, :class_name => "Graph", :foreign_key => "subgraph_id"
  
  # Validations
  validates :graph_id, :presence => true
  validates :subgraph_id, :presence => true
  validates_uniqueness_of :graph_id, scope: :subgraph_id, message: "You cannot add a #{I18n.translate('graphs.one').downcase} that has already been added."
end
