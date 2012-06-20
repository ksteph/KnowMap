class AddIndexToNodes < ActiveRecord::Migration
  def change
    add_index 'nodes', 'id'
  end
end
