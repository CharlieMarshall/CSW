<?php
	header('Content-type:application/json;charset=utf-8');

	if(isset($_GET['load']))
		echo shell_exec("/home/pi/bin/getLoad.sh ".escapeshellarg( $_GET['load'] ));
?>
