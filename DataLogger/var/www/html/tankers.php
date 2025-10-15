<?php
 $page = "tankers";
 $page_title = "CSW - Data logger";
 include("header.php");
 $output = shell_exec('/home/pi/bin/tableTankers.sh');
?>

<link href="../dist/css/style.css" rel="stylesheet">

<div class="container-fluid text-center">
	<div id="output"></div>
	<h3>Tankers</h3>
</div>


<div class="container-fluid myform">

	<form id="addTankerForm" class="form-inline" action="tankers.php" method="POST">
		<div class="form-group">
	        <label class="sr-only" for="certNo">Tanker Certificate</label>
	        <input type="number" class="form-control" id="certNo" name="certNo" placeholder="Tanker certificate" autofocus>
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
	        <label class="sr-only" for="cipdate">CIP date</label>
	        <input type="text" class="form-control" id="cipdate" name="cipdate" placeholder="CIP date & finished time">
	    </div>
	    <div class="form-group">
		    <button type="submit" class="btn btn-primary"><span class="glyphicon glyphicon-floppy-disk"></span> Save</button>
	    </div>
	</form>

	<form id="filterForm" class="form-inline" action="tankers.php" method="POST">
		<div class="form-group">
			<label class="sr-only" for="filter">Filter</label>
			<input type="search" class="form-control" id="filter" name="filter" placeholder="Search term">
		</div>
		<div class="form-group">
			<button type="submit" class="btn btn-primary"><span class="glyphicon glyphicon-search"></span> Search</button>
		</div>
	</form>
</div>

<div id="myTable" class="container-fluid">
	<?php echo "$output";?>
</div>

<script>
$(function() {
  $("#tankerTable").tablesorter({dateFormat:"uk", sortList:[[0, 1]]});
  $("#filterForm, #addTankerForm").submit(function(event) {
    event.preventDefault();
    var data = $(this).serialize();
    $.ajax({url:"getTankerDetails.php", type:"post", data:data, success:function(response) {
      $("#myTable").html(response);
      $("#tankerTable").tablesorter({dateFormat:"uk", sortList:[[0, 1]]});
      $("#addTankerForm").trigger("reset");
      $("#addTankerForm").find("input").first().focus();
    }});
  });
  $("#certNo").blur(function() {
    var cert = $(this).val();
    if (cert == "") {
      $("#addTankerForm").trigger("reset");
    } else {
      $.ajax({url:"getTanker.php", type:"get", data:{certNo:cert}, dataType:"json", success:function(response) {
        $("#id").val(response.tanker);
        $("#cipdate").val(response.cipdate);
      }});
    }
  });
});
</script>
<script type="text/javascript" src="dist/js/jquery.tablesorter.js"></script>
<script src="dist/js/bootstrap3.min.js"></script>
	</body>
</html>
