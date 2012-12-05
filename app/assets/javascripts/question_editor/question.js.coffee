error = QuestionEditor.error
warning = QuestionEditor.warning
getPrefix = QuestionEditor.getPrefix
getId = QuestionEditor.getId
getPreviewId = QuestionEditor.getPreviewId
getHeadId = QuestionEditor.getHeadId

class Question

  abstract: true

  cntSubElements: 0
  section: ""

  @syncTypes: ["input_text", "input_radio", "input_checkbox", "textarea", "select"]

  abstractmethod: (name) ->
    error "Method #{name} not implemented in question type #{@questionType}"

  constructor: (params) -> # should provide constructor which takes source or data as a parameter
    if @abstract
      error "Cannot create question of abstract question type!"
      return
    params = params || {}
    if params["data"]?
      if $.type(params["data"]) != "object"
        error "Parameter data must be of type object"
      @data = $.extend(true, {}, params["data"])
      @data = $.extend(true, {}, @data)
    else if "source" in params
      @data = @getDatafromSource(params["source"])
    else
      @data = {}

    @parent = params["parent"]
    @fields = {}
    @previewFields = {}

    if params["element_id"]?
      @element_id = params["element_id"]

    @data["type"] = @questionType

    @section = params["section"] || ""

    @isInputBuilt = false

  getPreview: ->
    
    

  fixSection: (section_prefix) ->
    @section = section_prefix

  getElement: ->
    if not @["element_id"]?
      error "element id not found"
      return undefined
    prefix = getPrefix @element_id
    ret = $("##{prefix}")
    if ret.length == 0
      error "element "+@["element_id"]+" not found"
      return undefined
    return ret

  getData: (field) ->
    @updateData()
    if not field?
      return @data
    return @data[field]

  getSubElements: ->
    []

  getAllData: (params) ->
    params = params || {}
    if params["clean"]
      @data = {}
    @updateData()
    @data["type"] = @questionType
    if @cntSubElements
      @data["element_list"] = []
      for element in @getSubElements()
        sub_data = element.getAllData(params)
        @data["element_list"].push sub_data
      @data["element_list"] = @data["element_list"].slice(0)
    @validateData()
    return @data

  validateData: ->
    @data.error_list = []
    if !@data["description"].length
      @data.error_list.push "Please enter a description"

  buildInputFields: ->
    @abstractmethod("buildInputFields")
  
  bindFieldEvent: (field_id, event, handler) ->
    
    @fields[field_id]["bind"][event] = handler
    @getField(field_id).unbind(event).bind(event, handler)

  getFieldData: (field_id) ->
    if not @fields[field_id]? or not @fields[field_id]
      error "field object for #{field_id} not found"
      return
    if not @fields[field_id]["data"]?
      @fields[field_id]["data"] = ""
    @fields[field_id]["data"]

  updateFieldData: (field_id) ->
    if not @fields[field_id]?
      error "field object for #{field_id} not found"
      return
    if not @fields[field_id]["field"]?
      error "field entry not found in object for #{field_id}"
      return
    switch @fields[field_id]["type"]
      when "textarea"
        @fields[field_id]["data"] = @getField(field_id).val() || ""
      when "input_text"
        @fields[field_id]["data"] = @getField(field_id).val() || ""
      when "input_radio"
        @fields[field_id]["data"] = @getField(field_id).attr("checked") == "checked"
      when "input_checkbox"
        @fields[field_id]["data"] = @getField(field_id).attr("checked") == "checked"
      when "select"
        @fields[field_id]["data"] = @getField(field_id).val()
      else
        error "unrecognized field type for data update: #{@fields[field_id]["type"]}"
        return

  updateData: ->
    @abstractmethod("updateData")

  bindSync: (field_id, preview_field_id) ->
    @getField(field_id).bind "input change keypress", =>
      @updateFieldData(field_id)
      @updateData()
      renderer = @getPreviewRenderer preview_field_id
      previewField = @getPreviewField preview_field_id
      if not renderer?
        error "renderer not found for preview id #{preview_field_id}"
        return
      renderer @, previewField

  buildInput: (element_id) ->

    if @["element_id"] == undefined
      @element_id = element_id
    if @element_id == undefined
      error "Cannot build input without element_id"
    if @isInputBuilt
      error "Cannot build input twice"

    @buildInputFields()
    @buildPreviewFields @preview
    @buildCustomFields()

    @isInputBuilt = true

  addPreviewField: (params) ->

    if not params["id"]?
      error "Must provide id for preview field"
      return

    parent_element = @getElement()
    if params["parent_element"]?
      parent_element = params["parent_element"]
      parent_id = getPreviewId $(parent_element).attr("id")
      if parent_id in @previewFields
        @previewFields[parent_id]["subfields"].push params["id"]

    params["type"] = params["type"] || "div"
    params["attrs"] = params["attrs"] || {}

    field = $("<#{params["type"]}>").attr(params["attrs"])
    field.attr("id", "preview_field_#{params["id"]}")
    @previewFields[params["id"]] = params
    @previewFields[params["id"]]["field"] = field
    @previewFields[params["id"]]["subfields"] = []
    $(parent_element).append(field)

    if params["renderer"]?
      params["renderer"] @, field, false
    return field
    
  getPreviewField: (field_id) ->
    if @["previewFields"]? and @previewFields[field_id]?
      return @previewFields[field_id]["field"]
    error "preview field #{field_id} unfound"
    return undefined

  getPreviewRenderer: (field_id) ->
    if @["previewFields"]? and @previewFields[field_id]?
      return @previewFields[field_id]["renderer"]
    error "preview renderer for #{field_id} unfound"
    return undefined

  getSubFields: (field_id) ->
    @fields[field_id]["subfields"]

  getSubPreviewFields: (field_id) ->
    @previewFields[field_id]["subfields"]

  removePreviewField: (field_id) ->
    for subfield in @getSubPreviewFields(field_id)
      @removePreviewField(subfield)
    @getPreviewField(field_id).remove()
    @previewFields[field_id] = undefined

  removeField: (field_id) ->
    for subfield in @getSubFields(field_id)
      @removeField(subfield)
    @getField(field_id).remove()
    @fields[field_id] = undefined

  addField: (params) ->

    parent_element = @getElement()

    if not params["id"]?
      error "Field must have an id"
      return

    if params["parent_element"]?
      parent_element = params["parent_element"]
      parent_id = getId $(parent_element).attr("id")
      @fields[parent_id]["subfields"].push params["id"]

    if params["wrapper"]?
      parent_element = $("<div>").attr(params["wrapper"]["attrs"] || {}).appendTo(parent_element)

    prefix = getPrefix @element_id

    field_id = "#{prefix}_#{params["id"]}"

    if params["label"]?
      label = $("<label>")
      label.attr("for", field_id)
      label.addClass("title_#{params["id"]}")
      label.html(params["label"])
      parent_element.append(label)

    params["attrs"] = params["attrs"] || {}

    switch params["type"]
      when "input_text"
        field = $("<input>").attr(params["attrs"]).attr("type", "text")
        field.val(params["data"] || "")
      when "input_radio"
        field = $("<input>").attr(params["attrs"]).attr("type", "radio")
        if params["data"] == true
          field.attr("checked", "checked")
      when "input_checkbox"
        field = $("<input>").attr(params["attrs"]).attr("type", "checkbox")
        if params["data"] == true
          field.attr("checked", "checked")
      when "textarea"
        field = $("<textarea>").attr(params["attrs"])
        field.val(params["data"] || "")
      when "div"
        field = $("<div>").attr(params["attrs"])
        if params["html"]
          field.html(params["html"])
      when "button"
        field = $("<a>").attr(params["attrs"]).attr("href", "javascript:void(0)").html(params["html"] || "")
      when "select"
        field = $("<select>").attr(params["attrs"])
        for type, description of params["options"]
          option = $("<option>").attr("value", type).html(description)
          if type == params["default_option"]
            option.attr("selected", "selected")
          field.append(option)
      else
        error "Unrecognized type: #{params["type"]}"
        return

    field.attr("id", field_id)

    if params["name"]?
      field.attr("name", "#{prefix}_#{params["name"]}")

    params["bind"] = params["bind"] || {}
    for event_type, event of params["bind"]
      field.unbind(event_type).bind(event_type, event)

    if params["sync"]?
      if params["type"] not in Question.syncTypes
        error "cannot sync type #{params["type"]}"
        return

    parent_element.append(field)

    @fields[params["id"]] = params
    @fields[params["id"]]["field"] = field
    @fields[params["id"]]["subfields"] = []

    if params["sync"]?
      @bindSync(params["id"], params["sync"])


    return field

  getField: (field_id) ->
    if @["fields"]? and @fields[field_id]? then @fields[field_id]["field"] else undefined

  
