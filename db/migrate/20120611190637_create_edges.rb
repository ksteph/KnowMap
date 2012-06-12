class CreateEdges < ActiveRecord::Migration
  def change
    create_table :edges do |t|
      t.integer :node_id_A, :null => false
      t.integer :node_id_B, :null => false
      t.integer :edgetype_id, :null => false

      t.timestamps
    end
  end
end
