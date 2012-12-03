error = QuestionEditor.error
warning = QuestionEditor.warning
getPrefix = QuestionEditor.getPrefix
getId = QuestionEditor.getId
getPreviewId = QuestionEditor.getPreviewId
getHeadId = QuestionEditor.getHeadId

class EssayQuestion extends StandardQuestion

  abstract: false
  questionType: "EssayQuestion"
  description: "Essay Question"

  constructor: (params) ->
    super(params)

  buildCustomPreviewFields: ->

  updateCustomData: ->

  buildCustomFields: ->


  addQuestion: (data) ->
    section_connector = if @section == "" then "" else "."
    new_section = @section + section_connector + (++@cntSubElements)
    new_question = QuestionEditor.createNewQuestion
      parent: @
      parent_element: @sub_elements
      section: new_section
      data: data


root = exports ? this
root.EssayQuestion = EssayQuestion
#QuestionEditor.registerQuestionType "EssayQuestion"
