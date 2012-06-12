class AddIndexToEdges < ActiveRecord::Migration
  def change
    add_index 'Edges', 'node_id_A'
    add_index 'Edges', 'node_id_B'
    add_index 'Edges', ['node_id_A', 'node_id_B', 'type'], :unique => true
    add_index 'Edges', 'type'
  end
end
