#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# annualForecast.sh — Output a forecast of the number of loads to be delivered based on the latest forecase.csv
# Usage: annualForecast.sh
# Author: Charlie Marshall
# License: MIT

#YEAR=$(date +%Y)
YEAR=2022

# This code block is commented out as part of the sanitising for GitHub
#cd "${HOME}/Maildir/forecast/attachments"
#if [ "$(ls -A ${HOME}/Maildir/forecast/attachments)" ]; then
#  for f in *; do
#    ssconvert $f "${LOGS_DIR}/forecast.csv"
#  done;
#  rm $f
#fi

# we have seen different column numbers on the forecast received therefore we use regex to find the Annual Fcast column to start from opposed to hard coded column numbers.
# i = the annual forcast column
# i+1 = is the first weekly forecast
# finish (i+51) = is the last weekly forecast
awk -v yr="$YEAR" -F ',' '
        NR==1   { split($0,header,","); i=1; while(header[i] !~ /Annual/) { i++; } next; }
        NR==2   { split($0,value,","); }
        END     {
			start=++i; finish=i+51;
			for(y=i; y<finish; y++){
                        	# manually only deal with this year hard coded
	                        if(header[y] ~ yr) { thisYrLitres+=value[y] }
        	                else { nextYrLitres+=value[y] };
                	}
			printf("%d loads forecast for the remainder of %d\n\n%d loads forecast in %d (up to %s)\n\nAnnual forecast for the next 52 weeks: %\047.f litres, (%d loads)\n", thisYrLitres/29500, yr,nextYrLitres/29500, yr+1, header[finish],value[--i], value[i]/29500);

			# removed for sanitising
			# message = sprintf("%d loads forecast for the remainder of %d\n\n%d loads forecast in %d (up to %s)\n\nAnnual forecast for the next 52 weeks: %\047.f litres, (%d loads)", thisYrLitres/29500, yr,nextYrLitres/29500, yr+1, header[finish],value[--i], value[i]/29500);
			# system(" push.sh \"Annual Forecast " header[start] "\" \"" message "\" ")
                } ' "${LOGS_DIR}/forecast.csv"
