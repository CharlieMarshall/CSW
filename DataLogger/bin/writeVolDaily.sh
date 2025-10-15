#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# writeVolDaily.sh — Description
# Usage: writeVolDaily.sh
# Author: Charlie Marshall
# License: MIT

# $1 holds the month
# if a argument is passed use this as the year, otherwise use the current year
if [ -z "$2" ]; then
        YEAR=$(date +%Y)
else
        YEAR=$2
fi

# HIGHLIGHTING -h must be turned off for the following lines to work, otherwise it fails when run on the last day of the month
######### SOME VERY UNUSUAL BUG - cannot use 'ncal -h' as with AJAX calls it does not default to begining a week on a Monday -M
######### Therefore we get incorrect weekend days, must use 'cal -NM' or 'ncal -M' instead #########
read wknd daysInMonth < <(ncal -hM "$1" "$YEAR" | awk 'NR==2 {days=$NF} NR>2 && $NF>days {days=$NF} NR>6 {for(i=2;i<=NF;i++) printf $i "|" } END{printf " "days}')

# Alternative to above line
# YEAR=$(date +%Y)
# daysInMonth=$(cal -h $1 $YEAR | awk 'NF {DAYS = $NF}; END {print DAYS}' )
## Using ncal OR cal -N | only print lines (NR) 7 & 8, ignore $1 as it is 'Sa' 'Su', print from $2 to NF (total number of fields), NOTE not in order
# wknd=$(cal -hNM $1 $YEAR | awk ' NR>6 { for(i=2; i<=NF; i++) printf $i "|" } ')
## Alternatively use cal | NR==3 is the first lines of dates in a month ie "1 2 3", NF is shorthand for NF>0 so we dont print the last blank line, NOTE in order
# wknd=$(cal -h $1 $YEAR | awk ' NR==3 { if(NF==7) { printf $1 "|" } printf $NF "|" } NR>3 && NF { printf $1 "|"; if(NF==7) printf $7 "|" } ')

awk -v month=$1 -v year=$YEAR -v maxdays=$daysInMonth -v wknd=$wknd 'BEGIN{ FS="\t" }
	# $7 is a date column: dd-mm-yyyy
	$7 ~ 	month"-"year {
		split($7,day,"-");
		sub(/^0/,"",day[1]);
		a[day[1]]++
	}
	END {
		split(wknd, s, "|");			# add weekend days to s ie s[1]=6, s[2]=7, s[3]=13, s[4]=14
		for(y in s) { wkndDate[s[y]]++ }	# move value of s[1] to wkndDate[s[1]] ie s[1]=6 to wkndDate[6]

		printf "#Day\tWeekday\tWeekend\n";
		for(i=1;i<=maxdays;i++){
			if(i in wkndDate)
				printf "%d\t%d\t%d\n", i, 0, a[i];
			else
				printf "%d\t%d\t%d\n", i, a[i], 0;
		}
	} ' "${LOGS_DIR}"/load_log.txt > "${LOGS_DIR}"/loadsByDay.dat

plotVolumeDaily.pg
