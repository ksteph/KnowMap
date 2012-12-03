error = QuestionEditor.error
warning = QuestionEditor.warning
getPrefix = QuestionEditor.getPrefix
getId = QuestionEditor.getId
getPreviewId = QuestionEditor.getPreviewId
getHeadId = QuestionEditor.getHeadId

class QuestionGroup extends StandardQuestion

  abstract: false
  questionType: "QuestionGroup"
  description: "Question group"
  children: []

  constructor: (params) ->
    super(params)
    @data["element_list"] = @data["element_list"] || []

  buildCustomPreviewFields: ->

  updateCustomData: ->

  fixSection: (section_prefix) ->
    super(section_prefix)
    @getField("btn_add_question").html("Add Question to Group #{@section}")


  getSubElements: ->
    sub_elements = []
    for elem in @getField("sub_elements").children()
      sub_elements.push QuestionEditor.getElement(getHeadId($(elem).attr("id")))
    return sub_elements

  buildCustomFields: ->

    @sub_elements = @addField
      id: "sub_elements"
      type: "div"
      attrs:
        class: "sub_elements"

    button_container = @addField
      id: "button_container"
      type: "div"
      attrs:
        class: "button_container"

    @addField
      id: "btn_add_question"
      type: "button"
      html: "Add Question to Group #{@section}"
      attrs:
        class: "button btn_add_question"
      parent_element: button_container
      bind:
        click: =>
          @addQuestion()
          
    for element in @data["element_list"]
      @addQuestion element
      QuestionEditor.createNewQuestion # TODO is this line necessary?

  addQuestion: (data) ->
    section_connector = if @section == "" then "" else "."
    new_section = @section + section_connector + (++@cntSubElements)
    new_question = QuestionEditor.createNewQuestion
      parent: @
      parent_element: @sub_elements
      section: new_section
      data: data

    @children.push new_question


#root = exports ? this
#root.QuestionGroup = QuestionGroup
#QuestionEditor.registerQuestionType "QuestionGroup"
