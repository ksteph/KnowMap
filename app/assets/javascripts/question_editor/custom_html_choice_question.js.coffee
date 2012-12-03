class CustomHTMLChoiceQuestion extends StandardQuestion

  abstract: true

  constructor: (params) ->
    super(params)
    @data["choices_template"] = @data["choices_template"] || ""
    @data["answer"] = @data["answer"] || []

  updateCustomData: ->

    @data["choices_template"] = @getFieldData("input_custom_html") || ""
    @data["answer"] = []
    cnt_choices = 0
    @data["choices_template"].replace @r_choice_matcher, ($0, $1, $2, $3, $4, $5) =>
      if $1.match QuestionEditor.regex.r_correct_choice
        @data["answer"].push(cnt_choices)
      cnt_choices += 1

  buildCustomPreviewFields: (preview) ->
    custom_mathjax_delay = new MathJaxDelayRenderer()

    customHtmlPreprocessor = (text) =>
      QuestionEditor.rendermd text.replace @r_choice_matcher, ($0, $1, $2, $3, $4, $5) =>
        str = ""
        if $1.match QuestionEditor.regex.correct_choice
          str += @c_checked
        else
          str += @c_empty
        str += $3
        return str

    @addPreviewField
      id: "custom_html"
      type: "div"
      parent_element: preview
      attrs:
        style: "text-align:left"
      renderer: (elem, field, delay) =>
        if not delay?
          delay = true
        custom_mathjax_delay.render
          element: field
          text: elem.getData "choices_template"
          preprocessor: customHtmlPreprocessor
          delay: delay

  buildCustomInputFields: (parent_element) ->

    choices_wrapper = @addField
      id: "choices_wrapper"
      type: "div"
      attrs:
        class: "choices_wrapper"
      parent_element: parent_element

    custom_html_wrapper = @addField
      id: "custom_html_wrapper"
      type: "div"
      attrs:
        class: "custom_html_wrapper"
      parent_element: parent_element

    @addField
      id: "input_custom_html"
      type: "textarea"
      attrs:
        rows: "4"
      data: @data["choices_template"]
      label: "Custom Layout for Choices"
      sync: "custom_html"
      parent_element: custom_html_wrapper


class CustomHTMLChooseAllQuestion extends CustomHTMLChoiceQuestion

  abstract: false
  questionType: "CustomHTMLChooseAllQuestion"
  description: "Select all with custom layout"

  constructor: (params) ->
    super(params)
    @r_choice_matcher = QuestionEditor.regex.custom_choose_all
    @c_checked = QuestionEditor.config.c_checked_checkbox
    @c_empty = QuestionEditor.config.c_empty_checkbox
  
class CustomHTMLMultipleChoiceQuestion extends CustomHTMLChoiceQuestion

  abstract: false
  questionType: "CustomHTMLMultipleChoiceQuestion"
  description: "Multiple choice with custom layout"

  constructor: (params) ->
    super(params)
    @r_choice_matcher = QuestionEditor.regex.custom_multiple_choice
    @c_checked = QuestionEditor.config.c_checked_radiobox
    @c_empty = QuestionEditor.config.c_empty_radiobox

root = exports ? this

root.CustomHTMLChooseAllQuestion = CustomHTMLChooseAllQuestion
root.CustomHTMLMultipleChoiceQuestion = CustomHTMLMultipleChoiceQuestion
#QuestionEditor.registerQuestionType ["CustomHTMLChooseAllQuestion", "CustomHTMLMultipleChoiceQuestion"]
