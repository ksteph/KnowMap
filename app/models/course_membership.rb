class CourseMembership < ActiveRecord::Base
  attr_accessible :course_id, :role, :user_id
  
  belongs_to :user
  belongs_to :course
  
  def self.studentRole
    1
  end
  
  def self.instructorRole
    0
  end
end
