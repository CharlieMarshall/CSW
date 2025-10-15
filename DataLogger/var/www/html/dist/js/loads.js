var d = new Date();
$(function() {
  $("#accordion > div").accordion({collapsible:true, heightStyle:"content", header:"h3"});
  $("#delDate").datepicker({dateFormat:"dd-mm-yy", constrainInput:false});
  if ($("#myTable tbody tr").length > 0)
    $("#myTable").tablesorter({dateFormat:"uk", sortList:[[0, 1]]});
  if ($("#labTable tbody tr").length > 0)
    $("#labTable").tablesorter({dateFormat:"uk", sortList:[[4, 0]]});
  if ($("#fillTable tbody tr").length > 0)
    $("#fillTable").tablesorter({dateFormat:"uk", sortList:[[0, 0]]});
  //$("#invDate").datepicker({dateFormat:'dd-mm-yy'}).val(d.getDate() + "-" + (d.getMonth()+1) + "-" + d.getFullYear());
  // we use splice to get the last 2 digits ( https://stackoverflow.com/questions/3605214/javascript-add-leading-zeroes-to-date ) 
  // we need a leading zero for the month, day seems ok with out, WHEN TYPING INTO THE BOX
  $("#invDate").datepicker({dateFormat:'dd-mm-yy'}).val(('0' + d.getDate()).slice(-2) + "-" + ('0' + (d.getMonth()+1)).slice(-2) + '-' + d.getFullYear() );
  $("#volMonth")[0].selectedIndex = d.getMonth();
  $("#id").on("change", function() {
    var certid = $(this).val();
    $.ajax({url:"getCerts.php", type:"get", data:{id:certid}, dataType:"json", success:function(response) {
      var select = "";
      for (var i = 0; i < response.length; i++) {
        var id = response[i];
        select += "<option value='" + id + "'>" + id + "</option>";
      }
      $("#cert").html(select);
    }});
  });
  // copy loader value to sampler and driver on change
  $("#loader").on("change", function() {
    var $loader = $('#loader');
    var $sampler = $('#sampler');
    var $driver = $('#driver');
    $sampler.val($loader.val());
    $driver.val($loader.val());
  });
  // copy Driver value to sampler on driver
  $("#sampler").on("change", function() {
    var $sampler = $('#sampler');
    var $driver = $('#driver');
    if ( ($sampler.val() != "JM") && ($sampler.val() != "CM") && ($sampler.val() != "jm") && ($sampler.val() != "cm") )  {
      $driver.val($sampler.val());
    }
  });

  $("#addload").on("blur", function() {
    var load = $(this).val();
    if (load == "") {
      $("#addLoadForm").trigger("reset");
      $("#cert").html("<option value='' disabled selected>Tanker Cert</option>");
    } else {
        $.ajax({url:"getLoad.php", type:"get", data:{load:load}, dataType:"json", success:function(response) {
          $("#id").val(response.tanker);
          $("#cert").html("<option value='" + response.cert + "'>" + response.cert + "</option>");
          $("#loader").val(response.loader);
          $("#sampler").val(response.sampler);
          $("#driver").val(response.driver);
          $("#delDate").val(response.delDate);
      }});
      $('#newCert').css("display", "none");
    }
  });
  $(document).on('click', 'table a', function (event) {
    event.preventDefault();
    var key = $(this).attr("data-type");
    var data = $(this).attr("data-value");
    var obj = {};
    obj[key] = data;
    $.ajax({url:"getLoadDetails.php", type:"post", data:obj, success:function(response) {
      $("#loadTable").html(response);
      if ($("#labTable tbody tr").length > 0)
        $("#labTable").tablesorter({dateFormat:"uk", sortList:[[4, 0]]});
      if ($("#fillTable tbody tr").length > 0)
        $("#fillTable").tablesorter({dateFormat:"uk", sortList:[[0, 0]]});
    }});
  });
  $("#addLoadForm, #filterForm").on("submit", function(event) {
    event.preventDefault();
    var data = $(this).serialize();
    $.ajax({url:"getLoadDetails.php", type:"post", data:data, success:function(response) {
      $("#loadTable").html(response);
      $("#addLoadForm").trigger("reset");
      $("#cert").html("<option value='' disabled selected>Tanker Cert</option>");
      $("#addload").focus();
      $("#myTable").tablesorter({dateFormat:"uk", sortList:[[0, 1]]});
    }});
  });
  $("#volMonth").on("change", function() {
    var data = $(this).serialize();
    $.ajax({url:"getLoadsByDay.php", type:"get", data:data, success:function(response) {
      d = new Date();
      $("#daily").attr("src", "/images/volumesDaily.svg?" + d.getTime());
    }});
  });
  $("#next-day").on("click", function(event) {
    var date = $("#invDate").datepicker("getDate");
    date.setDate(date.getDate() + 1);
    $("#invDate").datepicker("setDate", date);
  });
  $("#prev-day").on("click", function(event) {
    var date = $("#invDate").datepicker("getDate");
    date.setDate(date.getDate() - 1);
    $("#invDate").datepicker("setDate", date);
  });
  $("#invDate").on("change", function(event) {
    $.fn.getInvoiceDetails();
  });
  $("#invoiceForm").submit(function(event) {
    $.fn.getInvoiceDetails();
  });
  $.fn.getInvoiceDetails = function() {
    event.preventDefault();
    var data = $("#invoiceForm").serialize();
    $.ajax({url:"getLoadDetails.php", type:"post", data:data, success:function(response) {
      $("#display").html(response);
    }});
  };
  var $loading = $('#loading').hide();
  $(document).ajaxStart(function () {
    $loading.show();
  })
  .ajaxStop(function () {
    $loading.hide();
  });
});
