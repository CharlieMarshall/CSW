#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# overviewStorage.sh — Display the latest log data for each of our 3 storage tanks
# Usage: overviewStorage.sh
# Author: Charlie Marshall
# License: MIT

# A script to show an overview of the latest storage tank data
tail -n 3 "${LOGS_DIR}"/tank_log.txt | awk '
	BEGIN{ FS=OFS="\t"; print "Tank","Date & Time","Point","Level (m3)","Auto Fill","Set Level (m3)","Inlet" }
 	{ total+=$4; print }
	END { print "\n"," "," ","Total",total } ' | column -L -t -s $'\t'
