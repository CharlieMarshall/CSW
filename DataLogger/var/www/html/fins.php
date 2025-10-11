<?php
chdir(SCRIPTS_DIR);
$command = escapeshellcmd('cswJson.js');
$output = shell_exec($command);
echo $output;
?>
