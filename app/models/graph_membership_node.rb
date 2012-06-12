class GraphMembershipNode < ActiveRecord::Base
  attr_accessible :graph_id, :node_id
  belongs_to :graph
  belongs_to :node
  
  # Validations
  validates :graph_id, :presence => true
  validates :node_id, :presence => true
  validates_uniqueness_of :graph_id, scope: :node_id, message: "You cannot add a #{I18n.translate('nodes.one').downcase} that has already been added."
end
