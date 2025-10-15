<?php
if(isset($_POST['open']))  shell_exec("command.sh ' ' 'INTERNAL'" );
if(isset($_POST['close']))  shell_exec("closeGate.py" );
if(isset($_POST['reset'])) shell_exec ("resetGSM.py" );

$output = shell_exec("tac call_list.txt | head -n 50 | cut -f1,3");
?>

<!DOCTYPE html>
<html lang="en">
	<head><title>CSW Gate</title>
	<body>
		<div style="text-align: center"><h3>CSW Gate - GSM Call List</h3></div>
		<form action="index.php" method="POST">
		<button type="submit" class="btn btn-primary" name="open" id="open" value="open">Open Gate</button>
		<button type="submit" class="btn btn-primary" name="close" id="close" value="close">Close Gate</button>
		<button type="submit" class="btn btn-primary" name="reset" id="reset" value="reset">Reset Gate</button>
		<button type="submit" class="btn btn-primary" name="status" id="status" value="status">Relay Status</button>
	</form>
	<pre><?php echo $output; ?></pre>

<?php
if(isset($_POST['status'])){
  $status = trim(shell_exec("relayStatus.py"));
  echo "<script type='text/javascript'>alert('$status');</script>";
}
?>

	</body>
</html>
