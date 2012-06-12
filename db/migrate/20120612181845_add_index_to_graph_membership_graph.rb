class AddIndexToGraphMembershipGraph < ActiveRecord::Migration
  def change
    add_index 'Graph_Membership_Graphs', 'graph_id'
    add_index 'Graph_Membership_Graphs', 'subgraph_id'
    add_index 'Graph_Membership_Graphs', ['graph_id', 'subgraph_id'], :unique => true
  end
end
