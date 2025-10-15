<?php
chdir('/home/pi/bin/');

switch ( $_POST['data'] ) {
    case "releaseOne":
	$output = shell_exec('./releaseLoads.sh one');
	break;
    case "releaseAll":
	$output = shell_exec('./releaseLoads.sh');
	break;
    case "ciptanks":
	$output = shell_exec('./cipdates.sh');
	break;
    case "orders":
	$output = shell_exec('cat ../panel/orders.txt');
	break;
    case "blends_load":
	shell_exec('./blends.sh');
	$output = "Finished scanning for new loads. <a href=\"loads_misc.php\">View Loads</a>";
//	$output = shell_exec("./blends.sh && awk ' {print} END {print NR \" loads collected\"} ' ../panel/blends_load_log.txt");
	break;
    case "panel":
    case "tank":
//	$output = shell_exec('tail -n 200 ../panel/panel_log.txt | tac');
	$output = shell_exec('tail -n 200 ../panel/' . $_POST['data'] . '_log.txt | tac');
	break;
    case "sysInfo":
	$output = shell_exec('./systemInfo.sh' );
	break;
    case "annualForecast":
	$output = shell_exec('./monthlyForecast.sh' );
	break;
    case "missingLoads":
	$output = shell_exec('./findMissingLoads.sh' );
	break;
    case "reset":
	$output = shell_exec('./restartServer.sh' );
        break;
    case "solar":
	$output = shell_exec('./solar.sh' );
        break;
    case "openGate":
	shell_exec('./openGate.sh' );
	$output = "Gate opened";
        break;
    case "cipStatus":
	$output = shell_exec('date +"%H:%M:%S" && /home/pi/bin/cip.js');
        break;
    case "printRefresco":
	shell_exec('lp -d NewOki_ML5520 -n 6 /home/pi/panel/delNote.pdf');
	$output = "Printed 6 Refresco delivery notes";
        break;
    case "printWessex":
	shell_exec('lp -d BrotherLaser -n 7 /home/pi/panel/wessexSampleSheet.pdf' );
	$output = "Printed 7 Wessex sample sheets";
        break;
    case "cups":
	exit; // do nothing

    /*
    // obsolete lab case
    case "lab":
	shell_exec('./getLabCerts.sh > /dev/null 2>/dev/null &');
        $output = 'Checking for new lab certificates...<br><br>New certificates will be added to the <a href="lab_results.php">lab results page</a>. This may take a few minutes' ;
	break;
    */

    /*
    // obsolete calloff case
    case "calloff":
	// $output is not really needed here or is the use of tee in the getCalloff.sh script as we no longer use this output
	//$output = shell_exec('./getCalloff.sh');

// TODO if we encounter a problem when the call off is not getting scraped, look at doing this, output of getCallOff.sh needs to go into a
// variable $output. We can then view it in the console, if we comment out the reloading of the page in the header.php file bottom lines.
// it might be worth getting the exit code of the getCall.sh file to check whether we should reload the page or report an error.
// Think it is a permission issue which only happens after using dropbox to upload the calloff.
//	$output = "Result:";
//	$output .= shell_exec('./getCalloff.sh');
	shell_exec('./getCalloff.sh');
	break;
    */

    /*
    // obsolete alarm
    case "alarm":
	$getAlarm = shell_exec( " grep -c 'tankAlarm=\"ENABLED\"' parsePanel.sh ");

	if($getAlarm == 1){
		shell_exec ("sed ' s/tankAlarm=\"ENABLED\"/tankAlarm=\"DISABLED\"/ ' parsePanel.sh > panelAlarm.tmp && cp panelAlarm.tmp parsePanel.sh" );
		$output = "Low level alarm disabled";
	} else {
		shell_exec("sed ' s/tankAlarm=\"DISABLED\"/tankAlarm=\"ENABLED\"/ ' parsePanel.sh > panelAlarm.tmp && cp panelAlarm.tmp parsePanel.sh" );
		$output = "Low level alarm enabled";
	}
        break;
    */
}
echo "<div class=\"alert alert-info alert-dismissable\"><a href=\"\" class=\"close\" data-dismiss=\"alert\" aria-label=\"close\">x</a>$output</div>";
?>
