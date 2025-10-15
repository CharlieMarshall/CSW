<?php
header('Content-type:application/json;charset=utf-8');

if(isset($_GET['id'])){
        $id = $_GET['id'];
        $output = preg_split('/\n/',trim(shell_exec("awk -v id=$id ' $2==id { print $1 } END { print \"New Cert\" } ' /home/pi/panel/tanker_log.txt") ) );
        echo json_encode( $output );
}
?>
