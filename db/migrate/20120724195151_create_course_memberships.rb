class CreateCourseMemberships < ActiveRecord::Migration
  def change
    create_table :course_memberships do |t|
      t.integer :course_id
      t.integer :user_id
      t.integer :role

      t.timestamps
    end
  end
end
