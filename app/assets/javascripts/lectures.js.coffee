# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

draw_chart = (data, labels, selector, options) ->
  
  options = options ? {}
  height = options["height"] ? 100
  bottomMargin = options["bottommargin"] ? 80
  topMargin = options["topmargin"] ? 80

  extraHeight = 50

  barWidth = 30

  width = (barWidth + 30) * data.length

  x = d3.scale.linear().domain([0, data.length]).range([0,width])
  y = d3.scale.linear().domain([0, d3.max(data)]).range([0,width]).rangeRound([0, height])

  chart = d3.select(selector).append("svg:svg")
    .attr("width", width)
    .attr("height", height+extraHeight)
    .attr("preserveAspectRatio","xMidYMid")

  chart.selectAll("rect")
    .data(data)
    .enter()
    .append("svg:rect")
      .attr("width", barWidth)
      .attr("x", (d, i) -> return x(i) + 20)
      .attr("y", (d) -> return extraHeight/2 + height - y(d))
      .attr("height", (d) -> return y(d))
      .attr("fill", "rgba(34,68,204,1)")
      #.attr("stroke", "rgba(0,80,240,1.0)")
      #.attr("stroke-width", 0)

  chart.selectAll("text")
    .data(data)
    .enter()
    .append("svg:text")
    .attr("x", (d,i) -> x(i) + barWidth + 20)
    .attr("y", (datum) => 5 + height - y(datum))
    .attr("dx", -barWidth/2)
    .attr("dy", "1.2em")
    .attr("text-anchor", "middle")
    .text((datum) -> (datum))
    .attr("fill", "black")
  
  chart.selectAll("text.yAxis").
    data(data).
    enter().append("svg:text").
    attr("x", (d, i) -> x(i) + barWidth + 20).
    attr("y", height + extraHeight - 10).
    attr("dx", -barWidth/2).
    attr("text-anchor", "middle").
    attr("style", "font-size: 12; font-family: Helvetica, sans-serif").
    text((d, i) -> labels[i].toString()).
    attr("class", "yAxis")

site = window.site
site.lectures = new Object

site.lectures.new = ->

  lectureEditor = new LectureEditor

  initYouTubeAPI(lectureEditor.onPlayerReady, 
                 lectureEditor.onPlayerStateChange, 
                 lectureEditor.onPlayerError)


site.lectures.create = site.lectures.new
site.lectures.edit   = site.lectures.new
site.lectures.update = site.lectures.edit

site.lectures.show = ->

  lectureViewer = new LectureViewer

  initYouTubeAPI(lectureViewer.onPlayerReady, 
                 lectureViewer.onPlayerStateChange, 
                 lectureViewer.onPlayerError)

secondsToHoursMinutesSeconds = (seconds) ->
  date    = new Date(seconds*1000)
  hours   = date.getUTCHours()
  minutes = date.getUTCMinutes()
  seconds = date.getUTCSeconds()

  return [hours, minutes, seconds]
    
