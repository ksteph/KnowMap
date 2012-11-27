# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

site = window.site
site.assignments = new Object

site.assignments.init = ->

site.assignments.show = ->

  $(".submissions > ul").hide()

  $(".submission_link").click ->
    $(this).siblings('ul').toggle()

  $(".discussion > ul").hide()

  $(".discussion_link").click ->
    $(this).siblings('ul').toggle()

  timers = []

  $(".question_time_left_seconds").each (i, elt) =>
    time_left = $(elt).val()
    return if time_left == 0 or time_left == undefined
    $(elt).addClass('notice')
    $timer_elt = $(elt).parents('.question')
                      .find('.resubmit_timer')
    timers.push(new window.Timer($timer_elt, time_left).start())



site.assignments.new = ->

  question_preview = []
  question_added = []

  request = null
  runningRequest = false
  prevKey = ""

  getQid = (id) ->
    if id.lastIndexOf('_') >= 0
      return parseInt(id.substr( id.lastIndexOf('_') + 1))
    return parseInt(id.substr( id.lastIndexOf('/') + 1))


  if not $("#assignment_preview").length
    $("<div>").attr("id", "assignment_preview").insertAfter($("#assignment_form"))

  initSelect = ->
    $(".question_item").click ->
      $("#add_question").css("display", "inline")
      if not $(this).hasClass("question_item_selected")
        $(".question_item").removeClass("question_item_selected")
        $(this).addClass("question_item_selected")
        qid = getQid this.id
        if question_preview[qid]?
          $("#question_preview").html(question_preview[qid])
          #$("#question_preview").prepend($("<p><label>Question-specific Resubmit Delay (overrides assignment delay for this question)</label><input type='text' id='question_resubmit_delay'></input></p>"))
          $("#question_preview").prepend($("<input type='hidden' id='question_resubmit_delay'></input>"))
          MathJax.Hub.Queue(["Typeset", MathJax.Hub, "question_preview"])
        else
          $.get $(this).attr("data-url") + "?show_points=true", (data) =>
            $("#question_preview").html(data)
            #$("#question_preview").prepend($("<p><label>Resubmit Delay (seconds)</label><input type='text' id='question_resubmit_delay'></input></p>"))
            $("#question_preview").prepend($("<input type='hidden' id='question_resubmit_delay'></input>"))
            question_preview[qid] = data
            MathJax.Hub.Queue(["Typeset", MathJax.Hub, "question_preview"])

  initSelect()

  updateSearch = (params) ->
    params = params || {}
    force = params["force"] || false
    callback = params["callback"]
    search_key = $("#search_key").val()
    if not force and search_key == prevKey
      return
    prevKey = search_key
    if runningRequest
      request.abort()
    runningRequest = true
    search_url = $(".question_list").attr("search_url")
    request = $("#question_id").load "#{search_url}#{search_key}", ->
      $(".question_item").each ->
        if getQid(this.id) in question_added
          $(this).remove()
      MathJax.Hub.Queue(["Typeset", MathJax.Hub])
      initSelect()
      runningRequest = false
      if callback
        callback()

  $("#search_key").keyup updateSearch
  $("#search_key").keypress (e) ->
    code = e.keyCode || e.which
    if code == 13
      e.preventDefault()
      updateSearch()
  $("#btn_search_question").click updateSearch

  delete_assignment_entry = (event) ->
    question = $(event.target).closest(".question_list_item")
    qid = getQid question.attr("id")
    question.remove()
    question_added.splice question_added.indexOf(qid), 1
    id = question.attr("id")
    qid = id.slice(id.length - 1, id.length)
    removeHiddensFor(qid)
    updateSearch
      force: true

  $(".delete_assignment_entry").click(delete_assignment_entry)

  createQuestionListItem = (qid, resubmitDelay) ->
    questionHtml = "<li id=\"question_ids_#{qid}\" url=\"#{$("#question_#{qid}").attr("url")}\" class=\"question_list_item\">" + $("#question_#{qid}").html()
    #if resubmitDelay?
    #  questionHtml += " (Resubmit delay #{resubmitDelay} seconds)"
    questionHtml += "</li>"
    deleteButton = $("<a>").attr("href", "javascript:void(0)").addClass("btn").html("Remove").click(delete_assignment_entry)
    buttonContainer = $(document.createElement("div")).addClass("button_container").append(deleteButton)
    $(questionHtml).append(buttonContainer)


  removeHiddensFor = (qid) ->
    $("form input[data-question-id='#{qid}']").remove()

  addHiddensFor = (qid, resubmitDelay, questionIndex) ->
    form = $('form')
    form.append("<input type='hidden' name='assignment[entries_attributes][#{questionIndex}][question_id]' id='assignment_entries_#{questionIndex}_question_id' data-question-id=#{qid} value='#{qid}'/>")
    if resubmitDelay and resubmitDelay != ""
      form.append("<input type='hidden' name='assignment[entries_attributes][#{questionIndex}][resubmit_delay]' id='assignment_entries_#{questionIndex}_resubmit_delay' data-question-id=#{qid} value='#{resubmitDelay}'/>")

  addQuestion = ->
    questionIndex = 0
    (qid, resubmitDelay = 0) ->
      return if not $("#question_ids_#{qid}").length
        question = createQuestionListItem(qid, resubmitDelay)
        $('#selected_questions').append(question)

        addHiddensFor(qid, resubmitDelay, questionIndex)
        questionIndex += 1

        question_added.push qid

        question_div = $("<div>").attr("id", "assignment_preview_question_#{qid}").addClass("assignment_preview_question").appendTo($("#assignment_preview"))
        if question_preview[qid]?
          question_div.html(question_preview[qid])
          MathJax.Hub.Queue(["Typeset", MathJax.Hub, question_div.attr("id")])
        else
          $.get $("#question_#{qid}").attr("data-url"), (data) =>
            question_div.html(data)
            question_preview[qid] = data
            MathJax.Hub.Queue(["Typeset", MathJax.Hub, question_div.attr("id")])
        $("#question_#{qid}").remove()

  addQuestion = addQuestion()

  current_assignment_id = ->
    window.location.match(/assignments\/(\d+)/)[0]

  initSelectedQuestions = ->
    question_ids = $.unique(
      $("[data-question-id]").map((i, elt) =>
        $(elt).attr("data-question-id")
      )
    )
    for qid in question_ids
      addQuestion qid

  changed = (event, ui) ->
    old_ids = []
    $(".assignment_preview_question").each ->
      old_ids.push getQid this.id
    new_ids = []
    $("#selected_questions>li").each ->
      new_ids.push getQid this.id
    len = new_ids.length
    changed_index = null
    for index in [0...len]
      old_index = old_ids.indexOf(new_ids[index])
      new_slice = new_ids.slice(0, index).concat(new_ids.slice(index + 1, len))
      old_slice = old_ids.slice(0, old_index).concat(old_ids.slice(old_index + 1, len))
      if not (new_slice < old_slice or new_slice > old_slice)
        changed_index = index
        break
    qid = new_ids[index]
    if index == 0
      old_element = $("#assignment_preview_question_#{qid}")
      old_element.prependTo($("#assignment_preview"))
    else
      prev_qid = new_ids[index - 1]
      old_element = $("#assignment_preview_question_#{qid}")
      old_element.insertAfter($("#assignment_preview_question_#{prev_qid}"))

  $( "#selected_questions" ).sortable
    update: changed
    sort: -> # fix of sortable numbering according to the discussion at
             # http://forum.jquery.com/topic/sortable-ol-elements-don-t-display-numbers-properly
             # and the code at http://jsfiddle.net/cP4Fx/3/
      $lis = $(this).children('li')
      $lis.each ->
        $li = $(this)
        hindex = $lis.filter('.ui-sortable-helper').index()
        if !$li.is('.ui-sortable-helper')
          index = $li.index()
          index = if index < hindex then index + 1 else index
          $li.val(index)
          if $li.is('.ui-sortable-placeholder')
            $lis.filter('.ui-sortable-helper').val(index)
  $( "#selected_questions" ).disableSelection()
  initSelectedQuestions()

  $('#add_question').css("display", "none").click (event) ->
    event.preventDefault()
    selected = $(".question_item_selected")
    if selected.length
      qid = getQid selected.attr("id")
      resubmitDelay = $("#question_resubmit_delay").val()
      addQuestion(qid, resubmitDelay)
      $("#question_preview").html("")
      $(this).css("display", "none")

  $('#create_new_question').click (event) ->

    if $(this).text() == "Cancel"
      $(this).text("Create New Question")
    else
      $(this).text("Cancel")

    event.preventDefault()
    if $(this).attr("created")
      if $(this).attr("appeared")
        $(".question_editor").hide()
        $("#save_new_question").hide()
        $(this).removeAttr("appeared")
      else
        $(".question_editor").show()
        $("#save_new_question").show()
        $(this).attr("appeared", "appeared")
    else
      courseId = $(this).attr('data-course-id')
      config =
        submitId : "save_new_question"
        formPath : "/courses/#{courseId}/questions"
        embedded : true
        onSubmitSuccess : (data, textStatus) =>
          $('#create_new_question').text("Create New Question")
          qid = parseInt(data["id"])
          $(".question_editor").empty()
          $("#save_new_question").hide()
          $(this).removeAttr("created")
          $(this).removeAttr("appeared")
          if !$("#question_editor_message").length
            $("#content_container").prepend('<div class="alert alert-success" id="question_editor_message">Your question was successfully saved.</div>')
          else
            $("#question_editor_message").html("Your question was successfully saved.")
          $('html, body').animate({ scrollTop: '0px'}, 'fast')
          updateSearch
            force: true
            callback: ->
              addQuestion qid

        onSubmitError: (xhr, textStatus) =>
          if !$("#question_editor_message").length
            $("#content_container").prepend('<div class="alert alert-error" id="question_editor_message">Your question was not saved.</div>')
          else
            $("#question_editor_message").html("Your question was not saved.")
          $('html, body').animate({ scrollTop: $("#question_editor_message").offset().top + 'px'}, 'fast')
          console.log "added post error:"
          console.log xhr.responseText
      QuestionEditor.init $(".question_editor"), config
      $(this).attr("created", "created")
      $(this).attr("appeared", "appeared")
      $("#save_new_question").show()

site.assignments.edit   = site.assignments.new
site.assignments.create = site.assignments.new

