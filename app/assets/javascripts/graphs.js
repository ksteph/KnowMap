// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

function updateGraph() {
  graph_id = parseInt($("#graphData").attr('data-graph_id'));
  graph_nodes = $.parseJSON($("#graphData").attr('data-graph_nodes'));
  node_id = parseInt($("#graphData").attr('data-node_id'));
  
  uncolorNodes('lightblue');
  uncolorNodes("#4B7399");
  
  colorNode(node_id, "#4B7399");
  if(graph_nodes) {
    $.each(graph_nodes, function(i,v){ colorNode(v,'lightblue'); });
  }
}

function colorNode(id, color) {
  //$('title[data-id='+id+']').prev().prev().attr('style', 'fill: '+color);
}

function uncolorNodes(color) {
  //if($('[style="fill: '+color+'"]').length)
    //$('[style="fill: '+color+'"]').each(function(i, v){
    //  v.setAttribute('style', 'fill: pink');
    //});
}
