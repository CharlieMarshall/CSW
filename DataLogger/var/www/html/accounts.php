<?php
 $page = "accounts";
 $page_title = "CSW - Data logger";
 include("header.php");

 $locale = 'en_GB.utf-8';
 setlocale(LC_ALL, $locale);
 putenv('LC_ALL='.$locale);

 chdir('/home/pi/bin');

// $currentMonth = strftime('%m');
// $currentYear = strftime('%Y');

 $output = shell_exec("./volumes.sh.all -y ".escapeshellarg(strftime('%Y')));
?>
<script deger src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/3.7.0/chart.min.js"></script>

<div class="container-fluid text-center">

	<div id="output"></div>

	<h3>Financial Summary</h3>
	<form class="form-inline text-center" action="accounts.php" method="POST">
        	<div class="form-group">
                        <select class="form-control" id="year" name="year">
				<optgroup label="Calendar Years">
<?php
  for($x=date("Y"); $x>2015; $x--)
    echo '<option value="'.$x.'">'.$x.'</option>';
?>
                	        	<option value="all">All</option>

				</optgroup>
				<optgroup label="Tax Years">
<?php
  $currentMonth = date('m');

  if ($currentMonth < "4") {
    $taxYear=date("Y")-1;
  }
  else{
    $taxYear=date("Y");
  }

  for($x=$taxYear; $x>2014; $x--)
    echo '<option value="'.$x.'/'.($x+1).'">'.$x.' / '.($x+1).'</option>';
?>
				</optgroup>
                        </select>
		</div>
	</form>
</div>

<div class="container-fluid myform">
        <form id="ovForm" class="form-inline" action="accounts.php" method="POST">
	    <div class="form-group">
                <label class="sr-only" for="yearOh">Year</label>
                <select class="form-control" id="yearOh" name="yearOh">
<?php
  for($x=date("Y"); $x>2015; $x--)
    echo '<option value="'.$x.'">'.$x.'</option>';
?>
                </select>
            </div>
            <div class="form-group">
		<select class="form-control" id="overheadMonth" name="overheadMonth">
<?php
  $months = array(1 => 'Jan', 2 => 'Feb', 3 => 'Mar', 4 => 'Apr', 5 => 'May', 6 => 'Jun', 7 => 'Jul', 8 => 'Aug', 9 => 'Sep', 10 => 'Oct', 11 => 'Nov', 12 => 'Dec');

  foreach ($months as $num => $name)
    printf('<option value="%u">%s</option>', $num, $name);
?>
		</select>

            </div>
            <div class="form-group">
                <label class="sr-only" for="overhead">Overheads</label>
                <input type="text" class="form-control" id="overhead" name="overhead" placeholder="Overheads" autofocus>
            </div>
            <div class="form-group">
                    <button type="submit" class="btn btn-primary" id="submit" name="submit" value="yes">
			<span class="glyphicon glyphicon-floppy-disk"></span>  Save</button>
<!-- is this button doing anything??? -->
	            <button id="testBtn" class="btn btn-primary">Refresh Chart</button>

            </div>
        </form>
</div>

<div class="container-fluid">
        <div class="row centered">
                <div id="inputTable" class="col-md-12" style="padding-left:0px">
                        <?php echo "$output";?>
                </div>
<!--                <div class="col-md-5" style="padding-left:0px"><img class="img-responsive center-block" src="/images/capital.svg" alt=""/></div> -->
        </div>
</div>

<!--
<div class="container-fluid">
	<img class="img-responsive center-block" src="/images/volumes.svg" alt=""/>
</div>
-->

<div class="container-fluid">
	<canvas id="myChart" width="300" height="100"></canvas>
</div>


<script>
// $("#year").val( <?php echo $currentYear; ?> );
// $("#volMonth")[0].selectedIndex = <?php echo $currentMonth; ?>-1;
// $("#overheadMonth")[0].selectedIndex = <?php echo $currentMonth; ?>-1;
var d = new Date;
$(function() {
  $("#year").val(d.getFullYear());
  $("#yearOh").val(d.getFullYear());
  $("#overheadMonth")[0].selectedIndex = d.getMonth();
  $("#year").change(function() {
    var data = $(this).serialize();
    $.ajax({url:"getYear.php", type:"get", data:data, success:function(response) {
      $("#inputTable").html(response);
    }});
  });
// had to replace this line as we have the refresh chart button embedded within the form, although it is not actually related
//  $("#ovForm").submit(function(event) {
  $("#submit").click(function(event) {
    event.preventDefault();
    var data = $("#ovForm").serialize();
    $.ajax({url:"addOverhead.php", type:"post", data:data, success:function(response) {
      $("#inputTable").html(response);
    }});
  });
});
</script>
<script src="dist/js/bootstrap3.min.js"></script>
<script src="dist/js/chart.js"></script>

	</body>
</html>
