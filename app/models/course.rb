class Course < ActiveRecord::Base
  attr_accessible :description, :graph_id, :name, :course_memberships_attributes, :instructor_memberships_attributes, :student_memberships_attributes, :node_indices_attributes
  
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
  
  has_many :nodes, :finder_sql => proc { "WITH RECURSIVE subgraphs AS ( SELECT subgraph_id FROM graph_membership_graphs WHERE graph_id = #{graph.id} UNION ALL SELECT g.subgraph_id FROM graph_membership_graphs g, subgraphs sg WHERE g.graph_id = sg.subgraph_id) SELECT n.*, ni.row AS row, ni.index AS index, ni.id AS rank_id FROM nodes n LEFT JOIN node_indices ni ON n.id = ni.node_id AND (ni.course_id = #{id} OR ni.course_id = NULL) WHERE n.id IN (SELECT DISTINCT m.node_id FROM graph_membership_nodes m, subgraphs sg WHERE m.graph_id = sg.subgraph_id OR m.graph_id = #{graph.id}) ORDER BY row, index ASC" }
  
  has_many :node_indices
  accepts_nested_attributes_for :node_indices, :allow_destroy => false
  
  def update_nodes_rank
    # This function makes sure that every node that belongs to a course (through the course graph) has an entry the NodeIndex table
    # Otherwise, the page that allows rearranging nodes' rank in a course will not work
    
    query = ""
    result = ActiveRecord::Base.connection.select_all( "WITH RECURSIVE subgraphs AS ( SELECT subgraph_id FROM graph_membership_graphs WHERE graph_id = #{graph.id} UNION ALL SELECT g.subgraph_id FROM graph_membership_graphs g, subgraphs sg WHERE g.graph_id = sg.subgraph_id)
    SELECT n.id FROM nodes n WHERE n.id IN (SELECT DISTINCT m.node_id FROM graph_membership_nodes m, subgraphs sg WHERE m.graph_id = sg.subgraph_id OR m.graph_id = #{graph.id}) AND n.id NOT IN (SELECT n.id FROM nodes n RIGHT JOIN node_indices ni ON n.id = ni.node_id AND (ni.course_id = #{id} OR ni.course_id = NULL) WHERE n.id IN (SELECT DISTINCT m.node_id FROM graph_membership_nodes m, subgraphs sg WHERE m.graph_id = sg.subgraph_id OR m.graph_id = #{graph.id}));"); # gets ids of nodes that have entries in the NodeIndex table

    result.each do |h|
      query += ", " if query != ""
      query += "(#{id},#{h["id"].to_i},500,500,'#{Time.now}','#{Time.now}')"
    end

    ActiveRecord::Base.connection.select_all("INSERT INTO node_indices (\"course_id\", \"node_id\", \"row\", \"index\", \"created_at\", \"updated_at\") VALUES #{query};") if query != ""
  end
  
  def to_s
    "#{name}"
  end
end
