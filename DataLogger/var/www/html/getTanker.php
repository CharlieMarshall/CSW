<?php
chdir(SCRIPTS_DIR);
header('Content-type:application/json;charset=utf-8');

if(isset($_GET['certNo']))
	echo shell_exec("getTanker.sh ".escapeshellarg($_GET['certNo']));
?>
