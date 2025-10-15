<?php
 $page = 'loads';
 $page_title = "CSW - Data logger";
 include("header.php");

 chdir('/home/pi/bin');

// note the if and else if are not configured for hauliers only the else works

if(isset($_GET['loadNo']))
	$output = shell_exec('./loadSummary.sh '.escapeshellarg($_GET['loadNo']) );
else{
	$output = shell_exec('./tableCustomers.sh \/'.escapeshellarg(strftime('%Y'))); // Get the load data for all blends loads this year
	$output .= shell_exec('./tableLabResults.sh blends');
}
?>

<link href="../dist/css/style.css" rel="stylesheet">

<div class="container-fluid" style="margin-top:10px">
	<div id="output"></div>

	<div id="accordion">
		<div id="panel">
			<h3>Load details</h3>
			<div>
				<form id="addLoadForm" class="form-inline myform" action="loads2.php" method="POST">
					<div class="form-group">
						<label class="sr-only" for="addload">Load Number</label>
						<input type="number" class="form-control" id="addload" name="addload" placeholder="Load Number" autofocus>
					</div>
					<div class="form-group">
						<label class="sr-only" for="id">Invoice</label>
						<input type="text" class="form-control" id="invoice" name="invoice" placeholder="Invoice / PO">
					</div>
					<div class="form-group">
						<label class="sr-only" for="id">Tanker ID</label>
						<input type="text" class="form-control" id="id" name="id" placeholder="Tanker ID">
					</div>
					<div class="form-group">
						<label class="sr-only" for="cert">Tanker cert</label>
						<input type="text" class="form-control" id="cert" name="cert" placeholder="Tanker Cert">
					</div>
					<div class="form-group">
						<label class="sr-only" for="loader">Loader</label>
						<input type="text" class="form-control" id="loader" name="loader" placeholder="Loaders Initials">
					</div>
					<div class="form-group">
						<label class="sr-only" for="sampler">Samplers</label>
						<input type="text" class="form-control" id="sampler" name="sampler" placeholder="Samplers Initials">
					</div>
					<div class="form-group">
						<label class="sr-only" for="driver">Driver</label>
						<input type="text" class="form-control" id="driver" name="driver" placeholder="Driver / Haulier">
					</div>
					<div class="form-group">
						<button type="submit" name="addbtn" value="yes" class="btn btn-primary"><span class="glyphicon glyphicon-floppy-disk"></span>  Save</button>
					</div>
				</form>

				<form id="filterForm" class="form-inline myform" action="loads2.php" method="POST">
					<div class="form-group">
						<label class="sr-only" for="filter">filter</label>
						<input type="search" class="form-control" id="filter" name="filter" placeholder="Search term">
					</div>
					<div class="form-group">
						<button type="submit" name="filterbtn" value="yes" class="btn btn-primary">
							<span class="glyphicon glyphicon-search"></span> Search
						</button>
						<button type="button" class="btn btn-primary" data-toggle="modal" data-target="#myModal">
							<span class="glyphicon glyphicon-question-sign"></span> Help</button>
						<img id="loading" src="/images/ajax-loader.gif" alt="spinner"/>
					</div>
				</form>

				<div id="loadTable" class="container-fluid"><?php echo $output; ?></div>


			</div>
		</div>
	</div>
</div>



<!-- Modal -->
<div id="myModal" class="modal fade" role="dialog">
  <div class="modal-dialog">

    <!-- Modal content-->
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal">&times;</button>
        <h4 class="modal-title">Regex Search Help</h4>
      </div>
      <div class="modal-body">
	<p>2017 : Will find anything containing 2017</p>
	<p>^2017 : Will find a load beginning with 2017</p>
	<p>224[12] : Will find anything containing 2241 or 2242</p>
        <p>229[0-9] : Will find anything containing 2290-2299</p>
	<p>13/10/2017 : All loads loaded on the 13th October 2017</p>
	<p>13-10-2017 : All loads delivered on the 13th October 2017</p>
        <p>.*\t.*\tA\t.*\t.*\t.*\t.*\t.*\t.*\t.*\t.*\t : All loads loaded on Point A</p>
        <p>.*\t.*\t.*\t2\t.*\t.*\t.*\t.*\t.*\t.*\t.*\t : All loads loaded with Tank 2</p>
	<p>.*\t.*\t.*\t*\t.*\t.*\t.*\t.*\t.*\t.*\tPAWEL\t.*\t : All loads loaded by PAWEL</p>
	<p>.*\t.*\t.*\t*\t.*\t.*\t.*\t.*\t.*\t.*\t.*\tCM\t : All loads Sampled by CM</p>
	<p>Luke$ : Will find all loads delivered by Luke</p>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
      </div>
    </div>

  </div>
</div>
</div>

<script type="text/javascript" src="dist/js/loadsHaulier.js"></script>
<script type="text/javascript" src="dist/js/jquery.tablesorter.js"></script>
<script src="dist/js/bootstrap3.min.js"></script>

	</body>
</html>
