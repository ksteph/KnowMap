class AddIndexToGraphMembershipGraph < ActiveRecord::Migration
  def change
    add_index 'graph_membership_graphs', 'graph_id'
    add_index 'graph_membership_graphs', 'subgraph_id'
    add_index 'graph_membership_graphs', ['graph_id', 'subgraph_id'], :unique => true
  end
end
