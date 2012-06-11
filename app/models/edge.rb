class Edge < ActiveRecord::Base
  attr_accessible :edgetype_id, :node_id_A, :node_id_B
  belongs_to :edgetype
  belongs_to :node_A, :class_name => "Node", :foreign_key => "node_id_A"
  belongs_to :node_B, :class_name => "Node", :foreign_key => "node_id_B"
end
