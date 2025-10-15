<?php
// Using a ~ as a delimintor as , and | are in the data and ? threw errors
$output = shell_exec('./index.sh');
$test = explode("~",$output);
echo json_encode($test);
/*
Alternative to above using individual shell_exec commands:
shell_exec('./volumesHomePage.sh; ./storageToTable.sh; ./averageFlowRate.sh 30');
$command = escapeshellcmd('./overviewLoads.sh');
$loads = shell_exec($command);
$command = escapeshellcmd('./overviewGate.sh');
$gate = shell_exec($command);
$command = escapeshellcmd('./overviewCalloff.sh');
$callOff = shell_exec($command);
$command = escapeshellcmd('./overviewCIP.sh');
$cip = shell_exec($command);
$flowrate = shell_exec('tail -n 1 /home/pi/bin/dailyFlowRate.dat | cut -d" " -f2');
$myArray = array( $loads, $gate, $callOff, $cip, $flowrate);
echo json_encode($myArray);
*/
?>
