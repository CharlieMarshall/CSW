<?php

$output = shell_exec('/home/pi/bin/json.sh');

$allData = explode("\n|\n",$output); // stores 1 block of text per element

$jsonArray = array(); // array we are sending to the client

$objectLabel = array("Volumes", "Daily", "Abstracted"); // holds our labels

for ($y = 0; $y < count($allData); $y++)  { // for every block of text
	// initalise / clear arrays
	$lines = array();
	$datasets = array();

	$lines = explode("\n",$allData[$y]); // stores 1 line per element

	// start at index 1 as the labels are at 0 and they are not a key value pair
	for ($i = 1; $i < count($lines); $i++)  { // for every output line read
	  $keyValue = explode(":",$lines[$i]); // split key from value; [0]=key, [1]=value
	  array_push( $datasets, array("label" => $keyValue[0], "data" => $keyValue[1]) );
	}
	// add our labels and dataset to the array
	$jsonArray[$objectLabel[$y]] = array("labels" => $lines[0], datasets => $datasets);
}
echo json_encode($jsonArray);
/*
// TANK GRAPH
$output = shell_exec('/home/pi/bin/storageToJson.sh 2');

$jsonArray = array(); // array we are sending to the client

$datasets = array();
$lines = explode("\n",$output); // stores 1 line per element

// start at index 1 as the labels are at 0 and they are not a key value pair
for ($i = 1; $i < count($lines); $i++)  { // for every output line read
  $keyValue = explode(":",$lines[$i]); // split key from value; [0]=key, [1]=value
  array_push( $datasets, array("label" => $keyValue[0], "data" => $keyValue[1]) );
}
// add our labels and dataset to the array
$jsonArray["tanks"] = array("labels" => $lines[0], datasets => $datasets);
echo json_encode($jsonArray);
*/
?>
