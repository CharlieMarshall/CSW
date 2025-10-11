#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# volumesHomePage.sh — This script is a duplication and merging of 3 individual scripts. It parses the log files and creates a 3 dat files (volumes, loads by day and abstraction).
# This provides us with all the data (dat files) needed by our index.php page to loads the 3 produe the gnuplot graphs
# Usage: volumesHomePage.sh (executed by loading the index.php webpage)
# Author: Charlie Marshall
# License: MIT

# gets data and creates 3 .dat files for the volumes, one for the loads by day and 1 for the abstraction

cd "${LOGS_DIR}" || exit

CURYEAR=$(date +%Y)

read -r YEAR MONTH < <(date '+%Y %m')

# sanitised
CURYEAR='2022'
YEAR='2022'
MONTH='2'

boreholeElec.sh "$MONTH" &
fillingMode.sh "$MONTH" &

# HIGHLIGHTING -h must be turned off for the following lines to work, otherwise it fails when run on the last day of the month
######### SOME VERY UNUSUAL BUG - cannot use 'ncal -h' as with AJAX calls it does not default to begining a week on a Monday -M
######### Therefore we get incorrect weekend days, must use 'cal -NM' or 'ncal -M' instead #########
# NOTE SINCE UPGRADING TO BULLEYES WE HAVE HAD TO MANUALLY INSTALL NCAL and we can no longer use -h to stop highlighting seems it is done as default

#daysInMonth=$(cal -h "$MONTH" "$YEAR" | awk 'NF {DAYS = $NF}; END {print DAYS}' )
daysInMonth=$(cal "$MONTH" "$YEAR" | awk 'NF {DAYS = $NF}; END {print DAYS}' )
#wknd=$(cal -h "$MONTH" "$YEAR"  | awk ' NR==3 && NF { if(NF==7) { printf $1 "|" $NF "|" } else { printf $NF "|" } } NR>3 && NF { printf $1 "|"; if(NF==7) printf $7 "|"} ' )
wknd=$(cal "$MONTH" "$YEAR"  | awk ' NR==3 && NF { if(NF==7) { printf $1 "|" $NF "|" } else { printf $NF "|" } } NR>3 && NF { printf $1 "|"; if(NF==7) printf $7 "|"} ' )

awk -v curYr="$CURYEAR" -v year="$YEAR" -v month="$MONTH" -v maxdays="$daysInMonth" -v wknd="$wknd" '
	BEGIN { FS=OFS="\t";
                # split does not work without declaring the 2D arrays so we initialise the first index to 0
                for(i=2016; i<=curYr; i++)
                        loads[i][1]=0;

                split("Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec",m,"|");
                split("0|10|46|80|120|87|168|135|67|117|125|108",loads[2016],"|");
                split("165|52|186|156|212|157|174|192|26|170|125|176",loads[2017],"|");
                split("165|149|159|181|240|235|219|236|178|158|154|148",loads[2018],"|");
                split("228|69",loads[2019],"|");
	}

	# this first line is the same as writeVolDaily - allows us to write the file for the graph
	# we remove the leading zero of the month to allow us to store it in an array ie Jan = [1] instead of [01]
	$7 ~ month"-"year	{ split($7,day,"-"); sub(/^0/,"",day[1]); a[day[1]]++ }

	# this line is to populate the vol.dat file to plot the volume graph for multiple years
#	$7 ~ year 		{ Lmonth=substr($7, 4, 2); sub(/^0/,"",Lmonth); loads[year][Lmonth]++; next }
	FNR==NR 		{ yr=substr($7, 7, 4); mon=substr($7, 4, 2); sub(/^0/,"",mon); loads[yr][mon]++; next }

	END {
		# this block prints the header line: #Month\t2016\t2017\t2018....
		for(y=2016; y<=year; y++) { volHeader = volHeader "\t" y; }
                print "#Month" volHeader > "vol.dat";

		# loop through each month
		for(i=1; i<=12; i++) {
			printf "%s\t", m[i] > "vol.dat";
			for(y=2016; y<=year; y++) {
				# do not print a zero on the current year, otherwise the line graph will dive down
				if(y==year && loads[y][i]==0)
					printf "\t" > "vol.dat";
				else
					printf "%d\t", loads[y][i] > "vol.dat";

				##### we used to hard code this in case we remove old years from the load_log.txt file
				# we need these next lines for the abstraction graph
				# loads[2016][i]=loads2016[w];
				# loads[2017][i]=loads2017[i];
			}
			printf "\n" > "vol.dat"; # end of month print a new line for the next month
		}
		#### end of loads per month graph plotting ####

		#### print data for the loads per day to loadsByDay.dat ####
		split(wknd, s, "|");            	# add weekend days to s ie s[1]=6, s[2]=7, s[3]=13, s[4]=14
                for(y in s) { wkndDate[s[y]]++ }	# move value of s[1] to wkndDate[s[1]] ie s[1]=6 to wkndDate[6]

		print "#Day", "Weekday", "Weekend" > "loadsByDay.dat"
                for(i=1;i<=maxdays;i++){
                        if(a[i]=="") Dloads="0" > "loadsByDay.dat";
                        else Dloads=a[i];

                        if(i in wkndDate) print i, "0", Dloads > "loadsByDay.dat";
                        else print i, Dloads, "0" > "loadsByDay.dat"
                }
		#### end of loads per month ####

		#### print data for abstraction graph to abstraction.dat ####
		if(month<4)
			year--;			# Reduce the year by one if we are in the first quarter of the year

       	        licence=72999996;		# abstraction licence to nearest multiplier of 12
		monthlylicence=licence/12;      # monthly abstraction licence
		permitted=monthlylicence;

		print "#1st of Month", "Permitted", "Delivered" > "abstraction.dat";	# print header
		print "Apr " year, 0, 0 > "abstraction.dat";				# day 1 we are at 0 licence with 0 abstraction

		# first loop is May - Dec
		for(i=5;i<=12;i++){
			# do not print a zero otherwise the graph will straighten off
			if(loads[year][i-1]==0)
				print m[i] " " year, permitted, "" > "abstraction.dat";
			else
				print m[i] " " year, permitted, delivered+=loads[year][i-1]*29500 > "abstraction.dat";
			permitted+=monthlylicence;
		}
		year++;	# move to the next year
		# second loop is Jan - March
		for(i=1;i<=4;i++){
			if(i==1){
				# do not print a zero otherwise the graph will straighten off
				if(loads[year-1][12]==0)
					print m[i] " " year, permitted, "" > "abstraction.dat";
				else
					print m[i] " " year, permitted, delivered+=loads[year-1][12]*29500 > "abstraction.dat";
			}
			else{
				if(loads[year][i-1]==0)
					print m[i] " " year, permitted, "" > "abstraction.dat";
				else
					print m[i] " " year, permitted, delivered+=loads[year][i-1]*29500 > "abstraction.dat";
			}
			permitted+=monthlylicence;
		}
		#### end of abstraction data ####
	} ' load_log.txt > "loadsByDay.dat"

plotVolume.pg &
plotVolumeDaily.pg &
plotAbstracted.pg &
wait
