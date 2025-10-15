<?php
chdir('/home/pi/bin');

// if days is set there was a slider change and we need to execute storageToTable
if(isset($_GET['days']))
	shell_exec("./storageToTable.sh ".escapeshellarg($_GET['days']) );

if($_GET['graph'] == "total")
	shell_exec("./plotTotal.pg");
else
	shell_exec("./plotTankSummary.pg");
?>