class InLectureQuestion

  # timeInSeconds is the total time converted to seconds; it's not the number
  # of seconds in the total time (i.e. timeInSeconds can be greater than 60)
  constructor: (@id, @timeInSeconds, @text, @youtube, @markerClickedCallback) ->
    @idPrefix   = 'lecture_in_lecture_questions_attributes_'
    @namePrefix = 'lecture[in_lecture_questions_attributes]['
    @fieldIndex = (new Date).getTime()
    @persisted  = false

    @status     = "unanswered"

    @createMarker()

  createMarker: ->
    @marker = $(document.createElement('div'))
    @marker.attr('id', "question_marker_#{@id}")
    @marker.addClass('question_marker')
    @marker.addClass(@status)
    @marker.attr('title', 'Question')
    @marker.click =>
      if @markerClickedCallback?
        @markerClickedCallback(@id)

  activate: ->
    @marker.removeClass(@status)
    @status = "active"
    @marker.addClass(@status)

  skip: ->
    @marker.removeClass(@status)
    @status = "skipped"
    @marker.addClass(@status)

  submit: (correct) ->
    @marker.removeClass(@status)
    @status = if correct then "correct" else "incorrect"
    @marker.addClass(@status)

  destroy: ->
    @destroyMarker()
    @destroyFormFields()

  destroyMarker: ->
    @marker.remove()

  complete: ->
    return @status != "unanswered" and @status != "active"

  updateMarkerPosition: ->
    positionPercentage = (@timeInSeconds / @youtube.getDuration()) * 100
    positionPercentage = Math.min 100, positionPercentage
    @marker.css('left', positionPercentage + '%')

  timeString: ->
    time = moment(new Date(1000*@timeInSeconds))
    [hours, minutes, seconds] = secondsToHoursMinutesSeconds(@timeInSeconds)
    if hours > 0
      return time.format("h:mm:ss")
    else
      return time.format("m:ss")

  toIndexEntry: (index) ->
    item = $(document.createElement("li"))
    link = $(document.createElement("a")).addClass("question_index_link")
    link.attr("data-id", "#{@id}")
    link.attr("href", "javascript:void(0);")
    link.html("Question #{index+1}: #{@timeString()}")
    item.append(link)
    return item

  @fromFormFields: (container, textCallback, youtube, markerClickedCallback) ->
    idPrefix   = 'lecture_in_lecture_questions_attributes_'
    namePrefix = 'lecture[in_lecture_questions_attributes]['

    containerId = container.attr("id")
    fieldIndex = parseInt(containerId.substr(containerId.lastIndexOf("_")+1))

    id   = parseInt(container.find("#" + idPrefix + fieldIndex + '_question_id').val())

    hours   = parseInt(container.find("#" + idPrefix + fieldIndex + '_hours').val())
    minutes = parseInt(container.find("#" + idPrefix + fieldIndex + '_minutes').val())
    seconds = parseInt(container.find("#" + idPrefix + fieldIndex + '_seconds').val())

    timeInSeconds = hours * 3600 + minutes * 60 + seconds

    question = new InLectureQuestion( id, 
                                      timeInSeconds, 
                                      "", 
                                      youtube, 
                                      markerClickedCallback)

    question.fieldIndex = fieldIndex

    if $("#" + idPrefix + fieldIndex + "_id").length > 0
      question.persisted = true

    textCallback id, (text) =>
      question.text = text

    return question
  
  updateTime: (time) ->
    if time != @timeInSeconds
      oldTime = @timeInSeconds
      @timeInSeconds = time
      [hours, minutes, seconds] = secondsToHoursMinutesSeconds(@timeInSeconds)

      console.log @idPrefix + @fieldIndex + '_hours'

      $('#' + @idPrefix + @fieldIndex + '_hours').val(hours)
      $('#' + @idPrefix + @fieldIndex + '_minutes').val(minutes)
      $('#' + @idPrefix + @fieldIndex + '_seconds').val(seconds)

      if Math.abs(time - oldTime) > .1
        @updateMarkerPosition()

  createFormFields: ->

    [hours, minutes, seconds] = secondsToHoursMinutesSeconds(@timeInSeconds)

    container = $(document.createElement('div'))
    container.addClass('in_lecture_question')
    container.attr('id', "in_lecture_question_#{@fieldIndex}")
    $("#question_list").append(container)

    inputElement = document.createElement('input')
    $(inputElement).attr('type', 'hidden')
    $(inputElement).attr('id', @idPrefix + @fieldIndex + '_question_id')
    $(inputElement).attr('name', @namePrefix + @fieldIndex + '][question_id]')
    $(inputElement).attr('value', @id)
    $(inputElement).appendTo(container)

    inputElement = document.createElement('input')
    $(inputElement).attr('type', 'hidden')
    $(inputElement).attr('id', @idPrefix + @fieldIndex + '_hours')
    $(inputElement).attr('name', @namePrefix + @fieldIndex  + '][hours]')
    $(inputElement).attr('value', hours)
    $(inputElement).appendTo(container)

    inputElement = document.createElement('input')
    $(inputElement).attr('type', 'hidden')
    $(inputElement).attr('id', @idPrefix + @fieldIndex + '_minutes')
    $(inputElement).attr('name', @namePrefix + @fieldIndex + '][minutes]')
    $(inputElement).attr('value', minutes)
    $(inputElement).appendTo(container)

    inputElement = document.createElement('input')
    $(inputElement).attr('type', 'hidden')
    $(inputElement).attr('id', @idPrefix + @fieldIndex + '_seconds')
    $(inputElement).attr('name', @namePrefix + @fieldIndex + '][seconds]')
    $(inputElement).attr('value', seconds)
    $(inputElement).appendTo(container)

  destroyFormFields: ->
    if @persisted
      $("#" + @idPrefix + @fieldIndex + "__destroy").val(1)
    else
      $("#in_lecture_question_#{@fieldIndex}").remove()

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
      url = $("#question_list").attr("data-question-source") + "/" + id
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
      MathJax.Hub.Queue(["Typeset", MathJax.Hub, @resultsListSelector])
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

      $("#search_results").hide()

      qid = @getQuestionId clickedQuestion.id

      if not $(clickedQuestion).hasClass("question_item_selected")
        #$(".question_item").removeClass("question_item_selected")
        #$(clickedQuestion).addClass("question_item_selected")

        @getText qid, (text) =>

          $("#question_preview").html(text)
          MathJax.Hub.Queue(["Typeset", MathJax.Hub, "question_preview"])
          $("#question_preview").show()

        if @selectQuestionCallback?
          @selectQuestionCallback(qid)

