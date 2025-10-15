<?php
$output = shell_exec('/home/pi/bin/json.sh');

$allData = explode("\n|\n",$output); // stores 1 line per item

// volume data
$multiArray = explode("\n",$allData[0]); // stores 1 line per item
$datasets = array();
// start at index 1 as the labels were at 0
for ($i = 1; $i < count($multiArray); $i++)  { // for every output line received
  $keyValue = explode(":",$multiArray[$i]); // split key from value; [0]=key, [1]=value
  array_push( $datasets, array("label" => $keyValue[0], "data" => $keyValue[1]) );
}

$result = array("labels" => $multiArray[0], datasets => $datasets);


// daily Data
$dailyLoads = explode("\n",$allData[1]); // stores 1 line per item
$dailyDatasets = array();

for ($i = 1; $i < count($dailyLoads); $i++)  { // for every output line received
  $keyValue = explode(":",$dailyLoads[$i]); // split key from value; [0]=key, [1]=value
  array_push( $dailyDatasets, array("label" => $keyValue[0], "data" => $keyValue[1]) );
}

$jsonDaily = array("labels" => $dailyLoads[0], datasets => $dailyDatasets);


// abstracted Data
$abstractedLoads = explode("\n",$allData[2]); // stores 1 line per item
$abstractedDatasets = array();

for ($i = 1; $i < count($abstractedLoads); $i++)  { // for every output line received
  $keyValue = explode(":",$abstractedLoads[$i]); // split key from value; [0]=key, [1]=value
  array_push( $abstractedDatasets, array("label" => $keyValue[0], "data" => $keyValue[1]) );
}

$jsonAbstracted = array("labels" => $abstractedLoads[0], datasets => $abstractedDatasets);

//echo json_encode($result);
//echo json_encode($jsonDaily);
//echo json_encode($jsonAbstracted);

echo json_encode(array("volumes" => $result, "daily" => $jsonDaily, "abstracted" => $jsonAbstracted));

// TO DO put above into a loop with just a single $dataset
?>
