#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# getForecastDataDaily.sh — Parse the tank data and calculate the average flowrate based on a specified number of days. Then update the forecast
# Usage: getForecastDataDaily.sh noDays(Optional) eg getForecastDataDaily.sh 2
# Author: Charlie Marshall
# License: MIT

days=$1
if [ $# -eq 0 ]; then days=1; fi # no arguments supplied default to '1 day'

# $1 holds the number of days required
pdays=$(( $days*192 ))	# multiple by 192 which is (*4 *24 *2) *4 = 4 times per hour, *24 = 24 hours per day, *2 = 2 lines per log
tdays=$(( $days*288 ))	# multiple by 288 which is (*4 *24 *3) *4 = 4 times per hour, *24 = 24 hours per day, *3 = 3 lines per log

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


# A single day is 192 lines of the panel_log.txt file & 288 lines of the tank_log.txt file

awk -F'\t' -v Pdays=$pdays -v Tdays=$tdays '

	#### GET CURRENT DATA NEEDED FOR NON FLOWRATE DATA but data for calculated forecast such as tank level
	# Panel log file GET CURRENT pumped levels: round lt pumped to 29500, tankersum = the volume of litres pumped that day
	FNR==NR && FNR> Pdays-2				{ if($10>29500)	{ $10=29500 } tankersum+=$10; }

	#  Tank log file GET CURRENT tank levels: tanklevel = sum of tank levels, maxbuffer = sum of tank setl levels
	FNR!=NR	&& FNR> Tdays-3					{ tanklevel+=$4; maxbuffer+=$6 } # Add:  && $5=="ON" # if we only want when AutoFill is ON
	#### END CURRENT DATA

	# start of get average flow rate
	FNR==NR && $8=="OFFLINE"				{ a[$2]++ }	# Panel log file: If NOT PUMPING on the line at the timestamp increment the count for that day by 1 (2 max)

	#### Tank log
	# if NOT PUMPING on either line at this time ( a[$2]==2 )
	# Ignore the tank which is offline ( $3!="Offline" )
	#
	# If the inlet is open inrement the inlet count by 1 for that day
	# Sum the total tank level for the day
	FNR!=NR && a[$2]==2 && $3!="Offline"			{ if($7=="OPEN"){ inlet[$2]++ } totals[$2]+=$4 }

	#### Tank log
	# if NOT PUMPING on either line at this time ( a[$2]==2 )
	# AND it is the OFFLINE point ( $3=="Offline" )
	# AND at least one inlet is open
	#
	# Sum the total tank level for the day (this is the last time we do this as offline will always be last line read with the datestamp)
	# final[file line number] holds the total of the 3 tank levels at that date time stamp
	FNR!=NR && a[$2]==2 && $3=="Offline"			{ if($7=="OPEN"){ inlet[$2]++ } totals[$2]+=$4;
								  if(inlet[$2]>0) { final[FNR]=totals[$2] }
								}


	END							{ # loop through all records but only print ones where we have 2 subsequent readings (3 lines apart)
									for(i=Tdays; i>1; i--){
										if(final[i]!="" && final[i-3]!="") {
											count++;
											# multiply by 4 to get the hour change
											hour=(final[i] - final[i-3]) * 4;
											print hour;
											total+=hour
										}
									}
									if(total>0 && count>0)
										flowrate=total/count;
									else
										flowrate=18;	# manually set when we have not been filling in the last n days. GUI now uses 5 day averages

									printf ("%s\n%.1f\n%.1f\n%.1f\n%.1f\n", $2, tankersum/1000, tanklevel, flowrate, maxbuffer );
									#printf ("ecoPlanning.sh \"" $2 "\" " tanklevel " " flowrate " " maxbuffer " " 19 " " 14);
									system("ecoPlanning.sh \"" $2 "\" " tanklevel " " flowrate " " maxbuffer " " 22 " " 17);
								}
' <(tail -n $pdays "${LOGS_DIR}/panel_log.txt") <(tail -n $tdays "${LOGS_DIR}/tank_log.txt")

gnuplot -e lowlevel=40 plotForecast.pg
