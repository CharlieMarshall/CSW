#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# averageFlowRate.sh — A Script to calculate, store and plot average daily flow rates.
# Works by finding all occurences when the lines are not loading tankers.
# Then looks for the matching tank readings and stores any where at least one inlet is open.
# Then comparing the location of the found results and if there are two consequtive timestamps when we are not pumping and when the inlets are open it stores these
# Finally accumulates all the daily averages and stores a single average per day
# Usage averageFlowRate.sh noDays eg averageFlowRate.sh 2 # print 2 days of abstraction flow rates
#
# Author: Charlie Marshall
# License: MIT

days="$1"
if [ $# -eq 0 ]; then days=1; fi # if no arguments supplied default to '1 day'

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

# note the date we use 00:00 for the time so we have an entire day

# removed for sanitising, replaced with hardcoded date
#awk -v from="$(date +"%Y/%m/%d 00:00" -d "-$days days")" ' BEGIN { FS=OFS="\t" }
awk -v from="2022/02/12 00:00" ' BEGIN { FS=OFS="\t" }
	{
		# convert the date to a format we can compare 2018/12/30 so we can exit when ready
		split($2, x,"[/ :]");
		datetime=x[3]"/"x[2]"/"x[1]" "x[4]":"x[5];

		if(datetime>=from){
			# panel_log: if the line is OFFLINE increment the count for that day by 1 (2 max)
	        	if(FNR==NR)							{ if($8=="OFFLINE")	{ offline[$2]++ } next }

			# Duplicate to above line but ignoring cleaning. Not sure it adds much to the result so removed for tiny optimisation
			# if(FNR==NR)							{ if($8=="OFFLINE" && $5>6.5 && $5<9.5)	{ offline[$2]++ } next }

			# tank_log.txt file AND both points are not loading any tankers (offline[$2]==2)
			if(FNR!=NR && $3=="Offline")					{ next } ### Ignore the spare tank which may be used for flow compensation! ###
			if(FNR!=NR && offline[$2]==2)					{
											  storage+=$4;
											  if($7=="OPEN")	{ inlet[$2]++ }

											  if($3=="A")		{
												if(inlet[$2]>0)	{
													dt[++z]=$2;
													totalStorage[z]=storage;
												}
												storage=0;
											  }
											}
			#  What we are doing above for the tank_log.txt {action}:
			#
			#  Storage holds an accumulation of the tank level
			#  When we encounter an open tank inlet we increment the inlet array at this dateTimeStamp
			#  The file is read in reverse so the last point we encounter is 'A'.
			#  When we are on 'A':
			#	If any of the inlets are open:
			# 		Save the datetimestamp in dt[] using z as a reference. Having a reference allows us to print the array in the correct order
			#  		Save the totalStorage for this dateTimeStamp
			#	When we are finished with 'A' we reset the storage to 0, for the next dateTimeStamp
		}
		else { nextfile }
	}
        END {
		# loop through all records apart from the last one as we have nothing to compare it to
		for(; z>1; z--){

			# convert dt stamp to epoch. This allows us to check that the readings are sequential ie 15 minutes (900 seconds) apart
			split(dt[z],a,"[/ :]");						# current
			aTimeEpoch=mktime(a[3]" "a[2]" "a[1]" "a[4]" "a[5]" "00);	# current
			split(dt[z-1],b,"[/ :]");					# next
			bTimeEpoch=mktime(b[3]" "b[2]" "b[1]" "b[4]" "b[5]" "00);	# next

			# if recordings are 15 minutes (900 seconds) apart print data, if they are not results are ignored as we are missing data and it may throw in strange results
			# Alternatively we could check if the FNR are 3 apart if we stored them above eg fileLocation[FNR] inside 'A' block. It would be faster but not as accurate in the case of missing dtStamps
			if( (bTimeEpoch - aTimeEpoch) == 900){
				diff=(totalStorage[z-1] - totalStorage[z])*4;	# multiple by 4 to get an hourly flow rate as currently it is a 15 minute flow rate

				if(diff >8 && diff < 25) {	# ignores any garbage results
					# print dt[z], diff;	# prints the dateTimeStamp and the hourly flowrate				# debugging
					# print "Z=" z, "z: " dt[z], "z-1: "dt[z-1], aTimeEpoch, bTimeEpoch, diff, bTimeEpoch - aTimeEpoch; 	# debugging

					dom=a[3]a[2]a[1];	# create a new datestamp we use YYMMDD as it will be sorted when we loop through it later, DD/MM/YYYY will not print in order!
					flow[dom]+=diff;	# accumulate the HOURLY flowrates
					count[dom]++;		# hold a count of the number of occurences on this day
				}
			}
                }
		for(w in flow){
			# because awk does not print arrays in order we are using YYMMDD to store items to force it in order and then need to change it back to print it see
			# https://www.gnu.org/software/gawk/manual/html_node/Controlling-Array-Traversal.html
			convertDate = substr(w,7,2) "/" substr(w,5,2) "/" substr(w,0,4);
			printf "%s %.1f\n", convertDate, flow[w] / count[w];
			# print convertDate " " flow[w] / count[w];
		}
	} ' <(tac "${LOGS_DIR}/panel_log.txt") <(tac "${LOGS_DIR}/tank_log.txt") > "${LOGS_DIR}/dailyFlowRate.dat"

plotAverageFlowrate.pg # plot graph
