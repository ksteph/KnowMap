class Node < ActiveRecord::Base
  attr_accessible :title, :content, :pos_x, :pos_y, :incoming_edges_attributes, :outgoing_edges_attributes, :related_edges_A_attributes, :related_edges_B_attributes
  has_many :graphs, :through => :graph_membership_nodes
  has_many :graph_membership_nodes
  
  has_many :incoming_edges, :class_name => "DependentEdge", :foreign_key => "node_id_B"
  has_many :outgoing_edges, :class_name => "DependentEdge", :foreign_key => "node_id_A"
  has_many :related_edges_A,  :class_name => "RelatedEdge", :foreign_key => "node_id_B"
  has_many :related_edges_B,  :class_name => "RelatedEdge", :foreign_key => "node_id_A"
  
  has_many :previous_nodes, :through => :incoming_edges, :class_name => "Node", :source => "node_A"
  has_many :next_nodes, :through => :outgoing_edges, :class_name => "Node", :source => "node_B"
  has_many :related_nodes_A, :through => :related_edges_A, :class_name => "Node", :source => "node_A"
  has_many :related_nodes_B, :through => :related_edges_B, :class_name => "Node", :source => "node_B"

  # for Questions
  has_many :questions
  has_many :question_submissions
  
  accepts_nested_attributes_for :incoming_edges, :reject_if => lambda { |a| a[:node_id_A].blank? }, :allow_destroy => true
  accepts_nested_attributes_for :outgoing_edges, :reject_if => lambda { |a| a[:node_id_B].blank? }, :allow_destroy => true
  accepts_nested_attributes_for :related_edges_A, :reject_if => lambda { |a| a[:node_id_A].blank? }, :allow_destroy => true
  accepts_nested_attributes_for :related_edges_B, :reject_if => lambda { |a| a[:node_id_B].blank? }, :allow_destroy => true
  
  # Validations
  validates :title, :presence => true, :uniqueness => true
  
  has_paper_trail
  
  def related_nodes
    related_nodes_A | related_nodes_B
  end
  
  def learning_path
    path = [self.id]
    previous_nodes.each { |node| node.learning_path.each { |id| path.push id unless path.include? id } }
    path.push path.shift
  end
  
  def to_s
    title
  end
end
