class CreateGraphMembershipNodes < ActiveRecord::Migration
  def change
    create_table :graph_membership_nodes do |t|
      t.integer :graph_id
      t.integer :node_id

      t.timestamps
    end
  end
end
