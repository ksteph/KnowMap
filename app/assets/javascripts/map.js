$(function() {
  // Code that should execute after the DOM is ready
});

function setupMap() {
  $("#top-widget-button").on("click", toggleTopWidget);
  $("#side-widget-button").on("click", toggleSideWidget);
  $("#side-widget").animate({right: -$("#side-widget").outerWidth()});
  $("#side-widget-button").animate({left: -$("#side-widget-button").outerWidth()-1});
}

function toggleTopWidget(event) {
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

function showTopWidget() {
  if(!$("#top-widget-content").is(":visible"))
    toggleTopWidget();
}

function hideTopWidget() {
  if($("#top-widget-content").is(":visible"))
    toggleTopWidget();
}

function toggleSideWidget(event) {
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

function showSideWidget() {
  if(parseInt($("#side-widget").css("right"),10)!=0)
    toggleSideWidget();
}

function hideSideWidget() {
  if(parseInt($("#side-widget").css("right"),10)==0)
    toggleSideWidget();
}

function hideMap() {
  $("div#map").css("display","none");
  $("div#node").css("display","block");
}
    
function showMap() {
  $("div#map").css("display","block");
  $("div#node").css("display","none");
}

function showNode() { hideMap(); }
function hideNode() { showMap(); }
