class CreateGraphMembershipGraphs < ActiveRecord::Migration
  def change
    create_table :graph_membership_graphs do |t|
      t.integer :graph_id
      t.integer :subgraph_id

      t.timestamps
    end
  end
end
