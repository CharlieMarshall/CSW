#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# storageToJson.sh — A script to print storage tank and total levels over a specified period
# Usage: storageToJson.sh days eg ./storageToTable.sh 2 # print 2 days of storage
# Author: Charlie Marshall
# License: MIT

days=$1
if [ $# -eq 0 ]; then days=1; fi # no arguments supplied default to '1 day'
# file read in reverse for speed therefore 'Offline' is read first, we minus 15 mins for better accuracy
#tac "${LOGS_DIR}/tank_log.txt" | awk -v from="$(date +"%Y/%m/%d %H:%M" -d "-"$days" days -15 mins")" ' BEGIN { FS=OFS="\t" } {
tac "${LOGS_DIR}/tank_log.txt" | awk -v from="2022/02/24 00:00" ' BEGIN { FS=OFS="\t" } {
	# reformat date 25/12/2017 09:00 = 2017/12/25 09:00
	split($2, x,"[/ :]"); d=x[3]"/"x[2]"/"x[1]" "x[4]":"x[5];
	# this is quicker then getting todays date using EPOCH: from=systime()-(days*86400)
	# and creating a timestamp with mktime: d = mktime(x[3]" "x[2]" "x[1]" "x[4]" "x[5]" 00")
	if(d>=from){
		if($3=="Offline")	{ dt[++z]=$2 }
		if($1=="3")     	{ tank[3][z]=$4; next }
		if($1=="2")     	{ tank[2][z]=$4; next }
		if($1=="1")     	{ tank[1][z]=$4; next }
	}
	exit
	} END{
		for(i=0;i<5;i++){
			counter=z;
			if(i==0){
				printf "labels:";
				for(;counter>0;counter--) {
					if(counter==z)
						printf "%s", dt[counter];
					else
						printf ",%s", dt[counter];
				}
			}
			else if(i==4){
				printf "\ntotal:";
				for(;counter>0;counter--) {
					if(counter==z)
						printf "%.1f", tank[1][counter] + tank[2][counter] + tank[3][counter];
					else
						printf ",%.1f", tank[1][counter] + tank[2][counter] + tank[3][counter];
				}
			}
			else {
				printf "\nTank %d:", i;
				for(;counter>0;counter--) {
					if(counter==z)
						printf "%d", tank[i][counter];
					else
						printf ",%.1f", tank[i][counter];
				}
			}
		}
	} '

plotTankSummary.pg