initYouTubeAPI = (onPlayerReady, \
                  onPlayerStateChange, \
                  onPlayerError) ->

  tag     = document.createElement("script")
  tag.src = "https://www.youtube.com/player_api"
  firstScriptTag = document.getElementsByTagName("script")[0]
  firstScriptTag.parentNode.insertBefore tag, firstScriptTag

  window.onYouTubePlayerAPIReady = ->
    params = 
      width: "100%"
      events:
        onReady: onPlayerReady
        onStateChange: onPlayerStateChange
        onError: onPlayerError
      playerVars:
        wmode: "opaque" # This makes the player obey z-index
        color: "white"
        theme: "light"
        rel: 0
        html5: 1

    site.lectures.player = new YT.Player("player", params)

site.lectures.init = ->

class LectureEditor

  constructor: (params = {}) ->

    # These are for the question searcher, so we'll allow changing them
    @previewId        = params["previewId"]       ? "#question_preview"
    @searchFieldId    = params["searchFieldId"]   ? "#search_key"
    @searchResultsId  = params["searchResultsId"] ? "#search_results"

    @urlInput                 = $("#lecture_video_url")
    @addButton                = $("#add_question")
    @newButton                = $("#new_question")
    @removeButton             = $("#remove_question")
    @backButton               = $("#back")
    @addedQuestionList        = $("#added_questions")
    @hintWithVideo            = $("#hint_with_video")
    @hintWithoutVideo         = $("#hint_without_video")
    @questionIndex            = $("#question_index")
    @questionTime             = $("#question_time")
    @questionSearch           = $("#question_search")
    @questionSearchResults    = $("#search_results")
    @questionSearchFields     = $("#question_search_fields")
    @questionPreview          = $("#question_preview")
    @questionPlaceholder      = $("#question_placeholder")
    @questionPlaceholderText  = $("#question_placeholder > .placeholder_text")
    @player                   = $("#player")
    @playerPlaceholder        = $("#player_placeholder")
    @playerPlaceholderText    = $("#player_placeholder > .placeholder_text > p")
    @questionTimeline         = $("#question_timeline")

    @questionSearcher = new QuestionSearcher( @searchFieldId, 
                                              @searchResultsId,
                                              @questionSearcherSelect,
                                              @questionSearcherReset)

    @playerReady  = false
    @urlInvalid   = false
    @videoId      = null
    @questions    = []
    @question_ids = []

    @urlInput.bind "input paste keypress", =>
      @updateVideoId()

    @hidePlayer()
    @gotoInitialState()

    @addButton.click =>
      @youtube.pauseVideo()
      @gotoSearchState()

  loadExistingQuestions: () ->
    $('.in_lecture_question').each (index, el) =>
      container = $(el)

      question = InLectureQuestion.fromFormFields(container,
                                                  @questionSearcher.getText,
                                                  @youtube,
                                                  @markerClicked)

      # We don't append the markers here because the video may not yet
      # be loaded. This happens in onPlayerStateChange callback.

      @questions.push question
      @question_ids.push question.id

    if @questions.length > 0
      @gotoAddState()

  questionSearcherSelect: (qid) =>

    @questionSearchFields.hide()
    index = @question_ids.indexOf(qid)

    if index == -1
      timeInSeconds = @youtube.getCurrentTime()
      @questionSearcher.getText qid, (text) =>
        @createInLectureQuestion(qid, timeInSeconds, text)
        @gotoViewState(qid)
    else
      @gotoViewState(qid)

  questionSearcherReset: =>
    @backButton.show()
    @backButton.unbind().click =>
      @gotoAddState()

  updateVideoId: ->
    return unless @playerReady
    url = @urlInput.val().strip()

    watchRegex = /^.*youtube.com\/.*watch\?v=([^&]+).*/i
    embedRegex = /^.*youtube.com\/embed\/([^&]+).*/i

    match = watchRegex.exec(url)
    newVideoId = match[1] if match?
    
    unless newVideoId?
      match = embedRegex.exec(url)
      newVideoId = match[1] if match?

    if newVideoId? and newVideoId != @videoId
      @videoId = newVideoId
      if @videoId.length == 11
        @playerPlaceholderText.html("Loading your video...")
        @youtube.loadVideoById(@videoId)
        @urlInvalid = false
        @playerPlaceholderText.removeClass("invalid")
      else
        @youtube.pauseVideo()
        @urlInvalid = true
        @hidePlayer()

  createInLectureQuestion: (id, timeInSeconds, text) ->
    timeInSeconds = Math.floor(timeInSeconds)
    question = new InLectureQuestion(id, 
                                     timeInSeconds, 
                                     text, 
                                     @youtube,
                                     @markerClicked)
    question.createFormFields()
    @questionTimeline.append(question.marker)
    question.updateMarkerPosition()
    @questions.push question
    @question_ids.push id

  markerClicked: (id) =>
    @gotoViewState(id)

  showPlayer: ->

    @playerPlaceholder.hide()
    @player.css("visibility", "")
    @player.css("width", "100%")
    @player.css("height", "")

    # When we show the player, expand both placeholders to have the same height.
    # To do so, we need to take the borders into account.
    borderHeight  = @playerPlaceholder.outerHeight() - 
                    @playerPlaceholder.innerHeight()
    desiredHeight = @player.height()-borderHeight
    $(@searchResultsId).css('max-height', desiredHeight - 100)
    @playerPlaceholder.css('min-height', desiredHeight)
    @questionPlaceholder.css('min-height', desiredHeight)

  hidePlayer: ->

    @playerPlaceholder.show()
    @player.css("visibility", "hidden")
    @player.css("width", "1px")
    @player.css("height", "1px")

    if @urlInvalid
      @playerPlaceholderText.addClass("invalid")
      @playerPlaceholderText.html("Your YouTube link is invalid.")
    else
      @playerPlaceholderText.removeClass("invalid")
      @playerPlaceholderText.html("Your video will appear here.")

  # Used in setInterval so need fat arrow
  updateTimeDisplay: =>
    currentTime = @youtube.getCurrentTime()
    return if isNaN(currentTime)
    time = moment(new Date(1000*currentTime))
    [hours, minutes, seconds] = secondsToHoursMinutesSeconds(currentTime)
    if hours > 0
      @timeString = time.format("h:mm:ss")
    else
      @timeString = time.format("m:ss")

    @addButton.html("Add Question at #{@timeString}")

  onPlayerReady: (event) =>

    @playerReady = true

    # Store the player object after it's been created.
    @youtube = site.lectures.player

    # Need to reset @player because YouTube replaces the div
    @player = $("#player")

    @urlInvalid = false
    @hidePlayer()
    @updateVideoId()

    # We load here, because we need to pass the player as an argument when
    # creating the questions (therefore we need to wait for the player to be
    # ready)
    @loadExistingQuestions()

  onPlayerStateChange: (event) =>
    switch event.data
      when -1
        ->
        # Means unstarted; don't need to do anything here, yet.
      when YT.PlayerState.BUFFERING
        # Update marker positions here because the video may not have been
        # loaded at the beginning.
        for question in @questions
          @questionTimeline.append(question.marker)
          question.updateMarkerPosition()
        @urlInvalid = false
        @showPlayer()
        if @state == "init"
          @gotoAddState()
      when YT.PlayerState.PLAYING
        @updateTimeDisplayInterval = setInterval @updateTimeDisplay, 100
      when YT.PlayerState.PAUSED
        ->
        #Don't do anything when paused, yet..

  onPlayerError: (event) =>
    @urlInvalid = true
    @hidePlayer()
    clearInterval @updateTimeDisplayInterval

  gotoInitialState: ->

    @state = "init"

    @playerPlaceholderText.html("Initializing YouTube...")

    @hintWithVideo.hide()
    @hintWithoutVideo.show()

    @addButton.hide()
    @newButton.hide()
    @backButton.hide()
    @questionSearch.hide()
    @questionTime.hide()
    @questionPlaceholder.show()

  gotoAddState: ->

    clearInterval @questionTimeUpdatePollerInterval

    @state = "add"
    @questionIndex.show()

    @questionTime.hide()
    @questionSearch.hide()
    @hintWithoutVideo.hide()

    @addedQuestionList.empty()

    if @questions.length == 0
      @questionPlaceholderText.show()
      @hintWithVideo.show()
    else
      @questionPlaceholderText.hide()
      sortedQuestions = @questions.slice(0)
      sortedQuestions.sort( (a,b) -> a.timeInSeconds - b.timeInSeconds)

      title = $(document.createElement("li"))
      title.text("Scheduled Questions")
      @addedQuestionList.append(title)

      for question, index in sortedQuestions
        @addedQuestionList.append($(document.createElement("hr")))
        @addedQuestionList.append(question.toIndexEntry(index))
        $(".question_index_link").click (event) =>
          target = $(event.delegateTarget)
          id = parseInt(target.attr("data-id"))
          @gotoViewState(id)
      @addedQuestionList.show()

    @addButton.show()
    @newButton.show()

  gotoSearchState: ->

    @state = "search"

    @questionTime.hide()
    @questionPlaceholderText.hide()
    @hintWithoutVideo.hide()
    @hintWithVideo.hide()
    @addButton.hide()
    @removeButton.hide()
    @questionIndex.hide()

    @questionSearcher.reset()
    @questionSearch.show()
    @questionSearchFields.show()
    @backButton.show()
    @newButton.show()

    @backButton.click =>
      @questionSearcher.reset()

  questionTimeUpdatePoller: (question) =>
    @timeUpdateCount = 0
    =>
      if @timeUpdateCount < 2
        @timeUpdateCount = @timeUpdateCount + 1
      else
        currentTime = @youtube.getCurrentTime()
        if question.timeInSeconds != currentTime
          question.updateTime(currentTime)
          @questionTime.text("This question will appear at #{question.timeString()}")

  gotoViewState: (qid) ->

    clearInterval @questionTimeUpdatePollerInterval

    @state = "view"

    @questionSearchResults.hide()
    @questionSearchFields.hide()

    @questionIndex.hide()

    @addButton.hide()

    @questionSearch.show()
    @questionPreview.show()

    @backButton.show()

    index = @question_ids.indexOf(qid)
    question = @questions[index]
    @youtube.pauseVideo()
    @youtube.seekTo question.timeInSeconds

    @questionTime.text("This question will appear at #{question.timeString()}")
    @questionTime.show()

    @questionSearcher.getText qid, (text) =>
      @questionPreview.html(text)
      MathJax.Hub.Queue(["Typeset", MathJax.Hub, "question_preview"])

    @questionTimeUpdatePollerInterval = setInterval @questionTimeUpdatePoller(question), 100

    @backButton.text("Scheduled Questions")
    @backButton.unbind().click =>
      @gotoAddState()

    @removeButton.show().unbind().click =>
      question.destroy()
      @question_ids.splice(index,1)
      @questions.splice(index,1)
      @gotoAddState()

