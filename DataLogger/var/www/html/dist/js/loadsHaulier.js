var d = new Date();
$(function() {
  $("#accordion > div").accordion({collapsible:true, heightStyle:"content", header:"h3"});
  if ($("#myTable tbody tr").length > 0)
    $("#myTable").tablesorter({dateFormat:"uk", sortList:[[0, 1]]});
  if ($("#labTable tbody tr").length > 0)
    $("#labTable").tablesorter({dateFormat:"uk", sortList:[[4, 0]]});
  if ($("#fillTable tbody tr").length > 0)
    $("#fillTable").tablesorter({dateFormat:"uk", sortList:[[0, 0]]});

  // copy loader value to sampler and driver on change
  $("#loader").on("change", function() {
    var $loader = $('#loader');
    var $sampler = $('#sampler');
    $sampler.val($loader.val());
  });

  $("#addload").on("blur", function() {
    var load = $(this).val();
    if (load == "") {
      $("#addLoadForm").trigger("reset");
      $("#cert").html("<option value='' disabled selected>Tanker Cert</option>");
    } else {
        $.ajax({url:"getLoadHaulier.php", type:"get", data:{load:load}, dataType:"json", success:function(response) {
          $("#invoice").val(response.invoice);
          $("#id").val(response.tanker);
          $("#cert").val(response.cert);
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
    $.ajax({url:"getLoadDetailsHaulier.php", type:"post", data:obj, success:function(response) {
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
    $.ajax({url:"getLoadDetailsHaulier.php", type:"post", data:data, success:function(response) {
      $("#loadTable").html(response);
      $("#addLoadForm").trigger("reset");
      $("#addload").focus();
      $("#myTable").tablesorter({dateFormat:"uk", sortList:[[0, 1]]});
    }});
  });

  var $loading = $('#loading').hide();
  $(document).ajaxStart(function () {
    $loading.show();
  })
  .ajaxStop(function () {
    $loading.hide();
  });
});
