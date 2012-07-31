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
  
  has_many :nodes, :finder_sql => proc { "WITH RECURSIVE subgraphs AS ( SELECT subgraph_id FROM graph_membership_graphs WHERE graph_id = #{id} UNION ALL SELECT g.subgraph_id FROM graph_membership_graphs g, subgraphs sg WHERE g.graph_id = sg.subgraph_id) SELECT n.*, ni.row AS row, ni.index AS index FROM nodes n LEFT JOIN node_indices ni ON n.id = ni.node_id WHERE n.id IN (SELECT DISTINCT m.node_id FROM graph_membership_nodes m, subgraphs sg WHERE m.graph_id = sg.subgraph_id OR m.graph_id = #{id}) ORDER BY row, index ASC" }
end
