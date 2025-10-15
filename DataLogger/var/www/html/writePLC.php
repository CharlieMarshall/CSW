<?php
shell_exec('/home/pi/bin/writePLC.js '.escapeshellarg($_POST['addr'])." ".escapeshellarg($_POST['data']));
?>
