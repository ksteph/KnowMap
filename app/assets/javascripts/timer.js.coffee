class Timer
  constructor: ($timer, seconds_remaining) ->
    @$timer = $timer
    @seconds_remaining = seconds_remaining

  start: ->
    s = setTimeout =>
          @update_resubmit_timer(s)
        , 1000

  update_resubmit_timer: (s) ->
    timeout_id = s
    timer_text = null

    # Assuming hours max unit
    seconds = Math.floor(@seconds_remaining%60)
    minutes = Math.floor(@seconds_remaining/60)
    hours = Math.floor(@seconds_remaining/3600)

    timer_text =
      if @seconds_remaining <= 0
        'You can resubmit now.'
      else if hours > 0
        "You can resubmit in #{hours}h #{minutes}m #{seconds}s"
      else
        "You can resubmit in #{minutes}m #{seconds}s"

    @$timer.text(timer_text)

    @seconds_remaining -= 1

    if @seconds_remaining >= 0
      timeout_id = setTimeout =>
        @update_resubmit_timer(timeout_id)
      , 1000

window.Timer = Timer
