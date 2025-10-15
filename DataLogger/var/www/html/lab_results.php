<?php
 $page = "lab_results";
 $page_title = "CSW - Data logger";
 include("header.php");
 // this limits the page view to only this years samples. NOTE the use of a '/' before the year, this limits cases like cert 72018 appearing in 2018
 $output = shell_exec('/home/pi/bin/tableLabResults.sh /'.escapeshellarg(strftime('%Y')));
// $output = shell_exec('/home/pi/bin/tableLabResults.sh /'.escapeshellarg(strftime('%Y')).' 1323'); // restrict number of lines

 // note the start of a new year will cause errors as the tablesorter failes with an empty table. Work aroung temporary switch to all certificates:
 //  $output = shell_exec('/home/pi/bin/tableLabResults.sh');
?>

<link href="../dist/css/style.css" rel="stylesheet">

<div class="container-fluid text-center">
	<div id="output"></div>
	<h3>Lab Results</h3>
</div>

<div class="container-fluid myform">
        <form id="filterForm" class="form-inline" action="lab_results.php" method="POST">
                <div class="form-group">
                        <label class="sr-only" for="filter">filter</label>
                        <input type="search" class="form-control" id="filter" name="filter" placeholder="Search term" autofocus>
                        <button type="submit" class="btn btn-primary"><span class="glyphicon glyphicon-search"></span> Search</button>
                </div>
        </form>

	<div class="form-inline">
		<button id="price" type="submit" class="btn btn-primary" value="price">Lab Prices</button>
		<button id="cost" type="submit" class="btn btn-primary" value="cost">Invoice Cost Summary</button>
		<button id="missing" type="submit" class="btn btn-primary" value="missing">Missing Reports</button>
		<button id="exceptions" type="submit" class="btn btn-primary" value="exceptions">Exceptions</button>
		<button id="failure" type="submit" class="btn btn-primary" value="failure">Failure Stats</button>
		<button id="duplicates" type="submit" class="btn btn-primary" value="duplicates">Check for duplicates</button>
		<button id="retests" type="submit" class="btn btn-primary" value="retests">View retests</button>
		<img id="loading" src="/images/ajax-loader.gif" alt="spinner"/>
	</div>

</div>

<div id="labTable" class="container-fluid">
<?php echo "$output";?>
</div>

<script>
// function to colour the failures yellow
// coli, ecoli, enter & pseudo td's all have the class 'critical'
$.fn.colorFailures = function () {
  $("#myTable td.critical").each(function() {
    var val =  parseInt($(this).html());
    if(val > 0){
	$(this).css('background', 'yellow');
    }
  });
};


$(function() {
  $().colorFailures(); // change failures to yellow after page load

  var $loading = $("#loading").hide();
  $(document).ajaxStart(function() {
    $loading.show();
  }).ajaxStop(function() {
    $loading.hide();
  });
  $("#myTable").tablesorter({dateFormat:"uk", sortList:[[0, 1]]});
  $("#filterForm").submit(function(event) {
    event.preventDefault();
    var data = $(this).serialize();
    $.ajax({url:"getLabDetails.php", type:"post", data:data, success:function(response) {
      $("#labTable").html(response);
      $("#myTable").tablesorter({dateFormat:"uk", sortList:[[0, 1]]});
      $().colorFailures(); // change failures to yellow after AJAX search
    }});
  });
  $("#price, #cost, #missing, #failure, #retests, #duplicates, #exceptions").click(function() {
    var data = $(this).val();
    $.ajax({url:"getLabDetails.php", type:"post", data:data, success:function(response) {
      $("#labTable").html(response);
//	Uncomment line to be able to sort the cost summary
//      $("#myTable").tablesorter({dateFormat:"uk", sortList:[[0, 0]]});
    }});
  });


  // on change event of the dropdown we insert via php / bash script for the lab prices
  $(document).on('change', '#year', function(){

    var data = $(this).serialize();

    $.ajax({url:"getLabDetails.php", type:"get", data:data, success:function(response) {
      $("#labTable").html(response);
    }});

  });
  // end of on change event

});
</script>

<script type="text/javascript" src="dist/js/jquery.tablesorter.js"></script>
<script src="dist/js/bootstrap3.min.js"></script>
	</body>
</html>
