var MAP_CONSTANTS = {
    zoom_scale : 1.1,
    pan_step : 10,

    node_radius : 8,
    node_shift_x : 100,
    node_shift_y : 0,
    node_text_line_char_limit : 15,
    node_text_dy : 0.35,

    edge_style_related : "1,2",
    edge_style_dependent : "1,0",

    highlight_colors : ["#ff0000","#ff9900","#fff333","#00cc00","#3333ff"],
    highlight_radius : 11,
    highlight_opacity : 0.5,

    lp_node_radius : 30,
};

/*
  highlight colors are from here: http://www.colorschemer.com/schemes/viewscheme.php?id=9159
 */

$(function() {
  // Code that should execute after the DOM is ready
});


var Map = (function(Map, $, undefined){
  Map.TransMatrix = [1,0,0,1,0,0];
  Map.MousePos = [0,0];
  Map.WinMousePos = [0,0];
  Map.BMouseDown = false;
  Map.DragOldMousePos = [0,0];
  Map.DragStartMousePos = [0,0];
  Map.DragEndMousePos = [0,0];

  Map.setup = function() {
    //console.log("called Map.setup()");
    $("#learning-path-widget-button").on("click", Map.LearningPathWidget.toggle);
    $("#groups-widget-button").on("click", Map.GroupsWidget.toggle);
    //$("#groups-widget").animate({right: -$("#groups-widget").outerWidth()});
    //$("#groups-widget").css("right", -$("#groups-widget").outerWidth());
    //$("#groups-widget-button").animate({left: -$("#groups-widget-button").outerWidth()-1});
    //$("#groups-widget-button").css("left", -$("#groups-widget-button").outerWidth()-1);
    //Map.GroupsWidget.expand();

    window.addEventListener('keydown', Map.winKeyDown, false);
    window.addEventListener('mousemove', Map.winMouseMove, false);
    window.addEventListener('mouseup', Map.winMouseUp, false);

    $("#chart").on("mousewheel", Map.svgMouseWheel);
    $("#chart").on("mousedown", Map.svgMouseDown);

    Map.Svg = d3.select("#chart").append("svg")
    .attr("id", "svg-chart")
    .attr("width", "100%")
    .attr("height", "100%")
    .on("mousemove", Map.mouseMove);
    
    Map.SvgChartG = Map.Svg.append("g")
    .attr("id", "chart-group")
    .attr("transform", "matrix("+Map.TransMatrix.join(' ')+")");

    //Arrowhead Marker
    Map.SvgChartG.append("defs").append("marker")
      .attr("id", "arrowhead")
      .attr("viewBox", "0 0 10 10")
      .attr("refX", MAP_CONSTANTS.node_radius*4.35)
      .attr("refY", "5")
      .attr("markerUnits", "strokeWidth")
      .attr("markerWidth", 6)
      .attr("markerHeight", 4)
      .attr("orient", "auto")
      .append("path")
        .attr("d", "M 0 0 L 10 5 L 0 10 Z");

    //Need to create svg.g in this order because edges need to be "under" nodes
    Map.SvgEdgeG = Map.SvgChartG.append("g")
    .attr("id","edge-group");
    Map.SvgNodeG = Map.SvgChartG.append("g")
    .attr("id","node-group");

    Map.Node.setup(Map.SvgNodeG);
    Map.Edge.setup(Map.SvgEdgeG);

    Map.SvgZoomPanG = Map.Svg.append("g")
    .attr("id","zoom-pan-widget");
    Map.ZoomPanWidget.create(Map.SvgZoomPanG);

    Map.update();
  }
  
  Map.update = function() {
    //console.log("called Map.update()");
    if ( $("#graphData").attr("data-graph_id") && $("#graphData").attr("data-graph_id") !== "" ) {
      //console.log("--> Graph detected");
      //Map.LearningPathWidget.collapse();
      //Map.GroupsWidget.collapse();
      Map.show();
      Map.GroupsWidget.update();

      // doMapStuff();
      var url = "../data.json?id=";
      node_ids = $("#graphData").attr("data-all_graph_nodes");
      node_ids = node_ids.substr(1, node_ids.length-2);
      if(node_ids) { url = url + node_ids; }
      
      d3.json(url, function(json) {
        nodes = json.nodes;
        links = json.lines;

        Map.Node.update(nodes);
        Map.Edge.update(links, Map.Node.MapId2Data);
      });

      Map.Container.show();
      Map.LearningPathWidget.collapse();
      //Map.GroupsWidget.expand();
    } else if ( $("#graphData").attr("data-node_id") && $("#graphData").attr("data-node_id") !== "" ) {
      //console.log("--> Node detected");
      //Map.LearningPathWidget.expand();
      //Map.GroupsWidget.collapse();     
      Map.NodeWidget.update();
      Map.LearningPathWidget.update();
      Map.NodeWidget.show();
      Map.Container.show();
    } else {
      //console.log("--> hiding map container");
      Map.Container.hide();
    }
  }
    
  Map.hide = function() {
    $("div#map").css("display","none");
    $("div#node-widget").css("display","block");
  }
      
  Map.show = function() {
    $("div#map").css("display","block");
    $("div#node-widget").css("display","none");
  }
  
  Map.Container = (function(Container) {
    Container.hide = function() {
      $("#map-container").hide();
    }

    Container.show = function() {
      $("#map-container").show();
    }
    
    return Container;
  })({});
  
  Map.LearningPathWidget = (function(LearningPathWidget) {
    LearningPathWidget.update = function(node_id) {
      if(!node_id)
        node_id = $("#graphData").attr("data-node_id");
      $("#learning-path-widget-content").html( "<img src='/assets/path.png'/ > Node id: " + node_id);
    }
    
    LearningPathWidget.expand = function() {
      if(!$("#learning-path-widget-content").is(":visible"))
        LearningPathWidget.toggle();
    }

    LearningPathWidget.collapse = function() {
      if($("#learning-path-widget-content").is(":visible"))
        LearningPathWidget.toggle();
    }
    
    LearningPathWidget.toggle = function(event) {
      if(!$("#learning-path-widget-content").is(":visible"))
          $("#learning-path-widget-button").css("border-top","1px solid black");
      $("#learning-path-widget-content").animate({height: 'toggle'}, null, null, function() {
        if($("#learning-path-widget-content").is(":visible")) {
          $("#learning-path-widget-button").html("&#x2234;");
        } else {
          $("#learning-path-widget-button").html("&#x2235;");
          $("#learning-path-widget-button").css("border-top", "none");
        }
      });
    }
    
    return LearningPathWidget;
  })({});
  
  Map.GroupsWidget = (function(GroupsWidget) {
    GroupsWidget.update = function() {
      var url = '/graphs/'+ $("#graphData").attr("data-graph_id") +'/groups_widget';
      console.log(url);
      $.ajax({
        url: url,
        dataType: 'html'
      }).done(function(data) {
        $("#groups-widget-content").html(data);
      })
    }
    
    GroupsWidget.expand = function() {
      if(parseInt($("#groups-widget").css("right"),10)!=0)
        GroupsWidget.toggle();
    }

    GroupsWidget.collapse = function() {
      if(parseInt($("#groups-widget").css("right"),10)==0)
        GroupsWidget.toggle();
    }
    
    GroupsWidget.toggle = function(event) {
      if(parseInt($("#groups-widget").css("right"),10)!=0) {
          $("#groups-widget-button").animate({left: parseInt($("#groups-widget-button").css('left'),10) == -1 ? -$("#groups-widget-button").outerWidth()-1 : -1});
        }
        $("#groups-widget").animate({right: parseInt($("#groups-widget").css('right'),10) == 0 ? -$("#groups-widget").outerWidth() : 0},  function() {
          if(parseInt($("#groups-widget").css("right"),10)==0) {
            $("#groups-widget-button").html("&raquo;");
          } else {
            $("#groups-widget-button").animate({left: parseInt($("#groups-widget-button").css('left'),10) == -1 ? -$("#groups-widget-button").outerWidth()-1 : -1});
            $("#groups-widget-button").html("&laquo;");
          }
      });
    }
    
    return GroupsWidget;
  })({});
  
  Map.NodeWidget = (function(NodeWidget) {
    NodeWidget.show = function() { Map.hide() }

    NodeWidget.hide = function() { Map.show() }
    
    
    NodeWidget.update = function() {
      var url = '/nodes/'+ $("#graphData").attr("data-node_id") +'/node_widget';
      console.log(url);
      $.ajax({
        url: url,
        dataType: 'html'
      }).done(function(data) {
        $("#node-widget").html(data);
        ajax();
      })
    }
    
    return NodeWidget;
  })({});
  
  Map.Node = (function(Node) {
    Node.Data = null;
    Node.MapId2Data = null;
    Node.SvgG = null;
    Node.SvgNodes = null;
    Node.SvgNodesInner = null;

    Node.setup = function(svgG) {
      Node.SvgG = svgG;
    }

    Node.update = function(nodeData) {
      Node.Data = nodeData;
      Node.MapId2Data = {};

      for (var i=0; i < Node.Data.length; i++) {
        Node.Data[i].aryLabel = Node.getAryLabel(Node.Data[i].title);
        Node.MapId2Data[Node.Data[i].id] = Node.Data[i];
      }

      if (Node.SvgNodes != null)
          Node.SvgNodes.remove();

      Node.SvgNodes = Node.SvgG.selectAll("g.map-node-g")
        .data(Node.Data)
        .enter().append("g")
          .attr("class","map-node-g")
          .attr("id", function(d){return d.id;})
          .attr("transform", function(d){return "translate("+d.x+","+d.y+")";})
      //          .on("dblclick", onDblClick) //TODO: Move this function
          .on("dblclick", Map.Node.dblClick)
          .on("click", Map.Node.click);

      Node.SvgNodes.append("g")
        .attr("id","map-node-outer");

      Node.SvgNodesInner = Node.SvgNodes.append("g")
        .attr("id","map-node-inner");

      Node.SvgNodesInner.append("circle")
        .attr("class", "map-node")
        .attr("r", MAP_CONSTANTS.node_radius);

      Node.SvgNodesInner.append("g")
        .attr("id","g-node-label")
        .each(function(d) {
          var g = d3.select(this);
          var startDY = 0.5 - (d.aryLabel.length/2.0);
          startDY += MAP_CONSTANTS.node_text_dy;
          for(var i=0; i<d.aryLabel.length ;i++) {
            g.append("text").text(d.aryLabel[i])
              .attr("class","map-node-text")
              .attr("dy",(startDY+parseInt(i))+"em");
          }
        });
    }

    Node.getAryLabel = function(label) {
      if (label.length > MAP_CONSTANTS.node_text_line_char_limit) {
        var aryStr = label.split(' ');
        var aryLabel = [aryStr.shift()];
        var iLabel = 0;
        var currLineLen = aryLabel[iLabel].length;
        for (i in aryStr) {
          if ((currLineLen+aryStr[i].length+1) >
              MAP_CONSTANTS.node_text_line_char_limit) {
            iLabel++;
            aryLabel[iLabel] = ""
            currLineLen = 0;
          } else {
            aryLabel[iLabel] += " ";
            currLineLen++;
          }
          aryLabel[iLabel] += aryStr[i];
          currLineLen += aryStr[i].length;
        }
        
        return aryLabel;
      } else {
        return [label];
      }

    }

    Node.dblClick = function() {
        //      console.log("dblClick"); return;

      var id = parseInt(d3.select(this).attr("id"));
      var url = '/nodes/' + id;

      updateView(url);
      Map.NodeWidget.show();
      Map.LearningPathWidget.expand();
    
      // save history
      history.pushState({'node_id': id, search:search_term()}, document.title, url);

    }

    Node.click = function() {
      if (((Map.DragStartMousePos[0]-Map.DragEndMousePos[0]) != 0) ||
          ((Map.DragStartMousePos[1]-Map.DragEndMousePos[1]) != 0))
        return;

      //console.log("click"); return;

      node_id = this.__data__.id;
      console.log("node " + node_id + " was clicked");
      Map.LearningPathWidget.update(node_id); // update LearningPath Widget
      Map.LearningPathWidget.expand(); // expand LearningPath Widget
      Map.Node.highlight_path(node_id); // highlight learning path for node on map
    }
    
    Node.highlight_path = function(node_id) {
      $.ajax({
        url: '/nodes/'+node_id+'/learning_path',
        success: function(data) {
          node_ids = data.nodes.map(function(node) { return node.id });
          d3.selectAll("g[class=node]").selectAll("g[id=g-node]").selectAll("circle[class=map-node-highlighted]").filter(function(d) { return node_ids.indexOf(d.id) === -1 }).attr("class", "map-node"); // unhighlight old nodes
          d3.selectAll("g[class=node]").selectAll("g[id=g-node]").filter(function(d) { return node_ids.indexOf(d.id) > -1}).select("circle").attr("class", "map-node-highlighted"); // highlight new nodes 
        }
      });
    }
    
    return Node;
  })({});

  Map.Edge = (function(Edge) {
    Edge.SvgG = null;
    Edge.SvgEdges = null;
    Edge.Data = null;
    Edge.MapNodeId2Node = null;

    Edge.StrokeStyle = {
      "RelatedEdge":MAP_CONSTANTS.edge_style_related,
      "DependentEdge":MAP_CONSTANTS.edge_style_dependent,
    };
    Edge.MarkerEnd = {
      "RelatedEdge":"none",
      "DependentEdge":"url(#arrowhead)"
    };

    Edge.setup = function(svgG) {
      Edge.SvgG = svgG;
    }

    Edge.update = function(data, mapNode) {
      Edge.Data = data;
      Edge.MapNodeId2Node = mapNode;

      if (Edge.SvgEdges != null)
          Edge.SvgEdges.remove();

      Edge.SvgEdges = Edge.SvgG.selectAll(".edge")
        .data(Edge.Data)
        .enter().append("line")
          .attr("class", "map-edge")
          .attr("x1", function(d){return Edge.MapNodeId2Node[d.source].x;})
          .attr("y1", function(d){return Edge.MapNodeId2Node[d.source].y;})
          .attr("x2", function(d){return Edge.MapNodeId2Node[d.target].x;})
          .attr("y2", function(d){return Edge.MapNodeId2Node[d.target].y;})
          .style("stroke-dasharray", function(d){
              return Edge.StrokeStyle[d.type]
            })
          .style("marker-end", function(d){return Edge.MarkerEnd[d.type]});
    }

    return Edge;
  })({});

  Map.ZoomPanWidget = (function(ZoomPanWidget) {

    ZoomPanWidget.create = function(svgZoomPan) {
      svgZoomPan.append("circle")
      .attr("cx",50)
      .attr("cy",50)
      .attr("r",42)
      .style("fill","white")
      .style("opacity",0.75);
      svgZoomPan.append("path")
      .attr("d", "M50 10 l12 20 a40,70 0 0,0 -24,0z")
      .attr("class","zoom-pan-button")
      .on("click",Map.panUp);
      svgZoomPan.append("path")
      .attr("d", "M10 50 l20 -12 a70,40 0 0,0 0,24z")
      .attr("class","zoom-pan-button")
      .on("click",Map.panRight);
      svgZoomPan.append("path")
      .attr("d", "M50 90 l12 -20 a40,70 0 0,1 -24,0z")
      .attr("class","zoom-pan-button")
      .on("click",Map.panDown);
      svgZoomPan.append("path")
      .attr("d", "M90 50 l-20 -12 a70,40 0 0,1 0,24z")
      .attr("class","zoom-pan-button")
      .on("click",Map.panLeft);
      svgZoomPan.append("circle")
      .attr("class", "zoom-pan-compass")
      .attr("cx",50)
      .attr("cy",50)
      .attr("r",20);
      svgZoomPan.append("circle")
      .attr("class", "zoom-pan-button")
      .attr("cx",50)
      .attr("cy",41)
      .attr("r",8)
      .on("click",Map.zoomIn); //TODO: Zoom from center not mouse position
      svgZoomPan.append("circle")
      .attr("class", "zoom-pan-button")
      .attr("cx",50)
      .attr("cy",59)
      .attr("r",8)
      .on("click",Map.zoomOut);
      svgZoomPan.append("rect")
      .attr("class", "zoom-pan-plus-minus")
      .attr("x",46)
      .attr("y",39.5)
      .attr("width",8)
      .attr("height",3);
      svgZoomPan.append("rect")
      .attr("class", "zoom-pan-plus-minus")
      .attr("x",48.5)
      .attr("y",37)
      .attr("width",3)
      .attr("height",8);
      svgZoomPan.append("rect")
      .attr("class", "zoom-pan-plus-minus")
      .attr("x",46)
      .attr("y",57.5)
      .attr("width",8)
      .attr("height",3);
    }

    return ZoomPanWidget;
  })({});
  
  Map.pan = function(dx,dy) {
    if (Map.SvgChartG == null)
      return;
       
    Map.TransMatrix[4] += dx;
    Map.TransMatrix[5] += dy;
    
    var matrix = "matrix("+Map.TransMatrix.join(' ')+")";
    Map.SvgChartG.attr("transform", matrix);
  }

  Map.panUp = function(){ Map.pan(0,MAP_CONSTANTS.pan_step); }
  Map.panDown = function(){ Map.pan(0,-MAP_CONSTANTS.pan_step); }
  Map.panRight = function(){ Map.pan(MAP_CONSTANTS.pan_step,0); }
  Map.panLeft = function(){ Map.pan(-MAP_CONSTANTS.pan_step,0); }

  Map.zoomIn = function() { Map.zoom(MAP_CONSTANTS.zoom_scale); }
  Map.zoomOut = function() { Map.zoom(1.0/MAP_CONSTANTS.zoom_scale); }

  Map.zoom = function(scale) {
    if (Map.SvgChartG == null)
      return;

    for(var i = 0; i < Map.TransMatrix.length; i++) {
      Map.TransMatrix[i] *= scale;
    }

    Map.TransMatrix[4] += (1-scale)*Map.MousePos[0];
    Map.TransMatrix[5] += (1-scale)*Map.MousePos[1];

    var matrix = "matrix("+Map.TransMatrix.join(' ')+")";
    Map.SvgChartG.attr("transform", matrix);
  }

  Map.mouseMove = function(event) {
    Map.MousePos = d3.mouse(this);
  }

  Map.svgMouseWheel = function(event, delta, deltaX, deltaY) {
    if (delta > 0)
      Map.zoomIn();
    else
      Map.zoomOut();
    event.preventDefault();
  }

  Map.svgMouseDown = function(event) {
    if(event.which==1) {  // event.which is 1 -> left btn, 2 -> right btn
      Map.BMouseDown = true;
      Map.DragOldMousePos = Map.WinMousePos;
      Map.DragStartMousePos = Map.WinMousePos;
      $("#svg-chart").css("cursor", "move");
      event.preventDefault();
    }
  }

  Map.winMouseUp = function(event) {
    Map.BMouseDown = false;
    Map.DragEndMousePos = Map.WinMousePos;
    $("#svg-chart").css("cursor", "default");
  }

  Map.winMouseMove = function(e) {
    Map.WinMousePos = [e.clientX,e.clientY];
    if (Map.BMouseDown) {
      var dx = -1*(Map.DragOldMousePos[0]-Map.WinMousePos[0]);
      var dy = -1*(Map.DragOldMousePos[1]-Map.WinMousePos[1]);
      Map.pan(dx,dy);
      Map.DragOldMousePos = Map.WinMousePos;
    }
  }


  Map.winKeyDown = function(event) {
    switch(event.keyCode) {
      case 37: // left arrow
        Map.panRight();
        break;
      case 38: // up arrow
        Map.panUp();
        break;
      case 39: // right arrow
        Map.panLeft();
        break;
      case 40: // down arrow
        Map.panDown();
        break;
      case 187: // + key
        Map.zoomIn();
        break;
      case 189: // - key
        Map.zoomOut();
        break;
      default:
        break; // Do nothing
    }
  }

  return Map;
})({}, jQuery);
