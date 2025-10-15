<?php
	chdir('/home/pi/bin');
	$lowlevel = 40;

	if(isset($_GET['startforecast'])){
		$startforecast = $_GET['startforecast'];
		$buffer = $_GET['buffer'];
		$maxbuffer = $_GET['maxbuffer'];
		$flowrate = $_GET['flowrate'];
		$tankerbuffer = $_GET['tankerbuffer'];
		$ecoFillOn = $_GET['ecoFillOn'];
		$ecoFillOff = $_GET['ecoFillOff'];
	}
	if(isset($_GET['incTankers'])) {
		// as its a checkbox, it is set when checked or not set (unchecked), therefore no need to check == "yes"
		$lowlevel += $tankerbuffer;
		$buffer += $tankerbuffer;
		$maxbuffer += $tankerbuffer;
	}
//	shell_exec('./planning.sh '.escapeshellarg($startforecast)." ".escapeshellarg($buffer)." ".escapeshellarg($flowrate)." ".escapeshellarg($maxbuffer)." && gnuplot -e lowlevel=$lowlevel plotForecast.pg");

	shell_exec('./ecoPlanning.sh '.escapeshellarg($startforecast)." ".escapeshellarg($buffer)." ".escapeshellarg($flowrate)." ".escapeshellarg($maxbuffer)." ".escapeshellarg($ecoFillOn)." ".escapeshellarg($ecoFillOff)." && gnuplot -e lowlevel=$lowlevel plotForecast.pg");
?>
