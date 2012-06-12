class Node < ActiveRecord::Base
  attr_accessible :title, :content, :incoming_edges_attributes, :outgoing_edges_attributes, :related_edges_A_attributes, :related_edges_B_attributes
  has_many :graphs, :through => :graph_membership_nodes
  has_many :graph_membership_nodes
  
  has_many :incoming_edges, :class_name => "Edge", :conditions => { :edgetype_id => Edgetype.find_by_name('dependent') }, :foreign_key => "node_id_B"
  has_many :outgoing_edges, :class_name => "Edge", :conditions => { :edgetype_id => Edgetype.find_by_name('dependent') }, :foreign_key => "node_id_A"
  has_many :related_edges_A,  :class_name => "Edge", :conditions => { :edgetype_id => Edgetype.find_by_name('related') }, :foreign_key => "node_id_B"
  has_many :related_edges_B,  :class_name => "Edge", :conditions => { :edgetype_id => Edgetype.find_by_name('related') }, :foreign_key => "node_id_A"
  
  has_many :previous_nodes, :through => :incoming_edges, :class_name => "Node", :source => "node_A"
  has_many :next_nodes, :through => :outgoing_edges, :class_name => "Node", :source => "node_B"
  #has_many :related_nodes_A, :through => :related_edges_A, :class_name => "Node", :source => "node_B"
  #has_many :related_nodes_A, :through => :related_edges_B, :class_name => "Node", :source => "node_A"
  
  accepts_nested_attributes_for :incoming_edges, :reject_if => lambda { |a| a[:node_id_A].blank? }, :allow_destroy => true
  accepts_nested_attributes_for :outgoing_edges, :reject_if => lambda { |a| a[:node_id_B].blank? }, :allow_destroy => true
  accepts_nested_attributes_for :related_edges_A, :reject_if => lambda { |a| a[:node_id_A].blank? }, :allow_destroy => true
  accepts_nested_attributes_for :related_edges_B, :reject_if => lambda { |a| a[:node_id_B].blank? }, :allow_destroy => true
  
  #def previous_nodes
  #  Edge.where(:edgetype_id => Edgetype.find_by_name('dependent'), :node_id_B => self).all.map! { |e| e.node_A }
  #end
  #def next_nodes
  #  Edge.where(:edgetype_id => Edgetype.find_by_name('dependent'), :node_id_A => self).all.map! { |e| e.node_B }
  #end
  def related_nodes
    #Edge.where(:edgetype_id => Edgetype.find_by_name('related'), :node_id_A => self).all.map! { |e| e.node_B } | Edge.where(:edgetype_id => Edgetype.find_by_name('related'), :node_id_B => self).all.map! { |e| e.node_A }
    related_edges_A.map! { |e| e.node_A } | related_edges_B.map! { |e| e.node_B }
  end
end
