error = QuestionEditor.error
warning = QuestionEditor.warning
getPrefix = QuestionEditor.getPrefix
getId = QuestionEditor.getId
getPreviewId = QuestionEditor.getPreviewId
getHeadId = QuestionEditor.getHeadId

class SimpleChoiceQuestion extends StandardQuestion

  abstract: true
  cntChoices: 0

  constructor: (params) ->

    super(params)
    if not @data["choices"]?
      @data["choices"] = [""]
      @data["answer"] = [0]
    if not @data["answer"]?
      @data["answer"] = []
    @data["choices"] = @data["choices"].slice(0)
    @data["answer"] = @data["answer"].slice(0)

  updateCustomData: ->

    @data["choices"] = []
    @data["answer"] = []
    for i in [0...@cntChoices]
      if not @getField "input_choice_text_#{i}"
        continue
      choice = @getFieldData "input_choice_text_#{i}"
      if QuestionEditor.config.ignoreEmptyChoices and choice.match QuestionEditor.regex.blank_line
        continue
      @data["choices"].push choice
      if @getFieldData("input_choice_#{i}") == true
        @data["answer"].push @data["choices"].length - 1
      # TODO
      #else if $(element).children(".input_choice").attr("checked") and
      #    root.element_info[element_id].type == "MultipleChoiceQuestion" and
      #    not choice.strip()
      #        error_list.push "Question " + root.element_info[element_id].section_prefix + ": Multiple choice question must have an answer selected."
    if @data["choices"].length == 0
      @data["choices"].push ""
      @data["answer"].push 0


  addChoice: (params) ->

    params = params || {}
    parent_element = params["parent_element"] || @input_choices
    prefix = getPrefix @element_id
    choice_id = @cntChoices++

    choice_wrapper = @addField
      id: "choice_wrapper_#{choice_id}"
      type: "div"
      attrs:
        class: "choice_wrapper #{prefix}_choice_wrapper"
      parent_element: parent_element

    @addField
      id: "input_choice_#{choice_id}"
      type: @choiceType
      sync: "choice_status_#{choice_id}"
      name: "input_choice"
      data: params["is_answer"] || "false"
      attrs:
        class: "input_choice #{prefix}_input_choice"
      parent_element: choice_wrapper

    @addField
      id: "input_choice_text_#{choice_id}"
      name: "input_choice_text_#{choice_id}"
      sync: "choice_text_#{choice_id}"
      type: "textarea"
      data: params["choice"] || ""
      attrs:
        class: "input_choice_text #{prefix}_input_choice_text"
      bind:
        keydown: (event) =>
          keyCode = event.keyCode || event.which
          if keyCode == 9
            event.preventDefault()
            if event.shiftKey
              prev_choice_id = choice_id - 1
              while prev_choice_id >= 0
                prev_field = @getField "input_choice_text_#{prev_choice_id}"
                if prev_field
                  break
                --prev_choice_id
              if not prev_field
                ->
                @getField("explanation").focus()
              else
                prev_field.focus()
            else
              next_choice_id = choice_id + 1
              while next_choice_id <= @cntChoices - 1
                next_field = @getField "input_choice_text_#{next_choice_id}"
                if next_field
                  break
                ++next_choice_id
              if not next_field
                @addChoice()
                @getField("input_choice_text_#{@cntChoices - 1}").focus()
              else
                next_field.focus()
      parent_element: choice_wrapper

    @addField
      id: "delete_choice_#{choice_id}"
      type: "button"
      html: "<img src='/assets/icons/cross.png'/>"
      attrs:
        class: "delete_choice #{prefix}_delete_choice"
      parent_element: choice_wrapper
      bind:
        click: =>
          @deleteChoice(choice_id)

    choice_wrapper = @addPreviewField
      type: "span"
      id: "choice_wrapper_#{choice_id}"
      attrs:
        style: "text-align: left"
      parent_element: @preview_choice_wrapper

    choice_status = @addPreviewField
      type: "li"
      id: "choice_status_#{choice_id}"
      parent_element: choice_wrapper
      attrs:
        style: "text-align: left"
      renderer: (elem, field) =>
        @updateCustomData()
        for cid in [0...@cntChoices]
          field = @getPreviewField "choice_status_#{cid}"
          if not field
            continue
          @updateFieldData "input_choice_#{cid}"
          is_correct = @getFieldData "input_choice_#{cid}"
          if is_correct
            field.addClass("chosen")
          else
            field.removeClass("chosen")

    choice_mathjax_delay = new MathJaxDelayRenderer()
    choice_preprocessor = (text) ->
      QuestionEditor.rendermd(text).replace(/<p>/g, '').replace(/<\/p>/g, '')

    choice_text = @addPreviewField
      type: "span"
      id: "choice_text_#{choice_id}"
      parent_element: choice_status
      attrs:
        class: "item_wrapper"
        style: "text-align: left"
      renderer: (elem, field, delay) =>
        if not delay?
          delay = true
        @updateCustomData()
        @updateFieldData "input_choice_text_#{choice_id}"
        text = @getFieldData "input_choice_text_#{choice_id}"
        if QuestionEditor.config.ignoreEmptyChoices
          if not text? or text == ""
            @getPreviewField("choice_wrapper_#{choice_id}").css("display", "none")
          else
            @getPreviewField("choice_wrapper_#{choice_id}").css("display", "block")
        choice_mathjax_delay.render
          element: field
          text: text
          preprocessor: choice_preprocessor
          delay: delay

  deleteChoice: (choice_id) ->

    @removePreviewField "choice_wrapper_#{choice_id}"
    @removeField("choice_wrapper_#{choice_id}")

  buildCustomPreviewFields: (preview) ->

    @preview_choice_wrapper = @addPreviewField
      id: "choice_wrapper"
      type: "ol"
      parent_element: preview

  buildCustomInputFields: (parent_element) ->

    choices_wrapper = @addField
      id: "choices_wrapper"
      type: "div"
      attrs:
        class: "choices_wrapper"
      parent_element: parent_element

    @addField
      id: "choices_label"
      type: "div"
      attrs:
        class: "choices_label"
      html: "Choices"
      parent_element: choices_wrapper

    @input_choices = @addField
      id: "input_choices"
      type: "div"
      attrs:
        class: "input_choices"
      parent_element: choices_wrapper

    button_container = @addField
      id: "button_container"
      type: "div"
      attrs:
        class: "button_container"
      parent_element: choices_wrapper

    @addField
      id: "btn_add_choice"
      type: "button"
      html: "Add Choice"
      attrs:
        class: "btn btn_add_choice"
      parent_element: button_container
      bind:
        click: =>
          @addChoice()

    @bindFieldEvent "explanation", "keydown", (event) =>
      keyCode = event.keyCode || event.which
      if keyCode == 9
        if not event.shiftKey
          event.preventDefault()
          next_choice_id = 0
          while next_choice_id <= @cntChoices - 1
            next_field = @getField "input_choice_text_#{next_choice_id}"
            if next_field
              break
            ++next_choice_id
          if not next_field
            @addChoice()
            @getField("input_choice_text_#{@cntChoices - 1}").focus()
          else
            next_field.focus()

  buildCustomFields: ->
    backup_choices = @data["choices"].slice(0)
    backup_answer = @data["answer"].slice(0)

    for choice, i in backup_choices
      @addChoice
        choice: choice
        is_answer: i in backup_answer

class MultipleChoiceQuestion extends SimpleChoiceQuestion

  abstract: false
  questionType: "MultipleChoiceQuestion"
  description: "Multiple choice"
  choiceType: "input_radio"

class SelectAllQuestion extends SimpleChoiceQuestion
  
  abstract: false
  questionType: "SelectAllQuestion"
  description: "Select all that apply"
  choiceType: "input_checkbox"

root = exports ? this
root.MultipleChoiceQuestion = MultipleChoiceQuestion
root.SelectAllQuestion = SelectAllQuestion

QuestionEditor.registerQuestionType ["MultipleChoiceQuestion", "SelectAllQuestion"]
