<?php
chdir('/home/pi/bin');
if(isset($_GET['volMonth'])){
	shell_exec( "./writeVolDaily.sh ".escapeshellarg( $_GET['volMonth'] )." ".escapeshellarg( $_GET['volYear'] ).
		" & ./fillingMode.sh ".escapeshellarg( $_GET['volMonth'] )." ".escapeshellarg( $_GET['volYear'] ).
		" & ./boreholeElec.sh ".escapeshellarg( $_GET['volMonth'] )." ".escapeshellarg( $_GET['volYear'] ).
		" & wait" );
}
?>
