class Edge < ActiveRecord::Base
  attr_accessible :node_id_A, :node_id_B, :edgetype_id
  belongs_to :node_A, :class_name => "Node", :foreign_key => "node_id_A"
  belongs_to :node_B, :class_name => "Node", :foreign_key => "node_id_B"
  belongs_to :edgetype
  
  # Validations
  validates :node_id_A, :presence => true
  validates :node_id_B, :presence => true
  validates :edgetype_id, :presence => true
  validates_uniqueness_of :node_id_A, scope: :node_id_B, message: "You cannot add a #{I18n.translate('nodes.one').downcase} that has already been added."
end
