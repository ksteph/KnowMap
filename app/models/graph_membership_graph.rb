class GraphMembershipGraph < ActiveRecord::Base
  require Rails.root.join('lib', 'graph_subgraph_validator.rb')
  
  attr_accessible :graph_id, :subgraph_id
  belongs_to :graph
  belongs_to :subgraph, :class_name => "Graph", :foreign_key => "subgraph_id"
  
  # Validations
  validates :graph_id, :presence => true
  validates :subgraph_id, :presence => true
  validates_uniqueness_of :subgraph_id, scope: :graph_id, message: "^You can't add a #{I18n.translate('graphs.one').downcase} that has already been added."
  validates_with GraphSubgraphValidator
end
