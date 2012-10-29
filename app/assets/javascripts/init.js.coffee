site = new Object
window.site = site

site.common = new Object

site.common.init = ->
  dateSelect = $('.date_select').kalendae(format: "MM/DD/YY")
  window.moment = Kalendae.moment
  String::strip = -> if String::trim? then @trim() else @replace /^\s+|\s+$/g, ""
