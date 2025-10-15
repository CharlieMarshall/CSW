<?php
header('Content-type:application/json;charset=utf-8');

if(isset($_GET['id'])){
        $id = $_GET['id'];
        $output = shell_exec("awk -v id=$id ' $2==id { printf $1; exit } ' /home/pi/panel/tanker_log.txt");
        echo json_encode( $output );
}
?>
