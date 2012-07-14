class Graph < ActiveRecord::Base  
  attr_accessible :name, :content, :graph_membership_graphs_attributes, :graph_membership_nodes_attributes
  has_many :subgraphs, :through => :graph_membership_graphs, :class_name => 'Graph', :source => 'subgraph'
  has_many :nodes, :through => :graph_membership_nodes
  has_many :graph_membership_graphs
  has_many :graph_membership_nodes
  
  accepts_nested_attributes_for :graph_membership_graphs, :reject_if => lambda { |a| a[:subgraph_id].blank? }, :allow_destroy => true
  accepts_nested_attributes_for :graph_membership_nodes, :reject_if => lambda { |a| a[:node_id].blank? }, :allow_destroy => true
  
  # Validations
  validates :name, :presence => true, :uniqueness => true
  
  def all_subgraphs
    return [] if subgraphs.nil?
    result = subgraphs
    subgraphs.each { |g| result |= g.all_subgraphs }
    result
  end
  
  def all_nodes
    return [] if subgraphs.nil?
    result = nodes
    subgraphs.each { |g| result |= g.all_nodes }
    result
  end
  
  def to_s
    name
  end
end
