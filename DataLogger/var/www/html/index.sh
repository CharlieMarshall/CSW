#!/bin/bash
# script to produce all the image files for the index.php & op.php pages.
# Outputs a long ~ seperated string we deconstruct in PHP
cd /home/pi/bin/

# volumesHomePage.sh   Produces the loads per month (volumes.svg), abstraction (water.svg) and loads per day (volumesDaily.svg) images
# storageToTable.sh    Produces the tank image (tank_summary.svg)
# averageFlowRate.sh   Produces the average abstraction rate per hour image (fr.svg)
# create all images
./averageFlowRate.sh 30
#wait # we need to wait for the averageFlowRate to finish before we can tail the dailtFlowRate.dat file

./volumesHomePage.sh &
./storageToTable.sh &
./boreholeElec.sh &
./fillingMode.sh &

# echo the results of all these commands and return a csv string
echo -e "$(./overviewLoads.sh)~$(./overviewGate.sh)~$(./overviewCalloff.sh)~$(./overviewCIP.sh)~$(tail -n 1 dailyFlowRate.dat | cut -d' ' -f2)"
