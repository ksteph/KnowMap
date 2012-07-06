// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//  require jquery
//= require jquery_ujs
//          history_jquery_html5
//= require_tree .

function remove_fields(link) {
  $(link).prev().attr('value', true);
  $(link).parent().hide('fast');
}

function add_fields(link, association, content) {
  var new_id = new Date().getTime();
  var regexp = new RegExp("new_" + association, "g")
  $(link).before(content.replace(regexp, new_id));
}

function updateView(url) {
  $.ajax({
    url: url,
    dataType: 'html'
  }).done(function(data) { 
    $('div#content').html(data);
    updateGraph();
    ajax();
  });
}

jQuery(function($) {
  if ( history && history.pushState) {
    $(window).bind("popstate", function() {
      updateView(location.href);
      if(history.state)
        $("div.search input[type=text]").attr('value', history.state.search);
    });
    history.replaceState({search: search_term()}, document.title, document.location.href);
    updateGraph();
    ajax();

    if ( ! $.cookie("remote") ) {
      // set remote cookie
      $.cookie("remote", "true", { path: '/'});
      
      // ajaxify all links and all forms
      $('a,form').attr('data-remote', true);
      
      // bind ajax:success function
      ajax();
    }
  }
});

function ajax() {
  $('[data-remote=true]').not(".user_nav *").one('ajax:success', function(event, data, status, xhr) {
    // save history
    if(this.tagName.toLowerCase() === "a" || (this.tagName.toLowerCase() === "form" && window.location.pathname!==this.getAttribute('action') ))
      history.pushState({search: search_term()}, document.title, xhr.getResponseHeader("X-App-Path"));
    
    // update DOM with ajax response
    $('div#content').html(data);
    
    // updateGraph
    updateGraph();
    
    // attach ajax:success event
    ajax();
  });
  
  
  $('.user_nav a[data-remote=true]').one('ajax:success', function(event, data, status, xhr) {
    // save history
    if(this.tagName.toLowerCase() === "a" || (this.tagName.toLowerCase() === "form" && window.location.pathname!==this.getAttribute('action') ))
      history.pushState({search: search_term()}, document.title, xhr.getResponseHeader("X-App-Path"));
    
    // update DOM with ajax response
    $('div#content').html(data);
    
    $.ajax('_partials/user_nav').done(function(data) { $('div.user_nav').html(data); })
    
    // updateGraph
    updateGraph();
    
    // attach ajax:success event
    ajax();
  }); 
}
