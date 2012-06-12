class AddIndexToGraphs < ActiveRecord::Migration
  def change
    add_index 'Graphs', 'id'
  end
end
