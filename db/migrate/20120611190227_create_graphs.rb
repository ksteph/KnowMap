class CreateGraphs < ActiveRecord::Migration
  def change
    create_table :graphs do |t|
      t.string :name
      t.text :content

      t.timestamps
    end
  end
end
