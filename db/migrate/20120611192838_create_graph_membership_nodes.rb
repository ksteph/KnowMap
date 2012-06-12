class CreateGraphMembershipNodes < ActiveRecord::Migration
  def change
    create_table :graph_membership_nodes do |t|
      t.integer :graph_id, :null => false
      t.integer :node_id, :null => false

      t.timestamps
    end
  end
end
