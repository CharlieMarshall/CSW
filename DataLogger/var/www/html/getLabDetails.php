<?php
	chdir('/home/pi/bin');

	if(isset($_POST['filter']))
		$output = shell_exec('./tableLabResults.sh '.escapeshellarg( $_POST['filter'] ) );
	else if(isset($_POST['cost']))
		$output = shell_exec('./wessexCostSummary.sh');
	else if(isset($_POST['missing']))
		$output = shell_exec('./missingLab.sh');
	else if(isset($_POST['exceptions']))
		$output = shell_exec('./wessexExceptionArray.sh');
	else if(isset($_POST['failure']))
		$output = shell_exec('./numLabFailures.sh');
	else if(isset($_POST['duplicates']))
		$output = shell_exec('./findDuplicateLabSU.sh');
	else if(isset($_POST['retests']))
		$output = shell_exec('./findLabRetests.sh');
	else if(isset($_POST['price'])){
		$locale = 'en_GB.utf-8';
		setlocale(LC_ALL, $locale);
		putenv('LC_ALL='.$locale);

// temporatily changed to tablelabCostsYR.sh
//		$output = shell_exec ("/home/pi/bin/tableLabCosts.sh" );
		$output = shell_exec ("/home/pi/bin/tableLabCostsYr.sh -y ".escapeshellarg(strftime('%Y')));
	}
// TESTING to show prevoius years
	else if(isset($_GET['year'])){
		$locale = 'en_GB.utf-8';
		setlocale(LC_ALL, $locale);
		putenv('LC_ALL='.$locale);

			if($_GET['year'][4]=="/"){
			        $finyear = substr($_GET['year'], 0, 4);
			        $output = shell_exec("/home/pi/bin/tableLabCostsYr.sh -fy ".escapeshellarg($finyear) );
			}
			else if($_GET['year']=='all')
			        $output = shell_exec("/home/pi/bin/tableLabCostsYr.sh -a");
			else
			        $output = shell_exec("/home/pi/bin/tableLabCostsYr.sh -y ".escapeshellarg( $_GET['year'] ));
	}
// END OF TESTING

/*	else if(isset($_POST['from'])) {
		$from = $_POST['from'];
		$to = $_POST['to'];
		$output = shell_exec('./wessexInvoice.sh '.escapeshellarg($from)." ".escapeshellarg($to));
	}	*/
	echo $output;
?>
