class GraphMembershipNode < ActiveRecord::Base
  attr_accessible :graph_id, :node_id
  belongs_to :node
  belongs_to :graph
end
