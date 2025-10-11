#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# storageToTable.sh — A script to print hourly levels for each tank and the total over a specified period
# Usage: storageToTable.sh period eg storageToTable.sh 2 # prints 2 days of storage
# Author: Charlie Marshall
# License: MIT

# no arguments supplied default to '1 day'
if [ $# -eq 0 ]; then
    days='1'
else
    days="$1"
fi


# file read in reverse for speed therefore 'Offline' is read first, we minus 15 mins for better accuracy
#tac "${LOGS_DIR}"/tank_log.txt | awk -v from="$(date +"%Y/%m/%d %H:%M" -d "-$days days -15 mins")" ' BEGIN { FS=OFS="\t" } {
# sanitised
tac "${LOGS_DIR}"/tank_log.txt | awk -v from="2022/02/18 00:00" ' BEGIN { FS=OFS="\t" } {
	# reformat date 25/12/2017 09:00 = 2017/12/25 09:00
	split($2, x,"[/ :]"); d=x[3]"/"x[2]"/"x[1]" "x[4]":"x[5];
	# this is quicker then getting todays date using EPOCH: from=systime()-(days*86400)
	# and creating a timestamp with mktime: d = mktime(x[3]" "x[2]" "x[1]" "x[4]" "x[5]" 00")
	if(d>=from){
		if($3=="Offline")	{ dt[++z]=$2 }
		if($1=="3")     	{ c[z]=$4; next }
		if($1=="2")     	{ b[z]=$4; next }
		if($1=="1")     	{ a[z]=$4; next }
	}
	exit
	} END { for(; z>0;z--) print dt[z], a[z], b[z], c[z], a[z]+b[z]+c[z] } ' > "$LOGS_DIR/storageTable.dat"

plotTankSummary.pg
