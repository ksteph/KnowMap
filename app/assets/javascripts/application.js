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
//= require jquery
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
    if(history.state && history.state.node_id) {
      uncolor_nodes();
      color_node(history.state.node_id);
    }
    ajax();
  });
}

jQuery(function($) {
  if ( history && history.pushState) {
    $(window).bind("popstate", function() {
      updateView(location.href);
    });
    ajax();

    if ( ! $.cookie("remote") ) {
      $.cookie("remote", "true", { path: '/'});
      updateView(window.location.pathname);
    }
  }
});

function ajax() {
  $('a[data-remote=true]').on('ajax:success', function(event, data, status, xhr) {
    // save history
    history.pushState(null, document.title, this.href);
    
    // update DOM with ajax response
    $(this).parents('div#content').html(data);
    
    // attach ajax:success event
    ajax();
  });
  
  $('form[data-remote=true]').on('ajax:success', function(event, data, status, xhr) {
    // save history
    if(window.location.pathname!==this.getAttribute('action'))
      history.pushState(null, document.title, this.getAttribute('action'));
    
    // update DOM with ajax response
    $(this).parents('div#content').html(data);
    
    // attach ajax:success events
    ajax();
  });
}

function color_node(id) {
  $('title[data-id='+id+']').prev().prev().attr('style', 'fill: #4B7399');
}

function uncolor_nodes() {
  if($('[style="fill: #4B7399"]').length)
  $('[style="fill: #4B7399"]').each(function(i, v){
    v.setAttribute('style', 'fill: pink');
  });
}
