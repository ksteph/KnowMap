class AddIndexToEdges < ActiveRecord::Migration
  def change
    add_index 'edges', 'node_id_A'
    add_index 'edges', 'node_id_B'
    add_index 'edges', ['node_id_A', 'node_id_B', 'type'], :unique => true
    add_index 'edges', 'type'
  end
end
