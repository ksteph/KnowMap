class CreateEdges < ActiveRecord::Migration
  def change
    create_table :edges do |t|
      t.integer :node_id_A, :null => false
      t.integer :node_id_B, :null => false
      t.string :type, :null => false

      t.timestamps
    end
  end
end
