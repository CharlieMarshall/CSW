<?php
$locale = 'en_GB.utf-8';
setlocale(LC_ALL, $locale);
putenv('LC_ALL='.$locale);
$date=date("d-m-Y");

if(isset($_POST["save"])){
        shell_exec('/home/pi/bin/updateLoad.sh '.escapeshellarg($_POST["load"])." ".escapeshellarg($_POST["tankerID"])." "
                .escapeshellarg($_POST["tankerCert"])." ".escapeshellarg($_POST["loader"])." "
                .escapeshellarg($_POST["sampler"])." ".escapeshellarg($_POST['driver'])." ".escapeshellarg($_POST['delDate']) );
}
if(isset($_POST["printDel"])){
	shell_exec("/home/pi/bin/printPOD.py ".escapeshellarg($_POST['load'])." ".escapeshellarg($_POST['tankerID'])." ".escapeshellarg($_POST['tankerCert'])." ".escapeshellarg($_POST['seal'])." ".$date." &" );

        shell_exec('/home/pi/bin/updateLoad.sh '.escapeshellarg($_POST["load"])." ".escapeshellarg($_POST["tankerID"])." "
                .escapeshellarg($_POST["tankerCert"])." ".escapeshellarg($_POST["loader"])." "
                .escapeshellarg($_POST["sampler"])." ".escapeshellarg($_POST['driver'])." ".$date );
}
if(isset($_POST["printSample"])){
        shell_exec("/home/pi/bin/printLabel.py ".escapeshellarg($_POST['load'])." &" );
}


if(isset($_POST["printAll"])){
        shell_exec("/home/pi/bin/printPOD.py ".escapeshellarg($_POST['load'])." ".escapeshellarg($_POST['tankerID'])." ".escapeshellarg($_POST['tankerCert'])." ".escapeshellarg($_POST['seal'])." ".$date." &" );

        shell_exec('/home/pi/bin/updateLoad.sh '.escapeshellarg($_POST["load"])." ".escapeshellarg($_POST["tankerID"])." "
                .escapeshellarg($_POST["tankerCert"])." ".escapeshellarg($_POST["loader"])." "
                .escapeshellarg($_POST["sampler"])." ".escapeshellarg($_POST['driver'])." ".$date );

        shell_exec("/home/pi/bin/printLabel.py ".escapeshellarg($_POST['load'])." &" );
}
?>

<html>
  <link href="dist/css/bootstrap3.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css">
  <link rel="stylesheet" href="dist/css/mystyles.css">
  <link href="dist/css/style.css" rel="stylesheet">
  <head></head>

  <body>
    <!-- these can't be in the footer as it leads to error -->
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
    <script src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.12.1/jquery-ui.min.js"></script>
    <script type="text/javascript" src="//cdnjs.cloudflare.com/ajax/libs/jqueryui-touch-punch/0.2.3/jquery.ui.touch-punch.min.js"></script>

<script>
$(function() {
  $("#tankerID").on("change", function() {
    var tankerID = $(this).val();
    $.ajax({url:"getCert.php", type:"get", data:{id:tankerID}, dataType:"json", success:function(response) {
      $("#tankerCert").val(response);
    }});
  });

  $("#samplerCB").on("change", function() {
    if(document.getElementById('samplerCB').checked)
      $("#sampler").val( $("#loader").val() );
    else
      $("#sampler").val("");
  });

  $("#driverCB").on("change", function() {
    if(document.getElementById('driverCB').checked)
      $("#driver").val( $("#sampler").val() );
    else
      $("#driver").val("");
  });



  $("#load").on("blur", function() {
    var load = $(this).val();
    if (load == "") {
      $("#loadForm").trigger("reset");
      $("#tankerCert").val("");
    } else {
        $.ajax({url:"getLoad.php", type:"get", data:{load:load}, dataType:"json", success:function(response) {
          $("#tankerID").val(response.tanker);
          $("#tankerCert").val(response.cert);
          $("#loader").val(response.loader);
          $("#sampler").val(response.sampler);
          $("#driver").val(response.driver);
          $("#delDate").val(response.delDate);
      }});
    }
  });



});
</script>

    <div class="text-center"><h3 style="margin-top:0">Operate pumps:</h3>Note there is a 5 second delay in updating the screen!<div>

    <div class="text-center">
      <iframe src="http://192.168.100.4/operation.html" scrolling="no" frameborder="0" border="0" height="495" width ="820";> Your browser doesn't support iframes.</iframe>
    </div>

    <div class="container-fluid" style="margin-top:10px">
        <form id="loadForm" class="form-horizontal" action="printDel.php" method="POST">

          <div class="form-group">
            <label class="control-label col-sm-2" for="load">Load Number</label>
            <div class="col-sm-9"><input type="number" class="form-control" id="load" name="load" placeholder="Load Number" autofocus tabindex="1"></div>
          </div>


          <div id="panel" class="text-center"><h3>Enter Connection Details:</h3><div>


          <div class="form-group">
            <label class="control-label col-sm-2" for="tankerID">Tanker ID</label>
            <div class="col-sm-9">
              <label class="sr-only" for="tankerID">Tanker ID</label>
              <select class="form-control" id="tankerID" name="tankerID" tabindex="2">
                                                        <option value="" disabled selected>Tanker ID</option>
                                                        <option value="GEZ0001S">1S</option>
                                                        <option value="GEZ0002S">2S</option>
                                                        <option value="GEZ0003S">3S</option>
                                                        <option value="GEZ0004S">4S</option>
                                                        <option value="GEZ0005S">5S</option>
                                                </select>
            </div>
          </div>
