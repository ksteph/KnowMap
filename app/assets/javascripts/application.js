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
//= require_tree .

function remove_fields(link) {
  //$(link).prev("input[type=hidden]").val("1");
  //$(link).closest(".fields").hide();
  $(link).prev().attr('value', true);
  $(link).parent().hide('fast');
}

function add_fields(link, association, content) {
  var new_id = new Date().getTime();
  var regexp = new RegExp("new_" + association, "g")
  $(link).before(content.replace(regexp, new_id));
}

jQuery(function($) {
  ajax();
});

function ajax() {
  //alert('hooking graph');
  $('a[data-remote=true]').on('ajax:success', function(event, data, status, xhr) {
    //alert('its a success yo');
    // save history
    //history.pushState(null, document.title, this.href);
    
    // update DOM with ajax response
    $(this).parents('div#content').html(data);
    
    // attach ajax:success event
    ajax();
  });
}
