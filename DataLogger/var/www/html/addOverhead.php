<?php
$locale = 'en_GB.utf-8';
setlocale(LC_ALL, $locale);
putenv('LC_ALL='.$locale);

chdir('/home/pi/bin');
if(isset($_POST['overheadMonth']))
	echo shell_exec("./updateOverheads.sh ".escapeshellarg($_POST['overheadMonth'])." ".escapeshellarg($_POST['yearOh'])." ".escapeshellarg($_POST['overhead'])." && ./volumes.sh -y ".escapeshellarg($_POST['yearOh']) );
?>
