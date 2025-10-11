#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# writeVolShift.sh — Outputs to loadsByDay.dat the number of loads filled per day of the month
# Usage: writeVolShift.sh month eg writeVolShift.sh 2
# Author: Charlie Marshall
# License: MIT

# $1 holds the month
# HIGHLIGHTING -h must be turned off for the following lines to work, otherwise it fails when run on the last day of the month
######### A VERY UNUSUAL BUG - cannot use 'ncal -h' as with AJAX calls it does not default to begining a week on a Monday -M
######### Therefore we get incorrect weekend days, must use 'cal -NM' or 'ncal -M' instead #########

# Create a | seperated list of weekends days of the month and store it in wknd, get the total days in the month and store it in daysInMonth
#read -r wknd daysInMonth < <(cal -hNM "$1" $(date +%Y) | awk 'NR==2 {days=$NF} NR>2 && $NF>days {days=$NF} NR>6 {for(i=2;i<=NF;i++) printf $i "|" } END{printf " "days}')
read -r wknd daysInMonth < <(ncal -h "$1" 2022 | awk 'NR==2 {days=$NF} NR>2 && $NF>days {days=$NF} NR>6 {for(i=2;i<=NF;i++) printf $i "|" } END{printf " "days}')

# Alternative to above line
# YEAR=$(date +%Y)
# daysInMonth=$(cal -h $1 $YEAR | awk 'END {print $NF}'
## Using ncal OR cal -N | only print lines (NR) 7 & 8, ignore $1 as it is 'Sa' 'Su', print from $2 to NF (total number of fields), NOTE not in order
# wknd=$(cal -hNM $1 $YEAR | awk ' NR>6 { for(i=2; i<=NF; i++) printf $i "|" } ')
## Alternatively use cal | NR==3 is the first lines of dates in a month ie "1 2 3", NF is shorthand for NF>0 so we dont print the last blank line, NOTE in order
# wknd=$(cal -h $1 $YEAR | awk ' NR==3 { if(NF==7) { printf $1 "|" } printf $NF "|" } NR>3 && NF { printf $1 "|"; if(NF==7) printf $7 "|" } ')

awk -v month="$1" -v maxdays="$daysInMonth" -v wknd=$wknd 'BEGIN{ FS=OFS="\t" }
	# $7 is a date column: dd-mm-yyyy
	$2 ~ "/"month {
		split($2,day,"/| |:");
		sub(/^0/,"",day[1]);

		if(day[4] > 17 || day[4] < 6)
			nightShift[day[1]]++;
		else
			dayShift[day[1]]++;
	}
	END {
		split(wknd, s, "|");			# add weekend days to s ie s[1]=6, s[2]=7, s[3]=13, s[4]=14
		for(y in s) { wkndDate[s[y]]++ }	# move value of s[1] to wkndDate[s[1]] ie s[1]=6 to wkndDate[6]

		print "#Day of Month", "Weekday Day", "Weekday Night", "Weekend Day", "Weekend Night";
		for(i=1;i<=maxdays;i++){
			if(i in wkndDate)
				printf "%d\t%d\t%d\t%d\t%d\n", i, 0, 0, dayShift[i], nightShift[i];
			else
				printf "%d\t%d\t%d\t%d\t%d\n", i, dayShift[i], nightShift[i], 0, 0;
		}
	} ' "${LOGS_DIR}/load_log.txt" | column -L -t -s $'\t' > "${LOGS_DIR}/loadsByDay.dat"

plotVolumeDaily.pg
