class NodeIndex < ActiveRecord::Base
  attr_accessible :course_id, :index, :row, :node_id
  
  belongs_to :course
end