class StandardQuestion extends Question

  abstract: true

  constructor: (params) ->
    super(params)

    @data["score"] = @data["score"] || "1"
    @data["description"] = @data["description"]
    @data["explanation"] = @data["explanation"]

  buildCustomPreviewFields: ->
    @abstractmethod("buildCustomPreviewFields")

  buildCustomInputFields: ->
    @abstractmethod("buildCustomInputFields")

  buildCustomFields: ->
    @abstractmethod("buildCustomFields")

  updateCustomData: ->
    @abstractmethod("updateCustomData")

  updateData: ->
    if @isInputBuilt
      @data["description"] = @getFieldData("description") || ""
      @data["explanation"] = @getFieldData("explanation") || ""
      @data["score"] = @getFieldData("score") || "1"
      @data["title"] = @getFieldData("title") || ""
      @updateCustomData()

  doneEdit: ->
    @getField("edit").css "display", "none"
    @getField("btn_edit").css "display", "inline"
    @getPreviewField("preview_label").hide()

  restoreEdit: ->
    for elem in QuestionEditor.getElements()
      if elem and elem["doneEdit"]? and elem.element_id != @element_id
        elem.doneEdit()
    @getField("edit").css "display", "block"
    @getField("btn_edit").css "display", "none"
    @getPreviewField("preview_label").show()

  buildPreviewFields: (preview) ->

    preview_label = @addPreviewField
      id: "preview_label"
      type: "div"
      attrs:
        class: "preview_label"
      parent_element: preview

    question = @addPreviewField
      id: "question"
      type: "div"
      attrs:
        class: "question"
      parent_element: preview

    @addPreviewField
      id: "header"
      type: "h2"
      attrs:
        class: "header"
      parent_element: question
      renderer: (elem, field) =>
        data = elem.getData()
        pointString = if data["score"] == "1" then "point" else "points"
        data["title"] = data["title"].strip() if data["title"]
        title = if data["title"]? and data["title"] != "" then data["title"] else null
        if @parent?
          if (@parent instanceof Assignment)
            sectionName = if title? then "#{title}: Question" else "Question"
          else
            sectionName = if title? then "#{title}: Part" else "Part"
        else
          sectionName = if title? then "#{title}" else ""
        field.html("#{sectionName} #{elem.section}")

    text_mathjax_delay = new MathJaxDelayRenderer()
    @addPreviewField
      id: "text"
      attrs:
        class: "text"
      renderer: (elem, field, delay) ->
        if not delay?
          delay = true
        text_mathjax_delay.render
          element: field
          text: elem.getData "description"
          preprocessor: QuestionEditor.rendermd
          delay: delay
      parent_element: question

    @buildCustomPreviewFields(question)

    explanation_mathjax_delay = new MathJaxDelayRenderer()
    @addPreviewField
      id: "explanation"
      parent_element: question
      renderer: (elem, field, delay) ->
        if not delay?
          delay = true
        explanation = elem.getData "explanation"
        if explanation? and explanation != ""
          field.attr("class", "explanation")
          explanation_mathjax_delay.render
            element: field
            text: explanation
            preprocessor: QuestionEditor.rendermd
            delay: delay
        else
          field.attr("class", "")


  buildInputFields: ->

    @preview = @addField
      id: "preview"
      type: "div"
      attrs:
        class: "preview quick_preview"

    @addField
      id: "btn_edit"
      type: "button"
      html: "Edit"
      attrs:
        class: "btn btn_edit"
        style: "display:none"
      bind:
        click: =>
          @restoreEdit()

    edit = @addField
      id: "edit"
      type: "div"
      attrs:
        class: "element_edit active"

    @addField
      id: "section"
      type: "div"
      attrs:
        class: "section"
      parent_element: edit

    @addField
      id: "title"
      type: "input_text"
      sync: "header"
      label: "Title"
      data: @data["title"]
      attrs:
        class: "title"
        placeholder: "Title your question (optional)"
      parent_element: edit

    @addField
      id: "select_type"
      type: "select"
      label: "Question Type"
      attrs:
        class: "select_type"
      options: QuestionEditor.getQuestionOptions()
      default_option: @questionType
      bind:
        change: =>
          @updateFieldData "select_type"
          QuestionEditor.transformElement @element_id, @getFieldData("select_type")

      parent_element: edit

    @addField
      id: "score"
      type: "input_text"
      sync: "header"
      label: "Points"
      data: @data["score"]
      attrs:
        class: "points score"
      parent_element: edit

    @addField
      id: "description"
      type: "textarea"
      sync: "text"
      label: "Text"
      data: @data["description"]
      wrapper:
        attrs:
          class: "text_wrapper"
      attrs:
        rows: "3"
      parent_element: edit

    @addField
      id: "explanation"
      type: "textarea"
      sync: "explanation"
      label: "Explanation"
      data: @data["explanation"]
      wrapper:
        attrs:
          class: "explanation_wrapper"
      attrs:
        rows: "3"
      parent_element: edit


    @buildCustomInputFields(edit)

    button_container = @addField
      id: "button_container"
      type: "div"
      attrs:
        class: "button_container"
      parent_element: edit

    if QuestionEditor.config.editorType != "Question"
      @addField
        id: "btn_delete"
        type: "button"
        html: "Delete Question"
        attrs:
          class: "btn btn_delete"
        parent_element: button_container
        bind:
          click: =>
            QuestionEditor.deleteQuestion @element_id

    @addField
      id: "btn_done"
      type: "button"
      html: "Preview"
      attrs:
        class: "btn btn_done"
      parent_element: button_container
      bind:
        click: =>
          @doneEdit()
          
root = exports ? this
root.Question = Question
root.StandardQuestion = StandardQuestion
