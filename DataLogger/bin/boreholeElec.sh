#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# boreholeElec.sh — Calculate for each day of the month the number of hours (day, night and total) the borehole pump was running. Output to boreholeElec.dat
# Usage: boreholeElec.sh month year(optional) eg boreholeElec.sh 3 2021
# if a argument is passed as $2 use this as the year, otherwise use the current year
# Author: Charlie Marshall
# License: MIT

if [ -z "$1" ]; then
  exit;
elif [ -z "$2" ]; then
  # YEAR=$(date +%Y) # removed for sanitising
  YEAR="2022"
else
  YEAR="$2"
fi

daysInMonth=$(cal "$1" "$YEAR" | awk 'NF {DAYS = $NF}; END {print DAYS}' )

awk -F'\t' -v month="$1" -v year="$YEAR" -v days="$daysInMonth" '
	# we use sprintf to insert leading zero otherwise the input: 2, would search for February and December
	# NOTE the !seen must be at the end, if it was at the beginning it would mark all point A as seen whether they were open or not and would therefore not check B or OFFLINE
	$7=="OPEN" && $2 ~ sprintf("%02d",month)"/"year && !seen[$2]++ {

		split($2,day,"/| |:");
                sub(/^0/,"",day[1]);

		if(day[4]<7)	# night hours are 00:00 to 6:45, these may not reflect economy 7 but is much easier to plot (stack on graph)
			nightHours[day[1]]+=0.25;	# each recording is a quarter
		else
			dayHours[day[1]]+=0.25;
	}
	END {
		print "#DOM\tNight\tDay\tTotal";
		for(x=1; x<=days; x++){
			printf "%d\t%\047.2f\t%\047.2f\t%\047.2f\n", x, nightHours[x], dayHours[x], nightHours[x] + dayHours[x];
#			total+=dayHours[x]+nightHours[x];
		}
#		print "Total Hours: " total;
	}' "${LOGS_DIR}/tank_log.txt" > "${LOGS_DIR}/boreholeElec.dat"

plotBoreholeElec.pg
