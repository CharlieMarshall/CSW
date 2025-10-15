function getPLCData(){
 $.ajax({
  url: 'finsDual.php',
  type: 'get',
  datatype: 'json',
  success: function(data){
   var myData = $.parseJSON(data);
   $("#pointTable").html(tableMarkupFromObjectArray(myData[0]));     // point array
   $("#tankTable").html(tableMarkupFromObjectArray(myData[1]));      // tank array

   // NOTE we place the misc inside an array to avoid amending tableMarkupFromObjectArray()
   $("#miscTable").html(tableMarkupFromObjectArray([myData[2]]));    // misc array

   // populate forecast data except flowrate, this happens in the getShellData function
   $("#buffer").val( (myData[1][0]["Level (m3)"] + myData[1][1]["Level (m3)"] + myData[1][2]["Level (m3)"]).toFixed(1) );
   $("#maxbuffer").val(myData[1][0]["Set Level (m3)"][0] + myData[1][1]["Set Level (m3)"][0] + myData[1][2]["Set Level (m3)"][0]);
   $("#ecoFillOn").val(myData[2]["Eco Fill From (hrs)"][0]);
   $("#ecoFillOff").val(myData[2]["Eco Fill To (hrs)"][0]);
   $("#pointA").html("<b>A:</b><br>Ref: " + myData[0][0]["Refresco Load No"][0] + "<br>Aqua-D: " + myData[0][0]["AD Load No"][0] );
   $("#pointB").html("<b>A:</b><br>Ref: " + myData[0][1]["Refresco Load No"][0] + "<br>Aqua-D: " + myData[0][1]["AD Load No"][0] );
//   $("#pointB").html("<b>B:</b> " + myData[0][1]["Refresco Load No"][0]);   

   // draw tanker levels
   fillTanker("canvasA", "tankerA", myData[0][0]["Litres Pumped"]);
   fillTanker("canvasB", "tankerB", myData[0][1]["Litres Pumped"]);

   fillTank("canvas1", "tankImg1", myData[1][0]["Level (m3)"], myData[1][0]["Set Level (m3)"][0]);
   fillTank("canvas2", "tankImg2", myData[1][1]["Level (m3)"], myData[1][1]["Set Level (m3)"][0]);
   fillTank("canvas3", "tankImg3", myData[1][2]["Level (m3)"], myData[1][2]["Set Level (m3)"][0]);

   showFilling(arrowAnim1, myData[1][0]["Inlet Valve"])
   showFilling(arrowAnim2, myData[1][1]["Inlet Valve"])
   showFilling(arrowAnim3, myData[1][2]["Inlet Valve"])

// cant remember what is happening here
//   document.getElementById("#incTankers").value = myData[2]["Eco Fill To (hrs)"][0];

   $("#time").html("Last Updated: " + new Date().toLocaleString());                     // show time we last updated / refreshed our data

  },
  complete:function(data){
//   setTimeout(getPLCData,5000); // max speed!
     updateForecast();
  }
 });
}

function fillTanker(canvas, image, value){
  var canvas = document.getElementById(canvas);
  var ctx = canvas.getContext("2d");
  var image = document.getElementById(image);

  var cylinderHeight = 58; // total px of the cylinder
  // not sure why it does not work without setting the canvas size here, though I could do this via css
  canvas.width = image.width;
  canvas.height = image.height;

  var pixelFill = cylinderHeight - ((cylinderHeight / 29500) * value);
  ctx.fillStyle = "white";
  ctx.fillRect(0, 20, image.width, pixelFill); // pad 20px to clear the text title eg B and another 20px to reach the top of the cylinder

// potentially use this instead of a blue background div to draw the water
  var waterFill = cylinderHeight - ((cylinderHeight / 29500) * (29500 - value) );
  ctx.fillStyle = "#4C76A5"; // blue to use
  ctx.fillRect(0, 20 + pixelFill, image.width, waterFill); // draw the water in the tank, pad 20px and the empty tank space from above
////////////
}

function fillTank(canvas, image, level, setLevel){
  var canvas = document.getElementById(canvas);
  var ctx = canvas.getContext("2d");
  var image = document.getElementById(image);

  var topOfTank = 21; // px from the top of the image to the maximum water level
  var tankHeight = 221; // total number of px to fill the tank with water
  canvas.width = image.width;
  canvas.height = image.height;

  var pixelFill = tankHeight - ((tankHeight / 120) * level);
  ctx.fillStyle = "#a9a9a9";
  ctx.fillRect(0, topOfTank, image.width, pixelFill); // draw the empty grey space in the tank

// potentially use this instead of a blue background div ////////
  var waterFill = tankHeight - ((tankHeight / 120) * (120 - level) );
  ctx.fillStyle = "#4C76A5"; // blue to use
  ctx.fillRect(0, topOfTank + pixelFill, image.width, waterFill); // draw the water in the tank
////////

  var setLevelLine = (tankHeight + topOfTank) - ((tankHeight / 120) * setLevel);
  ctx.beginPath();
  ctx.lineWidth = "3";
  ctx.strokeStyle = "black";
  ctx.moveTo(0, setLevelLine);
  ctx.lineTo(canvas.width, setLevelLine);
  ctx.stroke(); // draw the set level line
}

