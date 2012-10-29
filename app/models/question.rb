require 'pandoc-ruby'

class Question < ActiveRecord::Base
  attr_accessible :answers, :choices, :explanations, :hint, :node_id, :type, :text, :json

  serialize :choices
  serialize :answers
  serialize :explanations

  belongs_to :node
  has_many :question_submissions, :dependent => :delete_all

  validates :node_id, :answers, :presence => true

  def self.from_editor_data(data, params={})

    # Converts string keys to symbols
    data = data.each_with_object({}){|(k,v), h| h[k.to_sym] = v}

    type = data[:type]
    #TODO: this should return some sort of error if it wasn't saved?
    case type
      when "QuestionGroup", "SelectAllQuestion", "MultipleChoiceQuestion", "EssayQuestion"#, "CustomHTMLChooseAll", "CustomHTMLMultipleChoice"
        question        = type.constantize.new
        question.node_id = params[:node_id]
        question.json   = data.to_json
        question.text   = process_text(data[:description])
        question.title  = strip_paragraph(process_text(data[:title]))
        if data[:explanation] and data[:explanation].strip != ""
          question.explanations     = process_text(data[:explanation])
        end
      else
        return nil
    end

    if question.process_editor_data(data) and question.save
      return question
    else
      return nil
    end
  end

  protected

    def self.process_text(text)
      return PandocRuby.convert(text, {:from => :markdown, :to => :html, :mathjax => nil})
    end

    def self.strip_paragraph(choice)
      return choice.gsub(/^<p>/, "").gsub("</p>","")
    end

end