class LectureViewer

  constructor: (params) ->

    @questionTimeline   = $("#question_timeline")
    @questionContainer  = $("#question_container")
    @playerContainer  = $("#player_container")

    @questions    = []
    @question_ids = []

  loadVideo: ->
    videoId = @playerContainer.attr('data-video')
    @player.css('height', '95%')
    if videoId?
      @youtube.loadVideoById(videoId, 0, "hd1080")

  loadQuestions: ->
    return unless @playerContainer.attr('data-questions')?
    questionData = JSON.parse(@playerContainer.attr('data-questions'))

    for questionAttrs in questionData
      id    = questionAttrs.question_id
      time  = questionAttrs.time
      text  = $("#question_text_#{id}").html()
      question = new InLectureQuestion(id,
                                       time,
                                       text,
                                       @youtube,
                                       @markerClicked)
      @questions.push question
      @question_ids.push id

  markerClicked: (id) =>

    index = @question_ids.indexOf(id)
    question = @questions[index]

    @showQuestion(question)

  pollYouTube: =>

    if @youtube.getPlayerState() == YT.PlayerState.PLAYING
      currentTime = @youtube.getCurrentTime()
      for question in @questions
        if not question.complete() and @withinThreshold(question.timeInSeconds, currentTime)
          @showQuestion(question)
          break

  showQuestion: (question) ->
    @player.animate {height: '50%'}, 250
    #clearInterval @pollInterval
    @youtube.seekTo(question.timeInSeconds)
    @youtube.pauseVideo()
    @questionContainer.html(question.text).addClass("active")
    
    borderHeight  = @questionContainer.outerHeight() - 
                    @questionContainer.innerHeight()
    desiredHeight = @player.height()-borderHeight
    #@questionContainer.css('min-height', desiredHeight)

    MathJax.Hub.Queue(["Typeset",MathJax.Hub])
    skipButton = $(document.createElement("a")).attr("id", "skip_question")
    skipButton.text("Skip Question").addClass("btn")
    @questionContainer.find(".button_container").prepend(skipButton)
    skipButton.click =>
      #@pollInterval = setInterval @pollYouTube, 100
      $(window).scrollTop(0)
      @player.animate {height: '95%'}, 250
      @youtube.playVideo()
      question.skip()
      @questionContainer.html("").removeClass("active")

    form = @questionContainer.find("form")
    form.submit (event) =>
      target = event.delegateTarget
      event.preventDefault()
      $.post(
        $(target).attr('action'),
        $(target).serialize(),
        (data) =>
          @questionContainer.html(data).addClass("active")
          MathJax.Hub.Queue(["Typeset",MathJax.Hub])
          correct = JSON.parse(@questionContainer.children("#answer_correctness").attr("data-correct"))
          buttonContainer = $(document.createElement("div"))
          buttonContainer.addClass('button_container')
          @questionContainer.find('.question').append(buttonContainer)
          question.submit(correct)
          $('html, body').scrollTop(@questionContainer.find('.question').offset().top)

          @questionContainer.find(".stats").each (index) ->
            data = $(this).data("values")
            id = $(this).attr("id")
            bins = $(this).data("bins")
            draw_chart(data, bins, "#" + id, height: 100, width: 300)# bins: bins)

          if correct
            @questionContainer.find('.question').addClass('correct')
            resumeButton = $(document.createElement("a"))
            resumeButton.attr("id", "resume_question")
            resumeButton.text("Resume Watching").addClass("btn")
            buttonContainer.append(resumeButton)
            resumeButton.click =>
              #@pollInterval = setInterval @pollYouTube, 100
              $(window).scrollTop(0)
              @player.animate {height: '95%'}, 250
              @youtube.playVideo()
              @questionContainer.html("").removeClass("active")
          else
            @questionContainer.find('.question').addClass('incorrect')
            [skipButton, retakeButton] = @createIncorrectButtons()
            buttonContainer.append(skipButton).append(retakeButton)
            skipButton.click =>
              #@pollInterval = setInterval @pollYouTube, 100
              $(window).scrollTop(0)
              @player.animate {height: '95%'}, 250
              @youtube.playVideo()
              question.skip()
              @questionContainer.html("").removeClass("active")
            retakeButton.click =>
              @showQuestion(question)
      )
      return false

  createIncorrectButtons: () ->
    skipButton = $(document.createElement("a")).attr("id", "skip_question")
    skipButton.text("Skip Question").addClass("btn")

    retakeButton = $(document.createElement("a")).attr("id", "retake_question")
    retakeButton.text("Retake Question").addClass("btn")
    return [skipButton, retakeButton]

  withinThreshold: (qtime, time) ->
    return (time > qtime - 0.5) and (time < qtime + 0.5)

  onPlayerReady: (event) =>

    @playerReady = true

    # Store the player object after it's been created.
    @youtube = site.lectures.player

    # Need to reset @player because YouTube replaces the div
    @player = $("#player")

    @loadQuestions()
    @loadVideo()

    @pollInterval = setInterval @pollYouTube, 100

  onPlayerStateChange: (event) =>
    switch event.data
      when -1
        ->
        # Means unstarted; don't need to do anything here.
      when YT.PlayerState.BUFFERING
        # Update marker positions here because the video may not have been
        # loaded at the beginning.
        for question in @questions
          @questionTimeline.append(question.marker)
          question.updateMarkerPosition()
      when YT.PlayerState.PLAYING
        # Update the marker when the video starts playing. This is because the
        # duration isn't available when the video is buffered. 
        # This is somewhat inefficient, but won't be a big deal.
        for question in @questions
          question.updateMarkerPosition()
      when YT.PlayerState.PAUSED
        ->
        #Don't do anything when paused, yet..

  onPlayerError: (event) =>
    ->
    #Don't do anything here, yet.
