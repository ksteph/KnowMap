class CreateActions < ActiveRecord::Migration
  def change
    create_table :actions do |t|
      t.integer :user_id
      t.string :controller
      t.string :action
      t.integer :target_id

      t.timestamps
    end
  end
end
