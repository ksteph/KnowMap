class AddIndexToGraphMembershipNode < ActiveRecord::Migration
  def change
    add_index 'Graph_Membership_Nodes', 'graph_id'
    add_index 'Graph_Membership_Nodes', 'node_id'
    add_index 'Graph_Membership_Nodes', ['graph_id', 'node_id'], :unique => true
  end
end
