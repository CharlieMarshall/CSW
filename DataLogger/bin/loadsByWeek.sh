#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# loadsByWeek.sh — A script to show the number of loads delivery per 7 days starting from a hard coded start date
# Usage: loadsByWeek.sh
# Author: Charlie Marshall
# License: MIT

startDate="11/01/2020"

awk -v start="$startDate" '

	BEGIN { FS=OFS="\t";
		now=systime();	# current date and time

		print "Start week on: " start;
		print "Week No, No Loads";

		# convert the start date to Epoch (seconds)
		split(start,s,"/");
		startEpoch=mktime(s[3]" "s[2]" "s[1]" 00 00 00");
	}

	{
		split($7,load,"-"); # $7 is the delivery date in dd-mm-yyyy format
                loadEpoch=mktime(load[3]" "load[2]" "load[1]" 00 00 00");

		week=1;		# week to start on
		for(i=startEpoch; i<now; i+=604800) {
			if( (loadEpoch>=i) && (loadEpoch<=i+604799)) {
				b[week]++; # add load to this week number
				# print loadEpoch "is between" startEpoch " & " i "in week " week;
			}
			week++;
		}

	}

	END {
		for(i=1;i<53;i++){
			print "Week " i " " b[i] b[i]*29500 "litres";
#			print b[i];
			total = total + b[i];
		}
		print total;
	}' "${LOGS_DIR}/load_log.txt"
