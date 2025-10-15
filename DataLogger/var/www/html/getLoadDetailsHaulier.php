<?php
chdir('/home/pi/bin');

if(isset($_POST['filter']))
	echo shell_exec('./tableLoads.sh '.escapeshellarg($_POST['filter']) );
else if(isset($_POST['loadno']))
	echo shell_exec('./loadSummary.sh '.escapeshellarg($_POST['loadno']) );
else if(isset($_POST['tankerCert']))
	echo shell_exec('./certSummary.sh '.escapeshellarg($_POST['tankerCert']) );
else if(isset($_POST["addload"])){
	shell_exec('./updateLoadHaulier.sh '.escapeshellarg($_POST["addload"])." ".escapeshellarg($_POST['invoice'])." ".escapeshellarg($_POST["id"])." "
		.escapeshellarg($_POST["cert"])." ".escapeshellarg($_POST["loader"])." ".escapeshellarg($_POST["sampler"])." ".escapeshellarg($_POST['driver']) );
	echo shell_exec('./tableCustomers.sh .'.escapeshellarg(strftime('%Y')));
	echo shell_exec('./tableLabResults.sh blends');
}
?>
