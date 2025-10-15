<?php
$locale = 'en_GB.utf-8';
setlocale(LC_ALL, $locale);
putenv('LC_ALL='.$locale);

if(isset($_POST["sample"]))
	shell_exec("/home/pi/bin/printLabel.py ".escapeshellarg($_POST['sample']) );

?>

<html>
  <link href="dist/css/bootstrap3.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css">
  <link rel="stylesheet" href="dist/css/mystyles.css">
  <link href="../dist/css/style.css" rel="stylesheet">
  <head></head>
  <body>
    <!-- these can't be in the footer as it leads to error -->
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
    <script src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.12.1/jquery-ui.min.js"></script>
    <script type="text/javascript" src="//cdnjs.cloudflare.com/ajax/libs/jqueryui-touch-punch/0.2.3/jquery.ui.touch-punch.min.js"></script>

    <div id="panel"><h3 class="text-center">Print Sample Labels</h3><div>

    <div class="container-fluid" style="margin-top:10px">
        <form id="sampleForm" class=".form-horizontal myform" action="delnoteSubmit.php" method="POST">
          <div class="form-group">
            <label for="" class="col-md-2 control-label">Sample Number</label>
            <div class="col-md-3"><input type="number" class="form-control" id="sample" name="sample" placeholder="Load Number" autofocus></div>
            <button type="submit" name="addbtn" value="yes" class="btn btn-primary">Submit
          </div>
        </form>
     </div>

<script src="dist/js/bootstrap3.min.js"></script>

<body>
</html>
