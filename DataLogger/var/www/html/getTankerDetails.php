<?php
chdir('/home/pi/bin');

if(isset($_POST['filter']))
	$output = shell_exec('./tableTankers.sh '.escapeshellarg($_POST['filter']));
else if(isset($_POST['certNo'])) {
	shell_exec('./updateTanker.sh '.escapeshellarg($_POST['certNo'])." ".escapeshellarg($_POST['id'])." ".escapeshellarg($_POST['cipdate']));
	$output = shell_exec('./tableTankers.sh');
}
echo $output;
?>
