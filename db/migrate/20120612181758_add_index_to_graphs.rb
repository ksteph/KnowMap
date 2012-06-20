class AddIndexToGraphs < ActiveRecord::Migration
  def change
    add_index 'graphs', 'id'
  end
end
