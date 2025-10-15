<?php
chdir('/home/pi/bin');

if(isset($_POST['invDate']))
	echo shell_exec('./invoiceDetails.sh '.escapeshellarg($_POST['invDate']) );
else if(isset($_POST['filter']))
	echo shell_exec('./tableLoads.sh '.escapeshellarg($_POST['filter']) );
else if(isset($_POST['loadno']))
	echo shell_exec('./loadSummary.sh '.escapeshellarg($_POST['loadno']) );
else if(isset($_POST['tankerCert']))
	echo shell_exec('./certSummary.sh '.escapeshellarg($_POST['tankerCert']) );
else if(isset($_POST["addload"])){
	if($_POST["newCert"]!=""){
		$cert=$_POST["newCert"];
		shell_exec('./updateTanker.sh '.escapeshellarg($cert)." ".escapeshellarg($_POST['id'])." "."-");
	}
	else
		$cert=$_POST["cert"];
	shell_exec('./updateLoad.sh '.escapeshellarg($_POST["addload"])." ".escapeshellarg($_POST["id"])." "
		.escapeshellarg($cert)." ".escapeshellarg($_POST["loader"])." "
		.escapeshellarg($_POST["sampler"])." ".escapeshellarg($_POST['driver'])." ".escapeshellarg($_POST['delDate']));
//	echo shell_exec("./tableLoads.sh");
	echo shell_exec('./tableLoads.sh .'.escapeshellarg(strftime('%Y')));
}
//shell_exec('./tableLoads.sh .'.escapeshellarg(strftime('%Y')));
?>
