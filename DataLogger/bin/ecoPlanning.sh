#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# ecoPlanning.sh — Outputs to forecast.dat the expecting levels of our storage tanks based on our orders.txt and the specified parameters
# Usage: ecoPlanning.sh startDateTime(DD/mm/YYYY HH:MM) buffer flowrate max on off # designed to be called from a website not from the terminal
# Example ecoPlanning.sh "22/02/2022 00:00" 100 18 400 19 14 # opening buffer of 100m3, flowrate of 18m3, maxTankLevels of 100m3, TanksTurnOn at 19:00, TanksTurnOff at 14:00
# Author: Charlie Marshall
# License: MIT

# http://stackoverflow.com/questions/11574435/print-date-in-loop-per-hour-with-bash-script
# ecoPlanning.sh "22/02/2022 00:00" 100 18 400 19 14 && sudo gnuplot -e lowlevel=50 plotForecast.pg
startDateTime="$1"
buffer="$2"
flowrate="$3"
max="$4"
on="$5"
off="$6"

# mktime needs date in the format %Y %m %d %H %M %s
awk -v  start="$startDateTime" -v buffer="$buffer" -v flowrate="$flowrate" -v maxBuffer="$max" -v on="$5" -v off="$6" '
	BEGIN { FS=OFS="\t"; print "#Date & Time", "Open", "Subtract", "Add", "Close", "Load No" }
	# we need this substring now we are using days of the week (Mon, Tue...) in the order.txt file
	{ a[substr($1,5)]=$2 }

	END {
		split(start,s,"[/ :]");                         	# the start date and time of the forecast
		split($1,e,"[/ :]");					# the date and time of the last order/forecast
		end=mktime(e[4] " " e[3] " " e[2] " " e[5]+1 " 00 00");	# formatted: %Y %m %d %H %M %S, we add one to the hour to show the affects of the last load, minutes and seconds are 00

		# If the start time is not on the hour, calculate times per minute
		if( s[5] != 00 ) {
			startbuffer=buffer;
			roundMins=60-s[5];					# Calculate how many minutes remain in the hour
			timeEpoch=mktime(s[3]" "s[2]" "s[1]" "s[4]" 00 00");	# Epoch version of the start time, adjusted to 00 mins to check if there is a load this hour
			hour=strftime( "%d/%m/%Y %H:%M", timeEpoch );
			ecoHour=strftime("%H", timeEpoch);

			if(hour in a) { subt=(29.5/60)*roundMins; buffer-=subt } else { subt=0 }

			# adds a leading zero to the hour if its a single digit
			if(ecoHour>=sprintf("%02d",off) && ecoHour<sprintf("%02d",on))
				add=0;					# autofill is turned off during these hours
			else {
				if	(buffer >= maxBuffer)				{ add=0 }				# Already at max capacity
				else if (maxBuffer-buffer >= (flowrate/60)*roundMins)	{ add=(flowrate/60)*roundMins }		# Enought space for the full flowrate
				else							{ add=maxBuffer-buffer }		# Less than an hour from max

				if(maxBuffer>0) { buffer+=add }		# stops the graph filling up when the level is less than 0
			}
			printf "%s\t%.1f\t%.1f\t%.1f\t%.1f\t%s\n", start, startbuffer, subt, add, buffer, a[hour];
			s[4]+=1;					# Move the time on to the next hour
		}

		timeEpoch=mktime(s[3]" "s[2]" "s[1]" "s[4]" 00 00");	# holds the start time / adjusted to next hour if not 00 minutes

		# If there are no orders print the next day with no other changes
		if(timeEpoch>end)
			printf "%s\t%.1f\t%.1f\t%.1f\t%.1f\t%s\n", strftime( "%d/%m/%Y %H:%M", timeEpoch+86400), startbuffer, subt, add, buffer, a[hour];
		else {
			for(i=timeEpoch;i<=end;i+=3600) {
				startbuffer=buffer;
				hour=strftime( "%d/%m/%Y %H:%M", i);
				ecoHour=strftime("%H", i);

				if(hour in a) { subt=29.5; buffer-=subt } else { subt=0 }

				# adds a leading zero to the hour if its a single digit
				if(ecoHour>=sprintf("%02d",off) && ecoHour<sprintf("%02d",on))
					add=0;								# autofill is turned off during these hours
				else {
					if	(buffer >= maxBuffer)		{ add=0 }		# Already at max capacity
					else if (maxBuffer-buffer >= flowrate)	{ add=flowrate }	# Over an hour from max capacity - add full flow
					else	{ add=maxBuffer-buffer }				# Less than an hour from max

					if(maxBuffer>0) { buffer+=add }					# stops the graph filling up when the level is less than 0
				}
				printf "%s\t%.1f\t%.1f\t%.1f\t%.1f\t%s\n", hour, startbuffer, subt, add, buffer, a[hour];
			}
		}
	}
' "${LOGS_DIR}/orders.txt" > "${LOGS_DIR}/forecast.dat"
