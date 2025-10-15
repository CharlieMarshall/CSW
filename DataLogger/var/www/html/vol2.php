<?php
$output = shell_exec('/home/pi/bin/test.sh');

$multiArray = explode("\n",$output); // stores 1 line per item

$datasets = array();
// start at index 1 as the labels were at 0
for ($i = 1; $i < count($multiArray); $i++)  { // for every output line received
  $keyValue = explode(":",$multiArray[$i]); // split key from value; [0]=key, [1]=value
  array_push( $datasets, array("label" => $keyValue[0], "data" => $keyValue[1]) );
}

$result = array("labels" => $multiArray[0], datasets => $datasets);


/*   WORKING 0: { label: 2016, data: 10,10,30....}
// start at index 1 as the labels were at 0
for ($i = 1; $i < count($multiArray); $i++)  { // for every output line received
  $keyValue = explode(":",$multiArray[$i]); // split key from value; [0]=key, [1]=value

//  $label = array("label" => $keyValue[0] );
//  $test = array("data" => explode(",",$keyValue[1]));

  $add = array("label" => $keyValue[0], "data" => explode(",",$keyValue[1]));
  array_push( $result["datasets"], $add );
}
*/


/*   WORKING with a label as the key eg 2016 : 10,20,30 ....


for ($i = 1; $i < count($multiArray); $i++)  { // for every output line received
  $keyValue = explode(":",$multiArray[$i]); // split key from value; [0]=key, [1]=value
  // array_push( $result["datasets"][ $keyValue[0] ], "" );
  $result["datasets"][ $keyValue[0]] = explode(",",$keyValue[1]);
}

*/
echo json_encode($result);
?>
