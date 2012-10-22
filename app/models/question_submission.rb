class QuestionSubmission < ActiveRecord::Base
  attr_accessible :correct, :node_id, :question_id, :student_answers, :user_id

  # serialize :student_answers

  belongs_to :node
  belongs_to :question
  belongs_to :user

  validates :node_id, :question_id, :user_id, :presence => true

end
