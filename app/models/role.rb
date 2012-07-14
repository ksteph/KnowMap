class Role < ActiveRecord::Base
  attr_accessible :name
  has_and_belongs_to_many :users
  
  def self.student
    Role.find_by_name "Student"
  end
  def self.instructor
    Role.find_by_name "Instructor"
  end
  def self.admin
    Role.find_by_name "Admin"
  end
  def self.super
    Role.find_by_name "Super"
  end
end
