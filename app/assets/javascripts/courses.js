// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(function() {
    if($(".rows").attr("data-edit")==="") {
      makeRowsSortable();
      makeNodesSortable();
    } else {
      $(".rows").children().last().remove();
    }
});

function save() {
    //console.log("--------------------------");
    var rank = {};
    var count = 0;
    $(".row").each(function(row,val1) {
        $(val1).find(".node").each(function(index,val2) {
            if(val2.dataset.rank!=="")
              rank['course[node_indices_attributes]['+count +'][id]'] = val2.dataset.rank;
            rank['course[node_indices_attributes]['+count +'][node_id]'] = val2.id.substr(5);
            rank['course[node_indices_attributes]['+count +'][row]'] = row;
            rank['course[node_indices_attributes]['+count++ +'][index]'] = index;
        });
    });
    $.ajax(window.location.pathname, {data: rank, 'type': 'PUT'});
    
    checkRows();
}

function checkRows() {
  // Adds blank row if none exist or deletes extra one if more than one exist
  var found = false;
  $($(".row").get().reverse()).each(function(row, val) {
    if($(val).find("li").length===0)
      if(found)
        $(val).remove();
      else
        found = true;
  });
  if (!found) addRow();
}

function makeRowsSortable() {
    $(".rows").sortable({
        axis: 'y',
        update: save
    }).disableSelection();
}
function makeNodesSortable() {
    $(".nodes").sortable({
        //placeholder: "node-placeholder",
        connectWith: ".nodes",
        update: save
    }).disableSelection();
}
function addRow() {
    $(".rows").append('<div class="row"><ul class="nodes"></ul></div>');
    makeNodesSortable();
}
