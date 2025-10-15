$(function() {
  $("#accordion > div").accordion({collapsible:true, heightStyle:"content", header:"h3"});
  $("head").append('<meta http-equiv="refresh" content="900">');
  $("#startforecast").datetimepicker({dateFormat:"dd/mm/yy"});
  $("#tanks, #total").checkboxradio({icon:false});

  var d = new Date;
  $("#volMonth")[0].selectedIndex = d.getMonth();
  $("#volYear").val(d.getFullYear());

  $("#volMonth, #volYear").change(function() {
//    var data = $(this).serialize();
    var data = $("#monthlyStats").serializeArray();
    $.ajax({url:"getLoadsByDay.php", type:"get", data:data, success:function(response) {
      d = new Date;
      $("#daily").attr("src", "/images/volumesDaily.svg?" + d.getTime());
      $("#fillmode").attr("src", "/images/elec.svg?" + d.getTime());
      $("#boreElec").attr("src", "/images/boreholeElec.svg?" + d.getTime());
    }});
  });
// tank level slider
  var handle = $("#custom-handle");
  $("#slider").slider({min:1, max:90, value:1, create:function() {
    handle.text($(this).slider("value"));
  }, slide:function(event, ui) {
    handle.text(ui.value);
  }});
  $("#slider").on("slidestop", function(event, ui) {
    var days = $("#slider").slider("option", "value");
    var graph = $("input[type=radio][name=graphGroup]:checked").val();
    $.ajax({url:"getTankGraph.php", type:"get", data:{days:days, graph:graph}, success:function(response) {
      d = new Date;
      $("#tankSummary").attr("src", "/images/tank_summary.svg?" + d.getTime());
    }});
  });
// end of tank level slider
// flowrate slider
  var handleFR = $("#flowRate-handle");
  $("#sliderFR").slider({min:1, max:500, value:30, create:function() {
    handleFR.text($(this).slider("value"));
  }, slide:function(event, ui) {
    handleFR.text(ui.value);
  }});
  $("#sliderFR").on("slidestop", function(event, ui) {
    var FRdays = $("#sliderFR").slider("option", "value");
    $.ajax({url:"getFlowRate.php", type:"get", data:{days:FRdays}, success:function(response) {
      d = new Date;
      $("#frGraph").attr("src", "/images/fr.svg?" + d.getTime());
    }});
  });
// end of flowrate slider
  $("#tanks, #total").change(function() {
    var graph = $("input[type=radio][name=graphGroup]:checked").val();
    $.ajax({url:"getTankGraph.php", type:"get", data:{graph:graph}, success:function(response) {
      d = new Date;
      $("#tankSummary").attr("src", "/images/tank_summary.svg?" + d.getTime());
    }});
  });
  $("#startforecast, #buffer, #maxbuffer, #flowrate, #incTankers, #ecoFillOn, #ecoFillOff").change(function() {
    var tankerbuffer = 0;
    if ($("#incTankers").prop("checked")) {
      tankerbuffer = $("#tankerTextLabel").text();
    }
    var data = $("#forecastForm").serializeArray();
    data.push({name:"tankerbuffer", value:tankerbuffer});
    $.ajax({url:"getForecast.php", type:"get", data:data, success:function(response) {
      d = new Date;
      $("#graph").attr("src", "/images/forecast.svg?" + d.getTime());
    }});
  });
  $("input[name=flow], input[name=channel]").change(function() {
    var $url = "http://www.timeview2.net/xdq/Cotswold%20Springs/COTSWOLDS%20SPRING/DODINGTON%20SPRING/IMAGES/";
    var $selectedflow = $("input[name=flow]:checked").val();
    var $selectedChannel = $("input[name=channel]:checked").val();
    $("#flowIMG").attr("src", $url + $selectedflow + $selectedChannel);
    $("#flowlink").attr("href", $url + $selectedflow + $selectedChannel);
  });
  $.getJSON("http://environment.data.gov.uk/flood-monitoring/id/stations/53131", function(data) {
    var latestDate = data["items"]["measures"]["2"]["latestReading"]["dateTime"].replace(/T/g, " ").slice(0, -4);
    var latestRead = data["items"]["measures"]["2"]["latestReading"]["value"];
    var maxOnRecord = data["items"]["stageScale"]["maxOnRecord"]["value"];
    var minOnRecord = data["items"]["stageScale"]["minOnRecord"]["value"];
    var typicalHigh = data["items"]["stageScale"]["typicalRangeHigh"];
    var typicalLow = data["items"]["stageScale"]["typicalRangeLow"];
    google.charts.load("current", {"packages":["gauge"]});
    google.charts.setOnLoadCallback(drawChart);
    function drawChart() {
      var data = google.visualization.arrayToDataTable([["Label", "Value"], ["Height", latestRead]]);
      var options = {min:minOnRecord, max:maxOnRecord, redFrom:minOnRecord, redTo:typicalLow, yellowFrom:typicalLow, yellowTo:typicalHigh, greenFrom:typicalHigh, greenTo:maxOnRecord, minorTicks:5};
      var chart = new google.visualization.Gauge(document.getElementById("chart_div"));
      chart.draw(data, options);
      $("#chart_div").append("<p>Recorded: " + latestDate + "</p>");
    }
  });
  var $loading = $('#loading').hide();
  $(document).ajaxStart(function () {
    $loading.show();
  })
  .ajaxStop(function () {
    $loading.hide();
  });
});
