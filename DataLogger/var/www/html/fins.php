<?php
$command = escapeshellcmd('/home/pi/bin/cswJson.js');
$output = shell_exec($command);
echo $output;
?>
