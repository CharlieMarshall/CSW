<?php
 $page = 'loads';
 $page_title = "CSW - Data logger";
 include("header.php");

 chdir('/home/pi/bin');
?>

<link href="../dist/css/style.css" rel="stylesheet">

<div class="container-fluid" style="margin-top:10px">
	<div id="output"></div>

<script type="text/javascript">
	function showfield(name){
		if(name=='New Cert')document.getElementById('newCert').style.display="";
		else document.getElementById('newCert').style.display="none";
	}
	function hidefield() {
		document.getElementById('newCert').style.display='none';
	}
</script>

  <body onload="hidefield()">







<form class="form-horizontal" role="form">


    <div class="form-group">
      <label for="" class="col-md-2 control-label">Point</label>
      <div class="btn-group-lg" data-toggle="buttons" role="group" aria-label="pointSelector">
                        <div class="col-md-offset-1 col-md-1">
				<label class="btn btn-primary"><input type="radio" name="options" id="A" autocomplete="off">A</label>
			</div>
			<div class="col-md-offset-1 col-md-1">
	                        <label class="btn btn-primary"><input type="radio" name="options" id="B" autocomplete="off">B</label>
			</div>
      </div>
    </div>


    <div class="form-group">
      <label for="" class="col-md-2 control-label">Load Number</label>
      <div class="col-md-3"><input type="number" class="form-control" id="addload" name="addload" placeholder="Load Number"></div>
    </div>

    <div class="form-group">
	<b><span class="col-md-2 control-label">Tanker</span></b>
        <div class="col-md-6">
            <div class="form-group row">
                <label for="inputKey" class="col-md-1 control-label">ID</label>
                <div class="col-md-2">
						<select class="form-control" id="id" name="id">
							<option value="" disabled selected>Tanker ID</option>
							<option value="GEZ0001S">1S</option>
							<option value="GEZ0002S">2S</option>
							<option value="GEZ0003S">3S</option>
							<option value="GEZ0004S">4S</option>
							<option value="GEZ0005S">5S</option>
						</select>


                </div>
                <label for="inputValue" class="col-md-1 control-label">Cert</label>
                <div class="col-md-2">

					<select id="cert" name="cert" class="form-control">
                                                        <option value="" disabled selected>Tanker Cert</option>
                                                </select>


                </div>
            </div>
        </div>
    </div>


    <div class="form-group">
      <label for="loader" class="col-md-2 control-label">Loader</label>
      <div class="col-md-3"><input type="text" class="form-control" id="loader" name="loader" placeholder="Loader"></div>
    </div>

    <div class="form-group">
      <label for="sampler" class="col-md-2 control-label">Samplers</label>
      <div class="col-md-3"><input type="text" class="form-control" id="sampler" name="sampler" placeholder="Samplers Name"></div>
    </div>

    <div class="form-group">
      <label for="driver" class="col-md-2 control-label">Driver</label>
      <div class="col-md-3"><input type="text" class="form-control" id="driver" name="driver" placeholder="Driver"></div>
    </div>
    <div class="form-group">
      <div class="col-md-offset-2 col-md-3"><button type="submit" name="addbtn" value="yes" class="btn btn-primary">Submit</div>
    </div>

</form>






	<div id="panel"><h3>Load details</h3><div>

	<form id="addLoadForm" class=".form-horizontal myform" action="loads.php" method="POST">

		<div class="form-group">
			<div class="btn-group-lg" data-toggle="buttons" role="group" aria-label="pointSelector">
				<label class="btn btn-primary"><input type="radio" name="options" id="A" autocomplete="off">A</label>
				<label class="btn btn-primary"><input type="radio" name="options" id="B" autocomplete="off">B</label>
			</div>
		</div>
	</form>

	<div id="panel"><h3>Print Sample Labels</h3><div>

	<form id="sampleForm" class=".form-horizontal myform" action="delnoteSubmit.php" method="POST">
		<div class="form-group">
			<label for="" class="col-md-2 control-label">Sample Number</label>
			<div class="col-md-3"><input type="number" class="form-control" id="sample" name="sample" placeholder="Load Number" autofocus></div>
			<button type="submit" name="addbtn" value="yes" class="btn btn-primary">Submit
		</div>
	</form>
</div>

<script type="text/javascript" src="dist/js/loads.js"></script>
<script src="dist/js/bootstrap3.min.js"></script>

	</body>
</html>
