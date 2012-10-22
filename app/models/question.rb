class Question < ActiveRecord::Base
  attr_accessible :answers, :choices, :explanations, :hint, :node_id, :type, :prompt

#   serialize :choices
#   serialize :answers
#   serialize :explanations

  belongs_to :node
  has_many :question_submissions, :dependent => :delete_all

  validates :node_id, :prompt, :answers, :presence => true
  
end
