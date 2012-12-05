# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

#= require mathjax_delay_renderer.js
#= require json2.js
#= require sprintf.js
#= require xregexp-min.js
#= require question_editor/question_editor.js
#= require question_editor/question.js
#= require question_editor/assignment.js
#= require question_editor/question_group.js
#= require question_editor/simple_choice_question.js
#= require question_editor/custom_html_choice_question.js
#= require question_editor/freeform_questions

class QuestionSearcher

  constructor: (@inputSelector, \
                @resultsListSelector, \
                @selectQuestionCallback=null, \
                @hidePreviewCallback=null) ->

    @inputField   = $(inputSelector)
    @resultsList  = $(resultsListSelector)

    @prevKey = ""
    @existingRequest = null
    @existingRequestRunning = false

    @cachedPreviews = []
    
    @url = @inputField.attr("data-search-url")

    @inputField.keyup @search

    # Disable the enter key (otherwise it'd submit the form
    @inputField.keypress (e) ->
      code = e.keyCode || e.which
      if code == 13
        e.preventDefault()
    
    @inputField.focus =>
      @reset()

    @initSelect()

  reset: ->
    @hidePreviewCallback() if @hidePreviewCallback?
    @resultsList.show()
    $("#question_preview").hide()

  # Used as a callback, so need fat arrow.
  getText: (id, callback) =>
    if @cachedPreviews[id]?
      callback(@cachedPreviews[id])
    else
      #FIXME make this a data attr on something meaningful
      url = $("#question_search").attr("data-question-source") + "/" + id + "?show_delete=true"
      $.get url, (data) =>
        @cachedPreviews[id] = data
        callback(@cachedPreviews[id])

  getQuestionId: (elementId) ->
    if elementId.lastIndexOf('_') >= 0
      return parseInt(elementId.substr(elementId.lastIndexOf('_') + 1))
    return parseInt(elementId.substr(elementId.lastIndexOf('/') + 1))

  # Fat arrow because used as callback
  search: (force=false, callback=null) =>

    searchKey = @inputField.val()

    return if not force and (searchKey == prevKey)

    prevKey = searchKey

    if @existingRequestRunning
      @existingRequest.abort()

    # Fat arrow because uses QuestionSearcher instance variables inside callback
    @existingRequest = $.get "#{@url}#{escape(searchKey)}", (data) =>
      @resultsList.html(data)
      MathJax.Hub.Queue(["Typeset", MathJax.Hub, @resultsList.prop('id')])
      @initSelect()
      @existingRequestRunning = false
      callback() if callback?

  # Fat arrow because used as callback
  initSelect: () =>

    # Fat arrow since instance methods are used inside callback
    $(".question_item").click (e) =>

      # Because the children of the question_item might be the click's target,
      # we use the delegateTarget to access the .question_item to which the
      # event was attached.
      clickedQuestion = e.delegateTarget

      qid = @getQuestionId clickedQuestion.id

      if not $(clickedQuestion).hasClass("question_item_selected")
        $(".question_item").removeClass("question_item_selected")
        $(clickedQuestion).addClass("question_item_selected")

        @getText qid, (text) =>

          $("#question_preview").html(text)
          MathJax.Hub.Queue(["Typeset", MathJax.Hub, "question_preview"])
          $("#question_preview").show()

site = window.site
site.questions = new Object

addError = (errorMsg) ->
  if $("#error_list").length
    $("#error_list").append("<li>#{errorMsg}</li>")
  else
    errorDiv = $('<div>').attr('id', "errors").addClass("message")
    errorDiv.html("<ul id='error_list'><li>#{errorMsg}</li></ul>")
    $("form").before(errorDiv)
  window.scrollTo 0, 0

site.questions.new = ->
  config =
    onSubmitSuccess: (data, textStatus) ->
      window.location.href = data.redirectURL
    onSubmitError: (xhr, textStatus) ->
      addError(xhr.responseText)
      console.log "added post error:"
      console.log xhr.responseText
      $(this).removeAttr('disabled')
  QuestionEditor.init $(".question_editor"), config

site.questions.index = ->
  @searchFieldId    = "#search_key"
  @searchResultsId  = "#search_results"

  questionSearcherSelect = (qid) ->
    questionSearcher.getText qid, (text) =>
      $("#question_preview").html(text)

  questionSearcher = new QuestionSearcher( @searchFieldId,
    @searchResultsId,
    questionSearcherSelect,
    -> )
