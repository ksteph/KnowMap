class AddCoordinatesToNodes < ActiveRecord::Migration
  def change
    change_table :nodes do |t|
      t.integer :pos_x, :default => 0
      t.integer :pos_y, :default => 0
    end
  end
end
