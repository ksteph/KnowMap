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
    uncolor_nodes();
    if(history.state && history.state.node_id) {
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
    id = this.href.search("node") > 0 ? this.href.substr(this.href.lastIndexOf('/')+1) : null;
    // save history
    history.pushState({'node_id': id}, document.title, this.href);
    
    // uncolor nodes
    uncolor_nodes();
    
    // update DOM with ajax response
    $('div#content').html(data);
    
    // color node
    color_node(id);
    
    // attach ajax:success event
    ajax();
  });
  
  $('form[data-remote=true]').on('ajax:success', function(event, data, status, xhr) {
    url = this.getAttribute('action');
    id = url.search("node") > 0 ? url.substr(url.lastIndexOf('/')+1) : null;
    
    // save history
    if(window.location.pathname!==this.getAttribute('action'))
      history.pushState({'node_id': id}, document.title, this.getAttribute('action'));
    
    // uncolor nodes
    uncolor_nodes();
    
    // update DOM with ajax response
    $(this).parents('div#content').html(data);
    
    // color node
    color_node(id);
    
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
