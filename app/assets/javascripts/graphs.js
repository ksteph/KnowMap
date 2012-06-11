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
