error = QuestionEditor.error
warning = QuestionEditor.warning
getPrefix = QuestionEditor.getPrefix
getId = QuestionEditor.getId
getPreviewId = QuestionEditor.getPreviewId
getHeadId = QuestionEditor.getHeadId

class Assignment extends Question

  abstract: false
  questionType: "Assignment"

  children: []

  constructor: (params) ->
    super(params)
    @data["element_list"] = @data["element_list"] || []

  buildPreviewFields: ->

  updateData: ->

  getSubElements: ->
    sub_elements = []
    for elem in @getField("sub_elements").children()
      sub_elements.push QuestionEditor.getElement(getHeadId($(elem).attr("id")))
    return sub_elements

  buildInputFields: ->

    @sub_elements = @addField
      id: "sub_elements"
      type: "div"
      attrs:
        class: "sub_elements"

    button_container_container = @addField
      id: "button_container_container"
      type: "div"
      attrs:
        class: "button_container_container"
        style: "position: absolute; bottom: 0; width: 100%"

    button_container = @addField
      id: "button_container"
      type: "div"
      attrs:
        class: "button_container"
      parent_element: button_container_container

    @addField
      id: "btn_add_question"
      type: "button"
      html: "Add Question"
      attrs:
        class: "button btn_add_question"
      parent_element: button_container
      bind:
        click: =>
          @addQuestion()

    for element in @data["element_list"]
      @addQuestion element
      QuestionEditor.createNewQuestion # TODO is this line necessary..?

  addQuestion: (data) ->
    section_connector = if @section == "" then "" else "."
    new_section = @section + section_connector + (++@cntSubElements)
    new_question = QuestionEditor.createNewQuestion
      parent: @
      parent_element: @sub_elements
      section: new_section
      data: data

    @children.push new_question

root = exports ? this
root.Assignment = Assignment
QuestionEditor.registerQuestionType "Assignment"
