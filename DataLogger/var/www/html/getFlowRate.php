<?php
chdir('/home/pi/bin');

// if days is set there was a slider change and we need to execute storageToTable
if(isset($_GET['days'])){
	printf("test");
	shell_exec("./averageFlowRate.sh ".escapeshellarg($_GET['days']) );
}
?>
