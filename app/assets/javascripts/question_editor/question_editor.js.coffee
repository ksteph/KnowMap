root = exports ? this

String::strip = -> if String::trim? then @trim() else @replace /^\s+|\s+$/g, ""

addError = (errorMsg) ->
  if $("#error_list").length
    $("#error_list").append("<li>#{errorMsg}</li>")
  else
    errorDiv = $('<div>').attr('id', "errors").addClass("message")
    errorDiv.html("<ul id='error_list'><li>#{errorMsg}</li></ul>")
    $("form").before(errorDiv)
  window.scrollTo 0, 0

getClass = (cls) ->
  root[cls]

class QuestionEditor

  @questionTypes: []
  @elements: []

  @config:
    ignoreEmptyChoices    : true
    defaultQuestionType   : "MultipleChoiceQuestion"
    renderMaxDelay        : 3000
    editors               : ["QuickEditor"]
    defaultEditor         : "QuickEditor"
    editorType            : "Question"
    reservedQuestionTypes : ["Assignment"]
    submitId              : "submit"
    c_empty_checkbox      : "&#9744;"
    c_checked_checkbox    : "&#9745;"
    c_empty_radiobox      : "&#9675;"
    c_checked_radiobox    : "&#9679;"
    embedded              : false
    onSubmitSuccess: ->
    onSubmitError: ->

  @getPreviewId: (id) -> id.replace /^preview_field_/, ""

  @getPrefix: (element_id) -> "element_#{element_id}"

  @getHeadId: (str) -> str.replace /^element_(\d)*.*/, ($0, $1) -> $1

  @getId: (id) -> id.replace /^element_\d*_/, ""

  @error: (msg) -> console.log "Error: #{msg}"

  @warning: (msg) -> console.log "Warning: #{msg}"

  @init: (elem, config)->

    $.extend @config, config
    @elem = elem
    @elements = []

    @rendermd = (text) ->
      (new Showdown.converter()).makeHtml(text)

    @initRegExp()
    @initPanel()
    @initSubmit()

  @initSubmit: ->
    cur = @
    $("##{@config.submitId}").removeAttr('disabled')
    $("##{@config.submitId}").click (event) ->
      $(this).attr('disabled', 'disabled')
      $('#errors').remove()

      # For Assignments, leave out for now
      ###
      if $("#assignment_title").val().strip() == ""
        $("#assignment_title").wrap($('<div>').addClass('field_with_errors'))
        addError("Please give your assignment a name.")
        $(this).removeAttr('disabled')
        $("#assignment_title").focus()
        return false
      else
        if $("#assignment_title").parent(".field_with_errors").length
          $("#assignment_title").unwrap()
      ###
      
      event.preventDefault()

      data = cur.elements[0].getAllData
        clean: true
      if cur.config.editorType == "Assignment" and (not data.element_list or not data.element_list.length)
        addError("Please add some questions before submitting your assignment.")
        console.log "added please add"
        $("##{cur.config.submitId}").removeAttr('disabled')
        return false
      else if data.error_list.length
        for error in data.error_list
          addError error
          console.log "added:"
          console.log error
        $("##{cur.config.submitId}").removeAttr('disabled')
        return false
      
      if cur.config.editorType == "Question"
        post_data =
          question:
            data: JSON.stringify(data)
            raw_source: ""
          embedded : cur.config.embedded
      else if cur.config.editorType == "Assignment"
          post_data =
            assignment:
              data: JSON.stringify(data)
              raw_source: ""
              title: $("#assignment_title").val()
            embedded : cur.config.embedded
      console.log post_data
      path = cur.config.formPath or $('form').attr('action')
      $.ajax {
        type: "POST"
        url: path
        data: post_data
        dataType: "json"
        success: cur.config.onSubmitSuccess
        error: cur.config.onSubmitError
      }

  @registerQuestionType: (questionType) ->
    if typeof questionType == "string"
      questionClass = getClass(questionType)
      if not questionClass
        error "Question type #{questionType} not found"
        return
      if questionClass::abstract == undefined
        error "Unrecognized question type #{questionType}"
        return
      if questionClass::abstract
        error "Cannot register an abstract question type"
        return
      @questionTypes.push questionType
    else if typeof questionType == "object"
      for qtype in questionType
        @registerQuestionType qtype
    else
      error "QuestionEditor.registerQuestionType only accepts string or array"

  @getQuestionOptions: ->
    options = {}
    for questionType in @questionTypes
      if questionType not in @config["reservedQuestionTypes"]
        options[questionType] = getClass(questionType)::description
    options

  @initQuickEditor: ->
    if @config.editorType == "Assignment"
      @createNewQuestion
        parent_element: $("#editor")
        type: "Assignment"
        section: ""
    else if @config.editorType == "Question"
      @createNewQuestion
        parent_element: $("#editor")
        type: "MultipleChoiceQuestion"
        section: ""

  @initPanel: ->

    preview_buffer = $("<div>").attr("id", "preview_buffer")
    editor = $("<div>").attr("id", "editor")

    if @config["defaultEditor"] not in @config["editors"]
      error "default editor must be in editors"
      return

    # TODO: Fix this when we want the Source Editor and need tabs again.
    ###
    tabs_wrapper = $("<div>").attr("id", "tabs")
    tabs = $("<ul>").addClass("tabs")
    tabs_editor = $("<div>").attr("id", "tabs_editor")
    if "QuickEditor" in @config["editors"]
      editor_tab = $("<li>").addClass("tab").attr("id", "tab_quick_editor")
      if @config["defaultEditor"] == "QuickEditor"
        editor_tab.addClass("selected")
      editor_tab.append($("<a>").attr("href", "#tabs_quick_editor").html("Editor"))
      tabs.append(editor_tab)
      tabs_editor.append($("<div>").attr("id", "tabs_quick_editor"))

    if "SourceEditor" in @config["editors"]
      editor_tab = $("<li>").addClass("tab").attr("id", "tab_source")
      if @config["defaultEditor"] == "SourceEditor"
        editor_tab.addClass("selected")
      editor_tab.append($("<a>").attr("href", "#tabs_source").html("Source View"))
      tabs.append(editor_tab)
      tabs_editor.append($("<div>").attr("id", "tabs_source").append($("<textarea>").attr("id", "source")).append($("<div>").addClass("preview").attr("id", "source_preview")))

    editor.append(tabs_wrapper.append(tabs)).append(tabs_editor)
    ###

    $(@elem).append(preview_buffer).append(editor)

    if "QuickEditor" in @config["editors"]
      @initQuickEditor()
    if "SourceEditor" in @config["editors"]
      @initSourceEditor()

  @deleteQuestion: (element_id) ->
    prefix = getPrefix element_id

    @elements[element_id] = undefined
    $("##{prefix}_wrapper").remove()

    @fixSections()

  @createNewQuestion: (params) ->

    parent_element = params["parent_element"]

    if not parent_element
      error "Must provide parent element for new question"
      return

    type = params["type"] || @config.defaultQuestionType
    section = params["section"] || ""

    if type not in @questionTypes
      error "unregistered question type: #{type}"
      return

    for elem in @elements
      if elem and elem["doneEdit"]?
        elem.doneEdit()

    element_id = @elements.length
    prefix = getPrefix element_id

    element_wrapper = $("<div>").addClass("element_wrapper").attr("id", "#{prefix}_wrapper").append($("<div>").addClass("element").attr("id", "#{prefix}"))
    parent_element.append(element_wrapper)

    element = new (getClass(type))
      element_id: element_id
      section: section
      parent: params["parent"]
      data: params["data"]

    element.buildInput()

    @elements[element_id] = element

    return element

  @fixSections: (element_id, section_prefix) ->

    element_id = element_id || 0
    section_prefix = section_prefix || ""
    section_joint = if section_prefix then '.' else ''

    element = @getElement(element_id)
    element.fixSection(section_prefix)

    element.cntSubElements = 0

    header = element.getPreviewField("header")
    if header
      renderer = element.getPreviewRenderer("header")
      renderer @getElement(element_id), header

    for sub_element in element.getSubElements()
      @fixSections sub_element.element_id, section_prefix + section_joint + (++element.cntSubElements)


  @transformElement: (element_id, type) ->
    prefix = getPrefix element_id
    element_container = $("##{prefix}")
    element = @elements[element_id]
    section = element.section
    data = $.extend(true, {}, element.getAllData())
    element_container.children().remove()
    @elements[element_id] = new (getClass(type))
      parent: element.parent
      element_id: element_id
      section: section
      data: $.extend(true, {}, data)
    @elements[element_id].buildInput()

  @getElement: (element_id) ->
    @elements[element_id]

  @getElements: ->
    (elem for elem in @elements when elem and elem?)
    # TODO: is the elem? necessary?

  @initRegExp: ->
    s_spaces              = "[\\s\\t]*"
    s_blanks = "[\\s\\t\\r\\n]*"
    s_blank_line = "^[\\s\\r\\n]*$"
    s_new_line = "\\r\\n|\\r|\\n"
    s_option_key = "\\w+"
    s_option_value = ".*?"
    s_option =
      "^" + s_spaces + "\\-" + s_spaces +
      "(" + s_option_key + ")" + # option key stored in $1
      s_spaces + ":" + s_spaces +
      "(" + s_option_value + ")" + # option value stored in $2
      s_blanks + "(?=\\-|$)"
    s_option_start =
      "^" +
      s_blanks +
      "\\-" + s_spaces +
      "(" + s_option_key + ")" + # option key stored in $1
      s_spaces + ":" + s_spaces +
      "(" + s_option_value + ")" + # option value stored in $2
      s_blanks + "(?=\\-|$)"
    s_question_identifier = "\\w+?"
    s_end_identifier      = "end"
    s_score               = "[\\-\\+]?\\d*\\.?\\d+"
    s_section             = "\\d+(\\.\\d+)*"
    s_question_start =
      "^" + s_spaces + "={2,}" + s_spaces + # leading spaces + ==...
      "(" + s_question_identifier + ")" +                              # identifier stored in $1
      s_spaces +
      "(" + s_section + ")?" +              # optional section number, stored in $2
      s_spaces +
      "(\\((" + s_score + ")\\))?" +        # optional score, stored in $5
      ".*" +                                # anything; allow wrong syntax at the end of the line (mainly for preview effect)
      s_spaces + "$"                        # strict format: does not allow anything else
    s_question_end =
      "^" + s_spaces + "={2,}" + s_spaces + # leading spaces + ==...
      "(" + s_end_identifier + ")" +        # end / End / e / E ...
      s_spaces + "$"                        # strict format
    #s_group_start    = sprintf s_start, s_group_identifier
    #s_group_end      = sprintf s_end, s_group_identifier
    s_separator      = "^" + s_spaces + "\\-{2,}" + s_spaces + "$"
    s_border =
      "(" +
         "(" + s_question_start + ")" +
        "|(" + s_question_end   + ")" +
      ")"
    s_radiobox       = "\\(" + s_spaces + "x?" + s_spaces + "\\)"
    s_checkbox       = "\\[" + s_spaces + "x?" + s_spaces + "\\]"
    s_choice =
      "(" + s_radiobox + ")" +
      "|" +
      "(" + s_checkbox + ")"
    s_choice_label = "\\{.*?\\}"
    s_text_after_choice = ".*?"
    s_text_after_choice_look_ahead =
      "?=(" + # look ahead
      "(<\\/?[\\w\\s]+\\/?\\s*>)" + "|" + # look for html tags
      "(%s)" + "|" + # fill this later according to choice type (only match the same type)
      "$" + # or, a new line
      ")"
    s_custom_choice =
      "(%s)" + # store choice in $1
      "(" + s_choice_label + ")?" + # store group label in $2
      "(" + s_text_after_choice + ")" + # store label in $3
      "(" + s_text_after_choice_look_ahead + ")"
    s_custom_multiple_choice = sprintf s_custom_choice, s_radiobox, s_radiobox
    s_custom_choose_all = sprintf s_custom_choice, s_checkbox, s_checkbox
    s_correct_choice = ("(" + s_radiobox + ")|(" + s_checkbox + ")").replace /\?/g, ''
    s_radiobox_line =
      "^" + s_spaces +               # leading spaces
      "(" + s_radiobox + ")" + # match the choice box, store in $1
      s_spaces +               # spaces
      "(.*)"                 # label for the choice, store in $2 TODO check this
    s_checkbox_line =
      "^" + s_spaces +               # leading spaces
      "(" + s_checkbox + ")" + # match the choice box, store in $1
      s_spaces +               # spaces
      "(.*)"                 # label for the choice, store in $2
    s_choice_line =
      "^" + s_spaces +               # leading spaces
      "(" + s_choice + ")" + # match the choice box, store in $1
      s_spaces +               # spaces
      "(.*)"                 # label for the choice, store in $4

    @regex = {
      option                 : new XRegExp s_option, "migs"
      option_start           : new XRegExp s_option_start, "mis"
      blank_line             : new RegExp  s_blank_line
      section                : new RegExp  s_section
      separator              : new RegExp  s_separator, "mg"
      question_start         : new RegExp  s_question_start, "i"
      #group_start            : new RegExp  s_group_start, "i"
      question_end           : new RegExp  s_question_end, "i"
      #group_end              : new RegExp  s_group_end, "i"
      border                 : new RegExp  s_border, "i"
      custom_multiple_choice : new RegExp  s_custom_multiple_choice, "mgi"
      custom_choose_all      : new RegExp  s_custom_choose_all, "mgi"
      correct_choice         : new RegExp  s_correct_choice, "i"
      radiobox_line          : new RegExp  s_radiobox_line, "i"
      checkbox_line          : new RegExp  s_checkbox_line, "i"
      choice_line            : new RegExp  s_choice_line, "i"
      radiobox               : new RegExp  s_radiobox, "i"
      checkbox               : new RegExp  s_checkbox, "i"
    }

error = QuestionEditor.error
warning = QuestionEditor.warning
getPrefix = QuestionEditor.getPrefix
getId = QuestionEditor.getId
getPreviewId = QuestionEditor.getPreviewId
getHeadId = QuestionEditor.getHeadId

root.QuestionEditor = QuestionEditor
