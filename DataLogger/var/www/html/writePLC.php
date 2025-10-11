<?php
chdir(SCRIPTS_DIR);
shell_exec('simpleWritePLC.js '.escapeshellarg($_POST['addr'])." ".escapeshellarg($_POST['data']));
?>
