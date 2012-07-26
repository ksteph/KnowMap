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
  Map.setup = function() {
    //console.log("called Map.setup()");
    $("#learning-path-widget-button").on("click", Map.LearningPathWidget.toggle);
    $("#groups-widget-button").on("click", Map.GroupsWidget.toggle);
    //$("#groups-widget").animate({right: -$("#groups-widget").outerWidth()});
    //$("#groups-widget").css("right", -$("#groups-widget").outerWidth());
    //$("#groups-widget-button").animate({left: -$("#groups-widget-button").outerWidth()-1});
    //$("#groups-widget-button").css("left", -$("#groups-widget-button").outerWidth()-1);
    //Map.GroupsWidget.expand();
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
      doMapStuff();
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
    Node.click = function() {
      node_id = this.__data__.id;
      Map.LearningPathWidget.update(node_id); // update LearningPath Widget
      Map.LearningPathWidget.expand(); // expand LearningPath Widget
      // TODO: implement highlighting path on map
      $.ajax({
        url: '/nodes/'+node_id+'/learning_path',
        success: function(data) {
          console.log(data.nodes)
          console.log(data.edges)
        }
      });
      console.log("node " + node_id + " was clicked");
    }
    
    return Node;
  })({});
  
  return Map;
})({}, jQuery);
