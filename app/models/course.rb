class Course < ActiveRecord::Base
  attr_accessible :description, :graph_id, :name
  
  belongs_to :graph
end
