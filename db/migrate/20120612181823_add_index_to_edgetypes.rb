class AddIndexToEdgetypes < ActiveRecord::Migration
  def change
    add_index 'Edgetypes', 'id'
  end
end
