<?php
$locale = 'en_GB.utf-8';
setlocale(LC_ALL, $locale);
putenv('LC_ALL='.$locale);

if($_GET['year'][4]=="/"){
	$finyear = substr($_GET['year'], 0, 4);
	echo shell_exec("/home/pi/bin/volumes.sh.all -fy ".escapeshellarg($finyear) );
}
else if($_GET['year']=='all')
	echo shell_exec("/home/pi/bin/volumes.sh.all -a");
else
	echo shell_exec("/home/pi/bin/volumes.sh.all -y ".escapeshellarg( $_GET['year'] ));
?>
