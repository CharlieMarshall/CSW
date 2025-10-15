<?php
 $page = 'loads';
 $page_title = "CSW - Data logger";
 include("header.php");

 chdir('/home/pi/bin');
// if ( $sendInvoice == "yes" ) { $output = "<pre class=\"text-left\">".shell_exec('./invoice.sh '.escapeshellarg($invDate) )."</pre>"; }

if(isset($_GET['loadNo']))
	$output = shell_exec('./loadSummary.sh '.escapeshellarg($_GET['loadNo']) );
else if(isset($_GET['tankerCert']))
	$output = shell_exec('./certSummary.sh '.escapeshellarg($_GET['tankerCert']) );
else
	$output = shell_exec('./tableLoads.sh \/'.escapeshellarg(strftime('%Y'))); // Get the load data for anything this year
//	$output = shell_exec('./tableLoads.sh .'.escapeshellarg(strftime('%Y'))); // Get the load data for anything this year
$invoice = shell_exec('./invoiceDetails.sh ' ); // populate the invoice div with todays details
shell_exec('./plotVolumeDaily.pg');
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


	<div id="accordion">
		<div id="panel">
			<h3>Load details</h3>
			<div>
				<form id="addLoadForm" class="form-inline myform" action="loads.php" method="POST">
					<div class="form-group">
						<label class="sr-only" for="addload">Load Number</label>
						<input type="number" class="form-control" id="addload" name="addload" placeholder="Load Number" autofocus>
					</div>
					<div class="form-group">
						<label class="sr-only" for="id">Tanker ID</label>
						<select class="form-control" id="id" name="id">
							<option value="" disabled selected>Tanker ID</option>
							<option value="GEZ0001S">1S</option>
							<option value="GEZ0002S">2S</option>
							<option value="GEZ0003S">3S</option>
							<option value="GEZ0004S">4S</option>
							<option value="GEZ0005S">5S</option>
						</select>
					</div>
					<div class="form-group">
						<label class="sr-only" for="cert">Tanker Cert</label>
						<select id="cert" name="cert" class="form-control" onchange="showfield(this.options[this.selectedIndex].value)">
							<option value="" disabled selected>Tanker Cert</option>
						</select>
						<input type="number" class="form-control" id="newCert" type="text" name="newCert" placeholder="Enter Cert"/>
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
						<input type="text" class="form-control" id="driver" name="driver" placeholder="Driver">
					</div>
					<div class="form-group">
						<label class="sr-only" for="delDate">Delivery Date</label>
						<input type="text" class="form-control" id="delDate" name="delDate" placeholder="Change del date" tabindex="-1">
					</div>
					<div class="form-group">
						<button type="submit" name="addbtn" value="yes" class="btn btn-primary"><span class="glyphicon glyphicon-floppy-disk"></span>  Save</button>
					</div>
				</form>

				<form id="filterForm" class="form-inline myform" action="loads.php" method="POST">
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
		<div id="invoice">
			<h3>View Invoice</h3>
                        <div>
				<form id="invoiceForm" class="form-inline myform">
			                <div class="form-group">
                        			<button id="prev-day" type="submit" class="btn btn-primary" name="viewInvoice" value="yes">
							<span class="glyphicon glyphicon-minus"></span></button>
			                        <button id="next-day" type="submit" class="btn btn-primary" name="viewInvoice" value="yes">
							<span class="glyphicon glyphicon-plus"></span></button>
			                </div>
					<div class="form-group">
						<label class="sr-only" for="invDate">Date</label>
						<input type="text" class="form-control" id="invDate" name="invDate">
					</div>
			<!--		<div class="form-group">
						<button type="submit" id="viewInvoice" name="viewInvoice" value="yes" class="btn btn-primary">View Invoice</button>
					</div>
						<div class="form-group">
				                <button type="submit" name="sendInvoice" value="yes" class="btn btn-primary">Send Invoice</button>
				        </div>
			-->
				</form>
				<div><pre id="display"><?php echo $invoice; ?></pre></div>
			</div>
		</div>

		<div id="loadsGraph">
			<h3>Loads per month</h3>
			<div>
	                        <form class="form-inline text-center">
        	                    <div class="form-group">Loads delivered daily during the month of &nbsp;
                	                <label class="sr-only" for="volMonth">Month of</label>
                        	        <select class="form-control" id="volMonth" name="volMonth">
                                		<option value="01">Jan</option>
	                	                <option value="02">Feb</option>
	        	                        <option value="03">Mar</option>
        	        	                <option value="04">Apr</option>
                	        	        <option value="05">May</option>
                        	        	<option value="06">Jun</option>
	                        	        <option value="07">Jul</option>
        	                        	<option value="08">Aug</option>
	                	                <option value="09">Sep</option>
        	                	        <option value="10">Oct</option>
	        	                       	<option value="11">Nov</option>
        	        	                <option value="12">Dec</option>
                	                </select>
	                            </div>
        	                </form>
                	        <img id="daily" class="img-responsive center-block" src="/images/volumesDaily.svg" alt=""/>
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



<script type="text/javascript" src="dist/js/loads.js"></script>
<script type="text/javascript" src="dist/js/jquery.tablesorter.js"></script>
<script src="dist/js/bootstrap3.min.js"></script>

	</body>
</html>