function showFilling(div, value) {
  if (value == "OPEN") {
    div.style.visibility = "visible";
  }
  else
    div.style.visibility = "hidden";
} 

function getShellData(){
 $.ajax({
  url: 'getShellData.php',
  type: 'get',
  datatype: 'json',
  success: function(data){
   var myData = $.parseJSON(data);

   $("#flowrate").val( parseInt(myData[4]).toFixed(1));

   // update our pre tags
   $("#preLoads").html(myData[0]);
   $("#preGate").html(myData[1]);
   $("#preCallOff").html(myData[2]);
   $("#preCIP").html(myData[3]);

/*
   document.getElementById("tankSummary").src = "/images/tank_summary.svg?t=" + timestamp;
   document.getElementById("frGraph").src = "/images/fr.svg?t=" + timestamp;
   document.getElementById("waterImg").src = "/images/water.svg?t=" + timestamp;
   document.getElementById("volImg").src = "/images/volumes.svg?t=" + timestamp;
   document.getElementById("daily").src = "/images/volumesDaily.svg?t=" + timestamp;
   document.getElementById("boreElec").src = "/images/boreholeElec.svg?t=" + timestamp;
   document.getElementById("fillmode").src = "/images/elec.svg?t=" + timestamp;
*/
   var timestamp = new Date().getTime(); // we append a timestamp to the query string so images can not be cached
   $("#tankSummary").attr("src", "/images/tank_summary.svg?t=" + timestamp);
   $("#frGraph").attr("src", "/images/fr.svg?t=" + timestamp);
   $("#waterImg").attr("src", "/images/water.svg?t=" + timestamp);
   $("#volImg").attr("src", "/images/volumes.svg?t=" + timestamp);
   $("#daily").attr("src","/images/volumesDaily.svg?t=" + timestamp);
   $("#boreElec").attr("src", "/images/boreholeElec.svg?t=" + timestamp);
   $("#fillmode").attr("src","/images/elec.svg?t=" + timestamp);

  }
 });
}

function tableMarkupFromObjectArray(obj) {
      let headers = `
      ${Object.keys(obj[0]).map((col) => {
        return `<th>${col}</th>`;
      }).join('')}`;

      let content = obj.map((row, idx) => {
        return `<tr>
          ${Object.values(row).map((datum) => {
            if( Array.isArray(datum) )
                return `<td>${datum[0]}</td>`
            else
              return `<td>${datum}</td>`
          }).join('')}
        </tr>`
      }).join('')

      let tablemarkup = `
      <table class="table table-condensed table-bordered table-hover table-striped">
        ${headers}
        ${content}
      </table>`
    return tablemarkup
}

function updateForecast() { 
  var tankerbuffer = 0;
  if ($("#incTankers").prop("checked")) {
    tankerbuffer = $("#tankerTextLabel").text();
  }
  var data = $("#forecastForm").serializeArray();
  data.push({name:"tankerbuffer", value:tankerbuffer});
  $.ajax({url:"getForecast.php", type:"get", data:data, success:function(response) {
    d = new Date();
    $("#graph").attr("src", "/images/forecast.svg?" + d.getTime());
  }});
} 

$(function() { // document.ready()
  getPLCData();

  var $loading = $('#loading').hide();
  $(document).ajaxStart(function () {
    $loading.show();
  })
  .ajaxStop(function () {
    $loading.hide();
  });

  $("#accordion > div").accordion({collapsible:true, heightStyle:"content", header:"h3"});

  $("#refreshPLCBtn").click(function(){
    getPLCData();
  });

  $("#refreshAllBtn").click(function(){
    getPLCData();
    getShellData();
  });

  $("#startforecast").datetimepicker({dateFormat:"dd/mm/yy"});
  $("#tanks, #total").checkboxradio({icon:false});

  var d = new Date();
  $("#volMonth")[0].selectedIndex = d.getMonth();
  $("#volYear").val(d.getFullYear());

  $("#volMonth, #volYear").change(function() {
//    var data = $(this).serialize();
    var data = $("#monthlyStats").serializeArray();
    $.ajax({url:"getLoadsByDay.php", type:"get", data:data, success:function(response) {
      d = new Date();
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
      d = new Date();
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
      d = new Date();
      $("#frGraph").attr("src", "/images/fr.svg?" + d.getTime());
    }});
  });
// end of flowrate slider

  $("#tanks, #total").change(function() {
    var graph = $("input[type=radio][name=graphGroup]:checked").val();
    $.ajax({url:"getTankGraph.php", type:"get", data:{graph:graph}, success:function(response) {
      d = new Date();
      $("#tankSummary").attr("src", "/images/tank_summary.svg?" + d.getTime());
    }});
  });

  $("#startforecast, #buffer, #maxbuffer, #flowrate, #incTankers, #ecoFillOn, #ecoFillOff").change( updateForecast );

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

});
