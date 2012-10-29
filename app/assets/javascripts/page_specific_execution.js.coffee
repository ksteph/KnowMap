$ ->

  site = window.site

  body = $('body')
  controller = body.attr('data-controller')
  action     = body.attr('data-action')

  site.common.init()

  console.log(site[controller])
  if site[controller]
    site[controller].init() if site[controller].init?
    if site[controller][action]?
      site[controller][action]()
