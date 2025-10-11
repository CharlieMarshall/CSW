<?php
chdir(SCRIPTS_DIR);
	header('Content-type:application/json;charset=utf-8');

	if(isset($_GET['load']))
		echo shell_exec("getLoad.sh ".escapeshellarg( $_GET['load'] ));
?>
