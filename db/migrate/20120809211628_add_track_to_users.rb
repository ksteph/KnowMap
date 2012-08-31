class AddTrackToUsers < ActiveRecord::Migration
  def change
    add_column :users, :track, :boolean, :default => true
  end
end
