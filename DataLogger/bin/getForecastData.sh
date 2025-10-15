#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# getForecastData.sh — A script to gather the data required to plot the forecast graph
# Usage: getForecastData.sh
# Author: Charlie Marshall
# License: MIT
#
# The flowrate is passed to awk as a variable. It is the latest recording in the dailyFlowRate.dat file
# The volumes of litres in the road tankers are calculated using the last 2 lines of the panel_log.txt file
# The storage tank levels and the maximum storage level are calculated using the last 3 lines of the tank_log.txt file
#
# The variables are then output to the terminal separated by newlines. The webGUI can then split these up in PHP and assign them to the correct boxes
# The script ecoPlanning.sh is run inside awk as we still have named access to the variables, this creates a data file to allow us to plot a graph
# Once the awk script has finished we plot the graph using gnuPlot

####  Panel log
# $1 = load number
# $2 = date and time stamp
# $3 = Point (A or B)
# $4 = Tank (1,2 or 3
# $5 = PH
# $6 = Conducitivity
# $7 = Temp
# $8 = Status (OFFLINE, PAUSED, LOADING)
# $9 = Set Level (29500)
# $10 = Pumped
# $11 = Flowrate
# $12 = Minutes Remaining

#### Tank log
# $1 = Tank number (1, 2 or 3)
# $2 = date and time stamp
# $3 = Point (A, B, or Offline)
# $4 = Tank Level
# $5 = Autofill (ON or OFF)
# $6 = Tank Set Level
# $7 = Inlet (OPEN or CLOSED)

awk -F'\t' -v flowrate=$(tail -n 1 "${LOGS_DIR}/dailyFlowRate.dat" | cut -d" " -f2) '
	# Panel log file, round lt pumped to 29500, tankersum = the volume of litres held in the road tankers at the last timestamp
	FNR==NR			{ if($10>29500)	{ $10=29500 } tankersum+=$10 }

	# Tank log file, tanklevel = sum of storage tank levels, maxbuffer = sum of the storage tank set levels. Both at the last timestamp
	FNR!=NR			{ tanklevel+=$4; maxbuffer+=$6 }
	#FNR!=NR && $5=="ON"	{ tanklevel+=$4; maxbuffer+=$6 } # same as line above but only records if autofil is 'ON'

	END			{
					printf ("%s\n%.1f\n%.1f\n%.1f\n%.1f\n", $2, tankersum/1000, tanklevel, flowrate, maxbuffer );
					system("ecoPlanning.sh \"" $2 "\" " tanklevel " " flowrate " " maxbuffer " " 23 " " 18);
				}
' <(tail -n 2 "${LOGS_DIR}/panel_log.txt") <(tail -n 3 "${LOGS_DIR}/tank_log.txt")

gnuplot -e lowlevel=40 plotForecast.pg
