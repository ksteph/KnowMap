# == Schema Information
#
# Table name: questions
#
#  id                  :integer         not null, primary key
#  type                :string(100)
#  text                :text
#  choices             :text
#  answers             :text
#  explanations        :text
#  parent_id           :integer
#  child_index         :integer
#  weight              :decimal(10, 4)  default(1.0)
#  json                :text
#  raw_source          :text
#  raw_source_format   :string(255)
#  javascript_includes :text
#  parameters          :text
#  created_at          :datetime        not null
#  updated_at          :datetime        not null
#  course_id           :integer
#  title               :string(255)
#

class SelectAllQuestion < Question

  # Assumes the input is an array of strings containing integers
  def preprocess_answer(answer)
    return [] if answer.nil? or answer.blank?
    return answer.map{ |x| x.to_i }
  end

  # Assumes answer is an array of integers and self.answers is an array of
  # integers.
  def is_correct?(answer)
    return false if answer.nil?
    return false if (self.answers - answer).length != 0
    return false if (answer - self.answers).length != 0
    return true
  end

  def choice_correct?(choice)
    return self.answers.include? choice
  end

  def process_editor_data(data)
    self.answers  = data[:answer]
    self.choices  = data[:choices].map{ |x| Question.strip_paragraph(Question.process_text(x)) }
    return true
  end

end
