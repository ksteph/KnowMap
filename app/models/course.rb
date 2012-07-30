class Course < ActiveRecord::Base
  attr_accessible :description, :graph_id, :name, :course_memberships_attributes, :instructor_memberships_attributes, :student_memberships_attributes
  
  belongs_to :graph
  
  has_many :course_memberships
  has_many :users, :through => :course_memberships
  accepts_nested_attributes_for :course_memberships, :reject_if => lambda { |a| a[:user_id].blank? }, :allow_destroy => true
  
  has_many :instructor_memberships, :class_name => "CourseMembership", :conditions => { :course_memberships => { :role => CourseMembership.instructorRole } }
  has_many :instructors, :through => :instructor_memberships, :class_name => "User", :source => :user
  accepts_nested_attributes_for :instructor_memberships, :reject_if => lambda { |a| a[:user_id].blank? }, :allow_destroy => true
  
  has_many :student_memberships, :class_name => "CourseMembership", :conditions => { :course_memberships => { :role => CourseMembership.studentRole } }
  has_many :students, :through => :student_memberships, :class_name => "User", :source => :user
  accepts_nested_attributes_for :student_memberships, :reject_if => lambda { |a| a[:user_id].blank? }, :allow_destroy => true
end
