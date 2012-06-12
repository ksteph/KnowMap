class AddIndexToNodes < ActiveRecord::Migration
  def change
    add_index 'Nodes', 'id'
  end
end
