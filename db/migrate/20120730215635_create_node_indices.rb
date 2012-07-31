class CreateNodeIndices < ActiveRecord::Migration
  def change
    create_table :node_indices do |t|
      t.integer :course_id
      t.integer :node_id
      t.integer :row
      t.integer :index

      t.timestamps
    end
  end
end
