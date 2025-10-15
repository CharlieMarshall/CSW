#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# monthlyForecast.sh — Outputs monthly brekdown of the number of loads forecast, converts from litres forecast to loads (29500 litres)
# Usage: monthlyForecast.sh
# Author: Charlie Marshall
# License: MIT

YEAR=2022
# commented for sanitising
# YEAR=$(date +%Y)

# we have seen different column numbers on the forecast received therefore we use regex to find the Annual Fcast column to start from opposed to hard coded column numbers.
# i = the annual forcast column
# i+1 = is the first weekly forecast
# finish (i+51) = is the last weekly forecast
awk -v yr="$YEAR" -F ',' '
	NR==1   { split($0,header,","); i=1; while(header[i] !~ /Annual/) { i++; } next; }
	NR==2   { split($0,value,","); }
	END     {
			i++; finish=i+51;
			for(y=i; y<finish; y++){
				split(header[y],date,"/");
				year=date[1];
				month=date[2]+0;

				if(y==i)
				  first=month;

				arr[year][month] +=value[y];
                	}
			printf("%s - %s = %\047.f litres, %d loads\n\nBy month (rounded down so may be short):\n", header[i], header[finish], value[--i], value[i]/29500); # print week range and total annual forecast

			# This is overly complex but I wanted to print the header of each month and then each months loads
			split("Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec",m,"|");
			for(x=1;x<14;x++){
			  printf("%s\t", m[first]);	# print each month header

  			  if(x==1) monthly = sprintf("%d", arr[yr][first] / 29500);
			  else monthly = sprintf("%s\t%d", monthly, arr[yr][first] / 29500);

			  if(first==12){
				yr++;		# note we need to comment this out for the last week of the year otherwise it will roll into future years! ####
				first=1;
			  }
			  else first++

			}
			printf("\n%s\n", monthly);
                }
' "${LOGS_DIR}/forecast.csv"