<!--

          <div class="form-group">
            <label class="control-label col-sm-2" for="tankerCert">Tanker Cert</label>
            <div class="col-sm-9">
              <select id="tankerCert" name="tankerCert" class="form-control" onchange="showfield(this.options[this.selectedIndex].value)">
                <option value="" disabled selected>Tanker Cert</option>
              </select>
            </div>
          </div>
-->


          <div class="form-group">
            <label class="control-label col-sm-2" for="tankerCert">Tanker Cert</label>
            <div class="col-sm-9"><input type="tankerCert" class="form-control" id="tankerCert" name="tankerCert" placeholder="Tanker Cert" readonly tabindex=-1></div>
          </div>


          <div class="form-group">
            <label for="loader" class="col-md-2 control-label">Loaders Initials</label>
            <div class="col-sm-9"><input type="text" class="form-control" id="loader" name="loader" placeholder="Loader" tabindex="3"></div>
          </div>


          <div class="form-group">
            <div class="col-sm-offset-2 col-sm-1"><button type="submit" name="save" value="yes" class="btn btn-primary" tabindex="4">Save</button></div>
          </div>



          <div class="text-center"><h3>Enter Disconnection Details:</h3><div>

          <div class="form-group">
            <label for="sampler" class="col-md-2 control-label">Samplers Initials</label>
            <div class="col-sm-9">
              <div class="col-sm-3 checkbox"><input type="checkbox" id="samplerCB"/>Same As Loader</div>
              <div class="col-sm-9"><input type="text" class="form-control" id="sampler" name="sampler" placeholder="Sampler"></div>
            </div>

          </div>

          <div class="form-group">
            <label class="control-label col-sm-2" for="seal">Seal Number</label>
            <div class="col-sm-9"><div class="col-sm-offset-3 col-sm-9"><input type="number" class="form-control" id="seal" name="seal" placeholder="Seal"></div></div>
          </div>

          <div class="form-group">
            <label for="driver" class="col-md-2 control-label">Driver</label>
            <div class="col-sm-9">
              <div class="col-sm-3 checkbox"><input type="checkbox" id="driverCB" value="">Same as Driver</div>
              <div class="col-sm-9"><input type="text" class="form-control" id="driver" name="driver" placeholder="Driver"></div>
            </div>
          </div>

          <div class="form-group">
            <input type="hidden" id="delDate" name="delDate"></div>
          </div>


          <div class="form-group">
            <div class="col-sm-offset-2 col-sm-1"><button type="submit" name="printAll" value="yes" class="btn btn-primary">Print All</button></div>
            <div class="col-sm-2"><button type="submit" name="printDel" value="yes" class="btn btn-primary">Print Delivery Note</button></div>
            <div class="col-sm-2"><button type="submit" name="printSample" value="yes" class="btn btn-primary">Print Sample Labels</button></div>
          </div>
       </form>
     </div>


</div>
    <div class="container-fluid" style="margin-top:10px">

        </form>

<script src="dist/js/bootstrap3.min.js"></script>

<body>
</html>
