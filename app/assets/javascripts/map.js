var MAP_CONSTANTS = {
    zoom_scale : 1.1,
    zoom_in_limit : 30.0,
    zoom_out_limit : 0.3,
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
    
    completed_opacity : 0.3,

    lp_node_radius : 30,
    lp_node_spacer : 45,
    lp_scroller_height : 10,
    lp_scroller_min_width : 10,
    lp_scroller_padding : 5,

    syllabus_transform_duration : 1000,
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

  Map.BLayoutIsSyllabus = false;

  Map.setup = function() {
    $("#learning-path-widget-button").on("click", Map.LearningPathWidget.toggle);
    $("#groups-widget-button").on("click", Map.GroupsWidget.toggle);
	
	// prepare event listeners for the tab buttons
	$("#groups-tab-button").on("click", function(){Map.GroupsWidget.displayTab("groups-widget-content", "groups-tab-button")});
	$("#node-stats-tab-button").on("click", function(){Map.GroupsWidget.displayTab("node-stats-widget-content", "node-stats-tab-button")});

	// displays the group-widget-content by default
	Map.GroupsWidget.displayTab("groups-widget-content", "groups-tab-button");
	
	// prepare students list and toggle-button
	Map.GroupsWidget.updateStudentsList();
    $("#show-students-button").on("click", function(){Map.GroupsWidget.toggleStudentsList()});

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

    var learningPathSvg = d3.select("#learning-path").append("svg")
      .attr("id", "learning-path-svg")
      .attr("width", "100%")
      .attr("height", "100%");

    Map.LearningPathWidget.setup(learningPathSvg);

    Map.update();
  }
  
  Map.update = function() {
    if ( $("#graphData").attr("data-graph_id") && $("#graphData").attr("data-graph_id") !== "" ) {
      Map.show();
      Map.GroupsWidget.update();

      // Draw nodes, links, and the zoom/pan widget
      var url = "../data.json?id=";
      node_ids = $("#graphData").attr("data-all_graph_nodes");
      node_ids = node_ids.substr(1, node_ids.length-2);
      if(node_ids) { url = url + node_ids; }
      
      url = url + "&TestGraphID=" + $("#graphData").attr("data-graph_id"); // need to pass graph-id to collect statistics
 
      d3.json(url, function(json) {
        Map.Node.update(json.nodes);
        Map.Edge.update(json.lines, Map.Node.MapId2Data);
      });

      Map.Container.show();
      Map.LearningPathWidget.collapse();
    } else if ( $("#graphData").attr("data-node_id") && $("#graphData").attr("data-node_id") !== "" ) {
      Map.NodeWidget.update();
      Map.LearningPathWidget.update();
      Map.NodeWidget.show();
      Map.Container.show();
    } else {
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
    LearningPathWidget.Svg = null;
    LearningPathWidget.SvgG = null;
    LearningPathWidget.SvgGScroller = null;
    LearningPathWidget.TransMatrix = [1,0,0,1,0,0,];
    LearningPathWidget.BMouseDown = false;
    LearningPathWidget.BMouseActive = false;

    LearningPathWidget.ScrollerTransMatrix = [1,0,0,1,0,0,];
    LearningPathWidget.BScrollerMouseDown = false;
    LearningPathWidget.BScrollerTooSmall = false;
    LearningPathWidget.ScrollScale = 1.0;

    LearningPathWidget.setup = function(svg) {
      LearningPathWidget.Svg = svg;
      LearningPathWidget.SvgGScroller = svg.append("g");
      LearningPathWidget.SvgG = svg.append("g").attr("id","lp-svg-g-main");

      $("#lp-svg-g-main").on("mousedown", LearningPathWidget.svgMouseDown);
    }

    LearningPathWidget.update = function(node_id) {
      if(!node_id)
        node_id = $("#graphData").attr("data-node_id");

      //Get height here so get height of style not
      // actual height while expanding the div
      var lpHeight = parseInt(d3.select("#learning-path-widget-content")
                              .style("height"));
      LearningPathWidget.Svg.style("height", lpHeight);
      // Clear old learning path stuff
      LearningPathWidget.SvgG.selectAll("g").remove();
      LearningPathWidget.TransMatrix = [1,0,0,1,0,0,];
      var matrix = "matrix("+LearningPathWidget.TransMatrix.join(' ')+")";
      LearningPathWidget.SvgG.attr("transform", matrix);
      d3.selectAll(".map-node-highlighted").attr("class","map-node");

      var urlJson = "../nodes/"+node_id+"/learning_path.json";

      d3.json(urlJson, function(json) {
        if (json == null)
          return;

        var lpNodes = json.nodes;
        var lpLinks = [];
        var lpNodesMap = {};

        var maxPosDiff = 0;
        var minPosDiff = 0;

        var lpWidth = $("#learning-path-widget-content").width();
        var pathWidth = LearningPathWidget.getNodePosX(lpNodes.length-1) +
            MAP_CONSTANTS.lp_node_radius + MAP_CONSTANTS.lp_node_spacer;

        var nodeY = lpHeight - MAP_CONSTANTS.lp_scroller_padding*2 -
            MAP_CONSTANTS.lp_scroller_height - MAP_CONSTANTS.lp_node_radius;

        LearningPathWidget.updateScrollRect(lpHeight, lpWidth, pathWidth);
        
        LearningPathWidget.pathlength = LearningPathWidget.getNodePosX(lpNodes.length-1) +
            MAP_CONSTANTS.lp_node_radius + MAP_CONSTANTS.lp_node_spacer;
        LearningPathWidget.width = $("#learning-path-widget-content").width();

        for(var i=0; i < lpNodes.length; i++) {
          lpNodes[i].aryLabel = Map.Node.getAryLabel(lpNodes[i].title);
          lpNodes[i].pos = i;
          lpNodesMap[lpNodes[i].id] = lpNodes[i];

          d3.select("#node-"+lpNodes[i].id).select(".map-node")
            .attr("class","map-node-highlighted");
        }

        for (var i=0; i<json.lines.length; i++) {
          //Filter to only edges that are dependent edges.
          if (json.lines[i].type == "DependentEdge")
            lpLinks.push(json.lines[i]);

          var nodeS = lpNodesMap[json.lines[i].source];
          var nodeT = lpNodesMap[json.lines[i].target];

          var diff = nodeT.pos - nodeS.pos;
          if (diff > maxPosDiff)
            maxPosDiff = diff;
          if (diff < minPosDiff)
            minPosDiff = diff;
        }

        LearningPathWidget.SvgG.append("g").append("rect")
          .attr("x",0)
          .attr("y",0)
          .attr("height",lpHeight-MAP_CONSTANTS.lp_scroller_height-
                MAP_CONSTANTS.lp_scroller_padding)
          .attr("width",pathWidth)
          .attr("fill",d3.select("#learning-path-widget-content")
                .style("background-color"));

        var svgLinkGroup = LearningPathWidget.SvgG.append("g");
        var svgMarkerDef = svgLinkGroup.append("defs");
        var svgNodeGroup = LearningPathWidget.SvgG.append("g");

        //Add arrowhead markers
        for (i=0; i<(maxPosDiff-minPosDiff+1); i++) {
          if (i == 0)
            continue;
          var angle = 15;
          var mult = minPosDiff + i;
          if (mult < 0) {
            angle = 180;
            mult *= -1;
          }
          
          svgMarkerDef.append("marker")
            .attr("class", "lp-arrowhead")
            .attr("id", "arrowhead-"+(minPosDiff+i))
            .attr("viewBox", "0 0 10 10")
            .attr("refX", 10)
            .attr("refY", 5)
            .attr("markerUnits", "strokeWidth")
            .attr("markerWidth", 5)
            .attr("markerHeight", 5)
            .attr("orient", angle+45*(mult/4.5))
            .append("path")
              .attr("d", "M 0 0 L 10 5 L 0 10 Z");
        }

        //Add Edges
        svgLinkGroup.selectAll("path.lp-edge")
          .data(lpLinks)
          .enter().append("path")
            .attr("class", function(d){ if (Map.Edge.MapNodeId2Node[d.source].completed == "true" && 
			                                Map.Edge.MapNodeId2Node[d.target].completed != "true") 
											{ return "lp-edge-completed"; } else { return "lp-edge"; }})
			.attr("opacity", function(d){if (Map.Edge.MapNodeId2Node[d.target].completed == "true") 
										    { return MAP_CONSTANTS.completed_opacity; } else { return 1.0; }})
            .style("fill","none")
            .style("marker-end", function(d){
               var diff = lpNodesMap[d.target].pos - lpNodesMap[d.source].pos;
               return "url(#arrowhead-"+diff+")";
             })
            .attr("d",function(d){
               var nodeS = lpNodesMap[d.source];
               var nodeT = lpNodesMap[d.target];

               var rCircle = MAP_CONSTANTS.lp_node_radius;

               var x1 = LearningPathWidget.getNodePosX(nodeS.pos);
               var x2 = LearningPathWidget.getNodePosX(nodeT.pos);

               var y1 = y2 = nodeY - MAP_CONSTANTS.lp_node_radius;

               var rX = (x2-x1)/2.0;
               var rY = (nodeT.pos-nodeS.pos)*rCircle/4.0;

               if (nodeT.pos < nodeS.pos) {
                 rX *= -1;
                 rY *= -1;
                 y1 += rCircle*2;
                 y2 += rCircle*2;
               }

            var pathStr = "M"+x1+","+y1+" ";
            pathStr += "A"+rX+","+rY+" 0 0,1 "+x2+","+y2;

            return pathStr;
            });

        //Add nodes
        var nodeGNode = svgNodeGroup.selectAll("g.lp-node-g")
          .data(lpNodes)
          .enter().append("g")
            .attr("class","lp-node-g")
            .attr("id",function(d){return "lp-node-"+d.id;})
            .attr("node-id",function(d){return d.id;})
            .attr("transform",function(d){
               return "translate("+
                 LearningPathWidget.getNodePosX(d.pos)+","+nodeY+")";
            });

        nodeGNode.append("circle")
          .attr("class", "lp-node")
          .attr("r", MAP_CONSTANTS.lp_node_radius)
          .attr("opacity", function(d){if (d.completed=="true") return MAP_CONSTANTS.completed_opacity; return 1.0;});

        nodeGNode.append("g")
          .attr("id","lp-node-label")
          .each(function(d) {
             var g = d3.select(this);
             var startDY = 0.5 - (d.aryLabel.length/2.0);
             startDY += MAP_CONSTANTS.node_text_dy;
             for(i in d.aryLabel) {
               g.append("text").text(d.aryLabel[i])
                 .attr("class","lp-node-text")
                 .attr("dy",(startDY+parseInt(i))+"em");
             }
           })
           .attr("opacity", function(d){if (d.completed=="true") return MAP_CONSTANTS.completed_opacity; return 1.0;});
      });
    }

    LearningPathWidget.getNodePosX = function(pos) {
      return MAP_CONSTANTS.lp_node_spacer + MAP_CONSTANTS.lp_node_radius +
          pos*(MAP_CONSTANTS.lp_node_radius*2 + MAP_CONSTANTS.lp_node_spacer);
    }

    LearningPathWidget.updateScrollRect =
        function(svgHeight, svgWidth, width) {
      LearningPathWidget.SvgGScroller.selectAll("rect").remove();
      LearningPathWidget.BScrollerTooSmall = false;
      LearningPathWidget.ScrollScale = 1.0;
      LearningPathWidget.ScrollerTransMatrix = [1,0,0,1,0,0,];
      var matrix = "matrix("+
          LearningPathWidget.ScrollerTransMatrix.join(' ')+")";
      LearningPathWidget.SvgGScroller.attr("transform", matrix);

      var scrollerWidth = svgWidth*2-width-MAP_CONSTANTS.lp_scroller_padding*2;
      if (width < svgWidth)
        scrollerWidth = svgWidth - MAP_CONSTANTS.lp_scroller_padding*2;

      if (scrollerWidth < MAP_CONSTANTS.lp_scroller_min_width) {
        scrollerWidth = MAP_CONSTANTS.lp_scroller_min_width;
        LearningPathWidget.BScrollerTooSmall = true;
        LearningPathWidget.ScrollScale =
            (width-svgWidth+MAP_CONSTANTS.lp_scroller_padding*2+
             MAP_CONSTANTS.lp_scroller_min_width)/(svgWidth*1.0);
      }

      LearningPathWidget.SvgGScroller.append("rect")
        .attr("id","lp-scroll-rect")
        .attr("x", MAP_CONSTANTS.lp_scroller_padding)
        .attr("y", svgHeight-MAP_CONSTANTS.lp_scroller_height-
              MAP_CONSTANTS.lp_scroller_padding)
        .attr("height", MAP_CONSTANTS.lp_scroller_height)
        .attr("width",scrollerWidth);

      $("#lp-scroll-rect").on("mousedown",
                              LearningPathWidget.scrollerMouseDown);
    }

    LearningPathWidget.panScroller = function(dx) {
      if (LearningPathWidget.SvgGScroller == null)
        return;

      LearningPathWidget.ScrollerTransMatrix[4] += dx;
      var matrix = "matrix("+
          LearningPathWidget.ScrollerTransMatrix.join(' ')+")";
      LearningPathWidget.SvgGScroller.attr("transform", matrix);
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

    LearningPathWidget.scrollerMouseDown = function(event) {
      if(event.which==1) {  // event.which is 1 -> left btn, 2 -> right btn
        LearningPathWidget.BScrollerMouseDown = true;
        LearningPathWidget.BMouseActive = true;
        Map.DragOldMousePos = Map.WinMousePos;
        Map.DragStartMousePos = Map.WinMousePos;
        event.preventDefault();
      }
    }

    LearningPathWidget.svgMouseDown = function(event) {
      if(event.which==1) {  // event.which is 1 -> left btn, 2 -> right btn
        LearningPathWidget.BMouseDown = true;
        LearningPathWidget.BMouseActive = true;
        Map.DragOldMousePos = Map.WinMousePos;
        Map.DragStartMousePos = Map.WinMousePos;
        $("#learning-path-svg").css("cursor", "move");
        event.preventDefault();
      }
    }

    LearningPathWidget.winMouseUp = function(event) {
      if (LearningPathWidget.BMouseDown) {
        LearningPathWidget.BMouseDown = false;
        Map.DragEndMousePos = Map.WinMousePos;
        $("#learning-path-svg").css("cursor", "default");
      } else if (LearningPathWidget.BScrollerMouseDown) {
        LearningPathWidget.BScrollerMouseDown = false;
        Map.DragEndMousePos = Map.WinMousePos;
      }
    }

    //Only use dx because don't want to move vertically.
    LearningPathWidget.pan = function(dx,dy) {
      if (LearningPathWidget.SvgG == null)
        return;

      var pathlength = LearningPathWidget.pathlength;
      var width = LearningPathWidget.width;
      if (pathlength>width){
	pathlength = pathlength - width;
      } else pathlength=0;


      if (LearningPathWidget.BMouseDown) {
	if ( ((LearningPathWidget.TransMatrix[4]+dx)<-pathlength) || ((LearningPathWidget.TransMatrix[4]+dx)>0) ){
	    dx=0;}
      
        LearningPathWidget.TransMatrix[4] += dx;

        LearningPathWidget.panScroller((dx * -1.0)/
                                       LearningPathWidget.ScrollScale);
      } else if (LearningPathWidget.BScrollerMouseDown) {
	var limit;
    	if (pathlength<width)
	    limit = pathlength;
	else limit = width-MAP_CONSTANTS.lp_scroller_padding-MAP_CONSTANTS.lp_scroller_min_width;
		
	if (((LearningPathWidget.ScrollerTransMatrix[4]+dx)>limit) || ((LearningPathWidget.ScrollerTransMatrix[4]+dx)<0)){
			dx=0;}
    
        LearningPathWidget.TransMatrix[4] +=
            (dx * -1.0 * LearningPathWidget.ScrollScale);
        LearningPathWidget.panScroller(dx);
      }

      if (LearningPathWidget.BMouseDown ||
          LearningPathWidget.BScrollerMouseDown) {
        var matrix = "matrix("+LearningPathWidget.TransMatrix.join(' ')+")";
        LearningPathWidget.SvgG.attr("transform", matrix);
      }
    }
    
    return LearningPathWidget;
  })({});
  
  Map.GroupsWidget = (function(GroupsWidget) {
    GroupsWidget.UsedColor = [];
    GroupsWidget.UnUsedColor = MAP_CONSTANTS.highlight_colors;
    GroupsWidget.NodeColors = {};
    GroupsWidget.BtnDefaultColor = null;
	// current node to display stats about: set to the last node that was clicked
	GroupsWidget.currentNodeId = null;
	// list of student ids to display stats about: set to empty to start (which means all students will be displayed)
	GroupsWidget.selectedStudentIds = null;

    GroupsWidget.update = function() {
      var url = '/graphs/'+ $("#graphData").attr("data-graph_id") +'/groups_widget';
      $.ajax({
        url: url,
        dataType: 'html'
      }).done(function(data) {
        $("#groups-widget-content").html(data);
        d3.selectAll(".group-button").on("click",Map.GroupsWidget.click);
        GroupsWidget.BtnDefaultColor = d3.select(".group-button").select("rect")
          .style("fill");
      })

      GroupsWidget.UsedColor = [];
      GroupsWidget.UnUsedColor = [];
      for (var i=0; i < MAP_CONSTANTS.highlight_colors.length; i++)
        GroupsWidget.UnUsedColor.push(MAP_CONSTANTS.highlight_colors[i]);
      GroupsWidget.NodeColors = {};
    }

    GroupsWidget.click = function() {
      var btn = d3.select(this);
      var btnRect = btn.select("rect");

      var ids = $.parseJSON(btn.attr("data-nodes"));
      var nodesToColor = d3.select("#node-group").selectAll(".map-node-g")
        .filter(function(d) { return ids.indexOf(d.id) > -1 } );

      if ((btnRect.style("fill") == GroupsWidget.BtnDefaultColor) &&
          (GroupsWidget.UnUsedColor.length > 0)) {
        $.ajax("/log/graph/"+this.id+"/highlight"); // log action

        var color = GroupsWidget.UnUsedColor.shift();
        btnRect.style("fill",color);
        color = btnRect.style("fill"); // Get browser's color representation
        GroupsWidget.UsedColor.push(color);

        nodesToColor.each(function(d) {
          if (GroupsWidget.NodeColors[d.id] == undefined)
              GroupsWidget.NodeColors[d.id] = [];

            GroupsWidget.NodeColors[d.id].push(color);

            Map.Node.addOuterCircles(d3.select(this),
                                     GroupsWidget.NodeColors[d.id]);
         });
      } else if (btnRect.style("fill") != GroupsWidget.BtnDefaultColor) {
        $.ajax("/log/graph/"+this.id+"/unhighlight"); // log action

        var color = btnRect.style("fill");
        GroupsWidget.UnUsedColor.push(color);
        GroupsWidget.UsedColor.splice(GroupsWidget.UsedColor.indexOf(color),1);

        btnRect.style("fill",GroupsWidget.BtnDefaultColor);
        nodesToColor.each(function(d) {
          var aryColors = GroupsWidget.NodeColors[d.id];
          GroupsWidget.NodeColors[d.id] = [];

          for (var c = 0; c<aryColors.length; c++) {
            if (aryColors[c] != color)
              GroupsWidget.NodeColors[d.id].push(aryColors[c]);
          }

          Map.Node.addOuterCircles(d3.select(this),
                                   GroupsWidget.NodeColors[d.id]);
        });
      }
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
    
    GroupsWidget.displayTab = function(strContent, strButton) {
	  // displays tab that was just clicked on
      strContent = "#" + strContent;
      $(".side-widget-content").css("display", "none");
      $(strContent).css("display", "block");
    
      strButton = "#" + strButton;
	  if ($(".side-widget-tab-button").data("original-background") == null) {
	      $(".side-widget-tab-button").data("original-background", $(".side-widget-tab-button").css("background-color"));
	  }
      $(".side-widget-tab-button").css("background-color", $(".side-widget-tab-button").data("original-background"));
      $(strButton).css("background-color",$("#groups-widget").css("background-color"));
    }

    GroupsWidget.toggleStudentsList = function() {
	    //display/undisplay student list
	    strButtonName = "show-students-button"
	    strContentName = "student-stats-widget-content"
		strViewName = "student_stats_widget_content"
		
		strCurrentDisplay = $("#" + strContentName).css("display");
		strNewDisplay = "";
		strNewButtonColor = "";
		
		switch(strCurrentDisplay)
		{
		case "none":
		    $("#" + strContentName).css("display", "block");
			if ($("#" + strButtonName).data("original-background") == null) {
			    $("#" + strButtonName).data("original-background", $("#" + strButtonName).css("background-color"));
			}
			$("#" + strButtonName).css("background-color", $("#groups-widget").css("background-color"));
			break;
		case "block":
		    $("#" + strContentName).css("display", "none");
			$("#" + strButtonName).css("background-color", $("#" + strButtonName).data("original-background"));
		    break;
		default:
		}
	}
	
	GroupsWidget.updateStudentsList = function() {
	  // fill students list with students from db, add event listeners to the buttons in the students-list page
      contentName = "student-stats-widget-content";
	  viewName = "student_stats_widget_content";
		
	  var url = '/graphs/'+ $("#graphData").attr("data-graph_id") + '/groups_widget' + "?contentType=" + viewName;
	  
      $.ajax({
        url: url,
        dataType: 'html'
      }).done(function(data) {
		$("#" + contentName).html(data);
		d3.select("#student-select-done-button").on("click",function(){Map.GroupsWidget.selectStudentsRefreshStats()});
		d3.selectAll(".student-button")
		  .attr("selected","true")
		  .select("rect").style("fill","black");
		  
		d3.selectAll(".student-button").on("click",Map.GroupsWidget.clickStudent);
      })
	}
	
	GroupsWidget.updateStatsTab = function(intNodeId, boolForced) { 
	  // update the stats with the new intNodeId, if boolForced
	  contentName = "node-stats-widget-content";
	  viewName = "node_stats_widget_content";
	  
	  if (intNodeId == null && GroupsWidget.currentNodeId == null) return;
	 
	  if (intNodeId != null) {
	    GroupsWidget.currentNodeId = intNodeId;
	  }
	 
	  intNodeId = GroupsWidget.currentNodeId;
	  intStudentIds = GroupsWidget.selectedStudentIds;
	  
	  if (!boolForced) return;
	  
	  var url = '/graphs/'+ $("#graphData").attr("data-graph_id") + '/groups_widget' + "?contentType=" + viewName + "&node_id=" + intNodeId + "&students=" + intStudentIds;
	  
      $.ajax({
        url: url,
        dataType: 'html'
      }).done(function(data) {
		$("#" + contentName).html(data);
      })
	  
	}
	
	GroupsWidget.selectStudentsRefreshStats = function() {
	    console.log("dummy refresh activated!");
		GroupsWidget.selectedStudentIds = "";
		d3.selectAll(".student-button")
		.each(function(d){
		    var g = d3.select(this);
			if (g.attr("selected") == "true") {
			    GroupsWidget.selectedStudentIds = GroupsWidget.selectedStudentIds + g.attr("id") + ",";
			}
		});
		GroupsWidget.selectedStudentIds = GroupsWidget.selectedStudentIds.substring(0,GroupsWidget.selectedStudentIds.length-1);
		console.log("student ids is now: " + GroupsWidget.selectedStudentIds);
		GroupsWidget.updateStatsTab(null, true);
	}
	
	GroupsWidget.clickStudent = function() {
	    var btn = d3.select(this);
        var btnRect = btn.select("rect");
		if (btn.attr("selected") == "" || btn.attr("selected") == "true") {
		    btnRect.style("fill", "white");
			btn.attr("selected","false");
		}
		else {
		    btnRect.style("fill", "black");
			btn.attr("selected","true");
		}
	}
	
	return GroupsWidget;
  })({});
  
  Map.NodeWidget = (function(NodeWidget) {
    NodeWidget.show = function() { Map.hide() }

    NodeWidget.hide = function() { Map.show() }
    
    
    NodeWidget.update = function() {
      var url = '/nodes/'+ $("#graphData").attr("data-node_id") +'/node_widget';
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
          .attr("id", function(d){return "node-"+d.id;})
          .attr("node-id", function(d){return d.id;})
          .attr("transform", function(d){return "translate("+d.x+","+d.y+")";})
          .on("dblclick", Map.Node.dblClick)
          .on("click", Map.Node.click);

      Node.SvgNodes.append("g")
        .attr("id","map-node-outer");

      Node.SvgNodesInner = Node.SvgNodes.append("g")
        .attr("id","map-node-inner");
        
      Node.SvgNodesInner.append("circle")
        .attr("r", MAP_CONSTANTS.node_radius)
        .style("fill",$("#window").css("background-color"));

      Node.SvgNodesInner.append("circle")
        .attr("class", "map-node")
        .attr("r", MAP_CONSTANTS.node_radius)
        .attr("opacity", function(d){if (d.completed=="true") return MAP_CONSTANTS.completed_opacity; return 1.0;});

      Node.SvgNodesInner.append("g")
        .attr("id","map-node-label")
        .each(function(d) {
          var g = d3.select(this);
          var startDY = 0.5 - (d.aryLabel.length/2.0);
          startDY += MAP_CONSTANTS.node_text_dy;
          for(var i=0; i<d.aryLabel.length ;i++) {
            g.append("text").text(d.aryLabel[i])
              .attr("class","map-node-text")
              .attr("dy",(startDY+parseInt(i))+"em")
              .attr("opacity", function(d){if (d.completed=="true") return MAP_CONSTANTS.completed_opacity; return 1.0;});
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

    Node.addOuterCircles = function(svgNode,colors) {
      var colorR = MAP_CONSTANTS.highlight_radius;
      var rotateRadian = Math.PI/2;
      var svgNodeOuterG = svgNode.select("#map-node-outer");

      svgNodeOuterG.selectAll("circle.map-node-highlight").remove();
      svgNodeOuterG.selectAll("path.map-node-highlight").remove();
      
      if (colors.length == 1) { // If one color just want a circle
        svgNodeOuterG.selectAll("circle.map-node-highlight")
          .data(colors).enter().append("circle")
            .attr("class","map-node-highlight")
            .attr("fill",function(d){return d;})
            .style("opacity",MAP_CONSTANTS.highlight_opacity)
            .attr("r",colorR);
      } else {
        svgNodeOuterG.selectAll("path.map-node-highlight")
          .data(colors).enter().append("path")
            .attr("class","map-node-highlight")
            .attr("fill",function(d){return d;})
            .style("opacity",MAP_CONSTANTS.highlight_opacity)
            .attr("d",function(d){
              var outStr = "M0,0 "; //Center

              var i = colors.indexOf(d);
              var len = colors.length;

              // Have -0.001 so have very slight overlap of the circle parts
              var x1 = colorR*Math.cos(Math.PI*2*((i/len)-0.001) - rotateRadian);
              var y1 = colorR*Math.sin(Math.PI*2*((i/len)-0.001) - rotateRadian);
  
              outStr += "L"+x1+","+y1+" ";
  
              var x2 = colorR*Math.cos(Math.PI*2*((i+1)/len) - rotateRadian);
              var y2 = colorR*Math.sin(Math.PI*2*((i+1)/len) - rotateRadian);
  
              outStr += "A"+colorR+","+colorR+" 0 0,1 ";
              outStr += x2+","+y2+" Z";

              return outStr;
            });
      }
    }

    Node.dblClick = function() {
      var id = parseInt(d3.select(this).attr("node-id"));
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

      node_id = this.__data__.id;
      Map.LearningPathWidget.update(node_id); // update LearningPath Widget
      Map.LearningPathWidget.expand(); // expand LearningPath Widget
	  Map.GroupsWidget.updateStatsTab(node_id, true); // update statistics tabs when in instructor mode
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
          .attr("class", function(d){if (Edge.MapNodeId2Node[d.source].completed == "true" && 
		                                 Edge.MapNodeId2Node[d.target].completed != "true") 
										 { return "map-edge-completed"; } else { return "map-edge"; }})
          .attr("x1", function(d){return Edge.MapNodeId2Node[d.source].x;})
          .attr("y1", function(d){return Edge.MapNodeId2Node[d.source].y;})
          .attr("x2", function(d){return Edge.MapNodeId2Node[d.target].x;})
          .attr("y2", function(d){return Edge.MapNodeId2Node[d.target].y;})
          .attr("opacity", function(d){if (Edge.MapNodeId2Node[d.target].completed == "true") 
										   { return MAP_CONSTANTS.completed_opacity; } else { return 1.0; }})
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

  Map.SyllabusView = (function(SyllabusView) {
    SyllabusView.Grid = null;
    SyllabusView.Coord = null;
    SyllabusView.Done = false;
    SyllabusView.IntervalVariable = null;

    SyllabusView.setupLayout = function(crsId) {
      if (SyllabusView.Grid != null)
        return;

      SyllabusView.Grid = [];
      SyllabusView.Coord = {};

      var url = "../courses/"+crsId+"/syllabus.json";
      d3.json(url, function(json) {
        var nodes = json.nodes;
        var edges = json.lines;

        //Code doesn't take into account if two nodes are in the same (row,index)
        for(var i = 0; i < nodes.length; i++) {
          Map.Node.MapId2Data[nodes[i].id].children = [];
          Map.Node.MapId2Data[nodes[i].id].parents = [];

          if (nodes[i].row != undefined) {
            if (SyllabusView.Grid[nodes[i].row] == undefined)
                SyllabusView.Grid[nodes[i].row] = [];

            SyllabusView.Grid[nodes[i].row][nodes[i].index] = nodes[i].id;
          }
        }

        //Clean in case have undefined elements anywhere
        for(var i = 0; i < SyllabusView.Grid.length; i++) {
          if (SyllabusView.Grid[i] == undefined) {
            SyllabusView.Grid.splice(i,1);
            i--;
          } else {
            for(var j = 0; j < SyllabusView.Grid[i].length; j++) {
              if (SyllabusView.Grid[i][j] == undefined) {
                SyllabusView.Grid[i].splice(j,1);
                j--;
              }
            }
          }
        }

        //Update node information to contain parent and children ID lists
        for(var i = 0; i < edges.length; i++) {
          var edge = edges[i];
          if (edge.type == "DependentEdge") {
            Map.Node.MapId2Data[edge.source].children.push(edge.target);
            Map.Node.MapId2Data[edge.target].parents.push(edge.source);
          }
        }

        //Insert parent nodes not in grid for nodes that are in grid
        var usedNodes = [];
        for(var i = 0; i < SyllabusView.Grid.length; i++) {
          //Check if parents are all set
          for(var j = 0; j < SyllabusView.Grid[i].length; j++) {
            var node = Map.Node.MapId2Data[SyllabusView.Grid[i][j]];
            for(var k = 0; k < node.parents.length; k++) {
              if (usedNodes.indexOf(node.parents[k]) < 0) {
                SyllabusView.Grid[i].splice(j,0,node.parents[k]);
                j++;

                usedNodes.push(node.parents[k]);
              }
            }
            usedNodes.push(SyllabusView.Grid[i][j]);
          }
        }

        //Find roots of the nodes not in grid.
        var roots = [];
        for(var i = 0; i < nodes.length; i++) {
          var node = Map.Node.MapId2Data[nodes[i].id];
          if ((usedNodes.indexOf(node.id)) < 0 && (node.parents.length == 0))
            roots.push(node.id);
        }
        
        var currRow = usedNodes.concat([]);
        if (currRow.length == 0) {
            for(var k = 0; k < 5; k++)
              if (roots.length > 0) currRow.push(roots.shift());

          SyllabusView.Grid.push(currRow.concat([]));
          usedNodes = usedNodes.concat(currRow);
        }

        var nextRow = [];
        while (currRow.length > 0) {
          //Build nextRow based on currRow's children with all parents used
          nextRow = [];
          for(var i = 0; i < currRow.length; i++) {
            var children = Map.Node.MapId2Data[currRow[i]].children;
            for(var j = 0; j < children.length; j++) {
              if (usedNodes.indexOf(children[j]) >= 0)
                continue; //Child already seen, don't do again

              //Find if all parents have been added
              var childParents = Map.Node.MapId2Data[children[j]].parents;
              var bParentsNotAllSeen = false;
              for(var k = 0; k < childParents.length; k++) {
                if (usedNodes.indexOf(childParents[k]) < 0)
                  bParentsNotAllSeen = true;
              }

              if (!bParentsNotAllSeen) {
                nextRow.push(children[j]);
                usedNodes.push(children[j]);
              }
            }
          }

          currRow = nextRow.concat([]);
          if (currRow.length == 0) {
            for(var k = 0; k < 5; k++)
              if (roots.length > 0) currRow.push(roots.shift());

            usedNodes = usedNodes.concat(currRow);
          }

          SyllabusView.Grid.push(currRow.concat([]));
        }

        //Set (row,index) for nodes and figure out their coordinates
        for(var i = 0; i < SyllabusView.Grid.length; i++) {
          var spacer = MAP_CONSTANTS.node_radius*4;
          var y = MAP_CONSTANTS.node_radius*2 + spacer*i;
          var xStart = ($("#chart").width()/2.0) -
              (SyllabusView.Grid[i].length/2.0)*spacer;

          for(var j = 0; j < SyllabusView.Grid[i].length; j++) {
            var x = xStart + spacer*j;
            SyllabusView.Coord[SyllabusView.Grid[i][j]] = {};
            SyllabusView.Coord[SyllabusView.Grid[i][j]].x = x;
            SyllabusView.Coord[SyllabusView.Grid[i][j]].y = y;
          }
        }

        SyllabusView.Done = true;
      });
    }

    SyllabusView.transform = function(bSyllabus) {
      if (!Map.SyllabusView.Done || (SyllabusView.IntervalVariable == null))
        return
      
      var crsId = 1; // hardcoded course ID
      $.ajax("/log/course/"+crsId+"/syllabus"); // log action

      Map.Node.SvgNodes.transition()
        .duration(MAP_CONSTANTS.syllabus_transform_duration)
        .attr("transform", function(d){
           var coord = {};
           if (bSyllabus) {
             var coord = Map.SyllabusView.Coord[d.id];

             if (coord == undefined) {
               coord.x = d.x;
               coord.y = d.y;
               Map.SyllabusView.Coord[d.id] = coord;
             }
           } else {
             coord.x = d.x;
             coord.y = d.y;
           }

           return "translate("+coord.x+","+coord.y+")";
         });

      var coordMap = SyllabusView.Coord;
      if (!bSyllabus)
        coordMap = Map.Node.MapId2Data;

      Map.Edge.SvgEdges.transition()
        .duration(MAP_CONSTANTS.syllabus_transform_duration)
        .attr("x1",function(d){return coordMap[d.source].x;})
        .attr("y1",function(d){return coordMap[d.source].y;})
        .attr("x2",function(d){return coordMap[d.target].x;})
        .attr("y2",function(d){return coordMap[d.target].y;});

      clearInterval(SyllabusView.IntervalVariable);
      SyllabusView.IntervalVariable = null;
    }

    return SyllabusView;
  })({});

  Map.toggleLayout = function() {
    Map.BLayoutIsSyllabus = !Map.BLayoutIsSyllabus;

    if (Map.BLayoutIsSyllabus) {
      Map.SyllabusView.setupLayout(1); //TODO: Hardcoding is bad!

      //Use setInterval so can wait until after data done processing
      Map.SyllabusView.IntervalVariable =
          setInterval(function(){Map.SyllabusView.transform(true)},50)
    } else {
      Map.SyllabusView.IntervalVariable = 0;
      Map.SyllabusView.transform(false);
    }
  }
  
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
      
    if (Map.TransMatrix[0]*scale > MAP_CONSTANTS.zoom_in_limit || 
        Map.TransMatrix[0]*scale < MAP_CONSTANTS.zoom_out_limit)
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
    if (Map.BMouseDown) {
      Map.BMouseDown = false;
      Map.DragEndMousePos = Map.WinMousePos;
      $("#svg-chart").css("cursor", "default");
    } else if (Map.LearningPathWidget.BMouseActive) {
      Map.LearningPathWidget.winMouseUp(event);
    }
  }

  Map.winMouseMove = function(e) {
    Map.WinMousePos = [e.clientX,e.clientY];
    if (Map.BMouseDown || Map.LearningPathWidget.BMouseActive) {
      var dx = -1*(Map.DragOldMousePos[0]-Map.WinMousePos[0]);
      var dy = -1*(Map.DragOldMousePos[1]-Map.WinMousePos[1]);
      Map.DragOldMousePos = Map.WinMousePos;

      if (Map.BMouseDown)
        Map.pan(dx,dy);
      else if (Map.LearningPathWidget.BMouseActive)
        Map.LearningPathWidget.pan(dx,dy);
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
      case 32: // space bar
        Map.toggleLayout();
        break;
      default:
        break; // Do nothing
    }
  }

  return Map;
})({}, jQuery);
