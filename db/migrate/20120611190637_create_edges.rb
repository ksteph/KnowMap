class CreateEdges < ActiveRecord::Migration
  def change
    create_table :edges do |t|
      t.integer :node_id_A
      t.integer :node_id_B
      t.integer :edgetype_id

      t.timestamps
    end
  end
end
