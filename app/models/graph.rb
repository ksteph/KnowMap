class Graph < ActiveRecord::Base  
  attr_accessible :name, :content, :graph_membership_graphs_attributes, :graph_membership_nodes_attributes
  has_many :subgraphs, :through => :graph_membership_graphs, :class_name => 'Graph', :source => 'subgraph'
  has_many :nodes, :through => :graph_membership_nodes
  has_many :graph_membership_graphs
  has_many :graph_membership_nodes
  has_one :course
  has_many :all_subgraphs, :class_name => "Graph", :finder_sql => proc { "WITH RECURSIVE subgraphs AS ( SELECT subgraph_id FROM graph_membership_graphs WHERE graph_id = #{id} UNION ALL SELECT g.subgraph_id FROM graph_membership_graphs g, subgraphs sg WHERE g.graph_id = sg.subgraph_id) SELECT DISTINCT g.* FROM subgraphs sg JOIN graphs g on g.id = sg.subgraph_id;" }
  has_many :all_nodes, :class_name => "Node", :finder_sql => proc { "WITH RECURSIVE subgraphs AS ( SELECT subgraph_id FROM graph_membership_graphs WHERE graph_id = #{id} UNION ALL SELECT g.subgraph_id FROM graph_membership_graphs g, subgraphs sg WHERE g.graph_id = sg.subgraph_id) SELECT * FROM nodes WHERE nodes.id IN (SELECT DISTINCT m.node_id FROM graph_membership_nodes m, subgraphs sg WHERE m.graph_id = sg.subgraph_id UNION ALL SELECT DISTINCT m.node_id FROM graph_membership_nodes m WHERE m.graph_id = #{id})" }
  
  accepts_nested_attributes_for :graph_membership_graphs, :reject_if => lambda { |a| a[:subgraph_id].blank? }, :allow_destroy => true
  accepts_nested_attributes_for :graph_membership_nodes, :reject_if => lambda { |a| a[:node_id].blank? }, :allow_destroy => true
  
  # Validations
  validates :name, :presence => true, :uniqueness => true
  
  def all_subgraphs_naive
    return [] if subgraphs.nil?
    result = subgraphs
    subgraphs.each { |g| result |= g.all_subgraphs }
    result
  end
  
  def all_nodes_naive
    return [] if subgraphs.nil?
    result = nodes
    subgraphs.each { |g| result |= g.all_nodes }
    result
  end
  
  def to_s
    name
  end
end
