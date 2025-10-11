<?php
header('Content-type:application/json;charset=utf-8');
chdir(LOGS_DIR);

if(isset($_GET['id'])){
        $id = $_GET['id'];
        $output = shell_exec("awk -v id=$id ' $2==id { printf $1; exit } ' tanker_log.txt");
        echo json_encode( $output );
}
?>
