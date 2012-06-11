class Node < ActiveRecord::Base
  attr_accessible :content, :title, :incoming_edges_attributes, :outgoing_edges_attributes
  has_many :graph_membership_nodes
  has_many :graphs, :through => :graph_membership_nodes
  
  has_many :incoming_edges, :class_name => "Edge", :foreign_key => "node_id_B"
  has_many :outgoing_edges, :class_name => "Edge", :foreign_key => "node_id_A"
  
  #has_many :parent_nodes, :through => :incoming_edges, :class_name => "Node", :source => "node_A"
  #has_many :child_nodes, :through => :outgoing_edges, :class_name => "Node", :source => "node_B"
  
  
  accepts_nested_attributes_for :incoming_edges, :reject_if => lambda { |a| a[:edge_id].blank? }, :allow_destroy => true
  
  def previous_nodes
    Edge.where(:edgetype_id => Edgetype.find_by_name('dependent'), :node_id_B => self).all.map! { |e| e.node_A }
  end
  def next_nodes
    Edge.where(:edgetype_id => Edgetype.find_by_name('dependent'), :node_id_A => self).all.map! { |e| e.node_B }
  end
  def related_nodes
    Edge.where(:edgetype_id => Edgetype.find_by_name('related'), :node_id_A => self).all.map! { |e| e.node_B } | Edge.where(:edgetype_id => Edgetype.find_by_name('related'), :node_id_B => self).all.map! { |e| e.node_A }
  end
end
