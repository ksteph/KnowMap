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
    $("#top-widget-button").on("click", Map.LearningPathWidget.toggle);
    $("#side-widget-button").on("click", Map.GroupsWidget.toggle);
    //$("#side-widget").animate({right: -$("#side-widget").outerWidth()});
    //$("#side-widget").css("right", -$("#side-widget").outerWidth());
    //$("#side-widget-button").animate({left: -$("#side-widget-button").outerWidth()-1});
    //$("#side-widget-button").css("left", -$("#side-widget-button").outerWidth()-1);
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
    LearningPathWidget.update = function() {
      node_id = $("#graphData").attr("data-node_id");
      $("#top-widget-content").html( "<img src='/assets/path.png'/ > Node id: " + node_id);
    }
    
    LearningPathWidget.expand = function() {
      if(!$("#top-widget-content").is(":visible"))
        LearningPathWidget.toggle();
    }

    LearningPathWidget.collapse = function() {
      if($("#top-widget-content").is(":visible"))
        LearningPathWidget.toggle();
    }
    
    LearningPathWidget.toggle = function(event) {
      if(!$("#top-widget-content").is(":visible"))
          $("#top-widget-button").css("border-top","1px solid black");
      $("#top-widget-content").animate({height: 'toggle'}, null, null, function() {
        if($("#top-widget-content").is(":visible")) {
          $("#top-widget-button").html("&#x2234;");
        } else {
          $("#top-widget-button").html("&#x2235;");
          $("#top-widget-button").css("border-top", "none");
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
        $("#side-widget-content").html(data);
      })
    }
    
    GroupsWidget.expand = function() {
      if(parseInt($("#side-widget").css("right"),10)!=0)
        GroupsWidget.toggle();
    }

    GroupsWidget.collapse = function() {
      if(parseInt($("#side-widget").css("right"),10)==0)
        GroupsWidget.toggle();
    }
    
    GroupsWidget.toggle = function(event) {
      if(parseInt($("#side-widget").css("right"),10)!=0) {
          $("#side-widget-button").animate({left: parseInt($("#side-widget-button").css('left'),10) == -1 ? -$("#side-widget-button").outerWidth()-1 : -1});
        }
        $("#side-widget").animate({right: parseInt($("#side-widget").css('right'),10) == 0 ? -$("#side-widget").outerWidth() : 0},  function() {
          if(parseInt($("#side-widget").css("right"),10)==0) {
            $("#side-widget-button").html("&raquo;");
          } else {
            $("#side-widget-button").animate({left: parseInt($("#side-widget-button").css('left'),10) == -1 ? -$("#side-widget-button").outerWidth()-1 : -1});
            $("#side-widget-button").html("&laquo;");
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
  
  return Map;
})({}, jQuery);
