class MultipleChoiceQuestion < Question
  validates_presence_of :text

  def process_editor_data(data)
    self.answers  = data[:answer]
    self.choices  = data[:choices].map{ |x| Question.strip_paragraph(Question.process_text(x)) }
    return true
  end

  def grade(resp)
  	return self.answers[0] == resp
  end

end
