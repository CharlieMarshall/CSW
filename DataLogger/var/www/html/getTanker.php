<?php
header('Content-type:application/json;charset=utf-8');

if(isset($_GET['certNo']))
	echo shell_exec("/home/pi/bin/getTanker.sh ".escapeshellarg($_GET['certNo']));
?>
