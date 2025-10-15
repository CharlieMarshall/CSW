<?php
$command = escapeshellcmd('/home/pi/bin/cswJsonDual.js');
$output = shell_exec($command);
echo $output;
?>
