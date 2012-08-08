class AddRoleToUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.string :role, :default => User.Roles.Student
    end
  end
end
