class AddIndexToGraphMembershipNode < ActiveRecord::Migration
  def change
    add_index 'graph_membership_nodes', 'graph_id'
    add_index 'graph_membership_nodes', 'node_id'
    add_index 'graph_membership_nodes', ['graph_id', 'node_id'], :unique => true
  end
end
