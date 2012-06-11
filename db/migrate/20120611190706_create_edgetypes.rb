class CreateEdgetypes < ActiveRecord::Migration
  def change
    create_table :edgetypes do |t|
      t.string :name
      t.text :desc

      t.timestamps
    end
  end
end
