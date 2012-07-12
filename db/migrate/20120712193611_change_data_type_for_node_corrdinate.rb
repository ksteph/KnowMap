class ChangeDataTypeForNodeCorrdinate < ActiveRecord::Migration
  def up
    change_table :nodes do |t|
      t.change :pos_x, :float
      t.change :pos_y, :float
    end
  end

  def down
    change_table :nodes do |t|
      t.change :pos_x, :integer
      t.change :pos_y, :integer
    end
  end
end
