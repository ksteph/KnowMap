class CreateGraphMembershipGraphs < ActiveRecord::Migration
  def change
    create_table :graph_membership_graphs do |t|
      t.integer :graph_id, :null => false
      t.integer :subgraph_id, :null => false

      t.timestamps
    end
  end
end
