#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# json.sh — A script is a duplication and merging of 3 individual scripts. It parses the log files and creates a csv output of 3 blocks (volumes, loads by day and abstraction).
# This allows our php server to call this one script as opposed to the 3 individual scripts which produce this data
# Usage: json.sh
# Author: Charlie Marshall
# License: MIT

CURYEAR=$(date +%Y)
read YEAR MONTH < <(date '+%Y %m')

# sanitising
CURYEAR='2022'
YEAR='2022'
MONTH='2'

# HIGHLIGHTING -h must be turned off for the following lines to work, otherwise it fails when run on the last day of the month
######### SOME VERY UNUSUAL BUG - cannot use 'ncal -h' as with AJAX calls it does not default to begining a week on a Monday -M
######### Therefore we get incorrect weekend days, must use 'cal -NM' or 'ncal -M' instead #########
#daysInMonth=$(cal -h $MONTH $YEAR | awk 'NF {DAYS = $NF}; END {print DAYS}' )
#wknd=$(cal -h $MONTH $YEAR  | awk ' NR==3 && NF { if(NF==7) { printf $1 "|" $NF "|" } else { printf $NF "|" } } NR>3 && NF { printf $1 "|"; if(NF==7) printf $7 "|"} ' )
daysInMonth=$(ncal -h $MONTH $YEAR | awk 'NF {DAYS = $NF}; END {print DAYS}' )
wknd=$(ncal -h $MONTH $YEAR  | awk ' NR==3 && NF { if(NF==7) { printf $1 "|" $NF "|" } else { printf $NF "|" } } NR>3 && NF { printf $1 "|"; if(NF==7) printf $7 "|"} ' )

awk -v curYr=$CURYEAR -v year=$YEAR -v month=$MONTH -v maxdays=$daysInMonth -v wknd=$wknd '
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


		# Print number of loads per month data
		print "January,February,March,April,May,June,July,August,September,October,November,December";
		for(y=2016; y<=curYr; y++) {
#			printf("%d:", y);

			# extra for loop just to get the total for the labels
			sumLoads=0;
			for(i=1; i<=12; i++) {sumLoads +=loads[y][i] }
				printf "%d (%d loads):",y ,sumLoads;


		        for(i=1; i<=12; i++) {
                		if(i==12) {
		                        printf "%d", loads[y][i];
				}
                		else
		                        printf "%d,", loads[y][i];
		        }
		        if(y!=curYr)
		               printf "\n";
		}

print "\n|"


		#### print data for the loads per day
		split(wknd, s, "|");            	# add weekend days to s ie s[1]=6, s[2]=7, s[3]=13, s[4]=14
                for(y in s) { wkndDate[s[y]]++ }	# move value of s[1] to wkndDate[s[1]] ie s[1]=6 to wkndDate[6]

#		print "#Day", "Weekday", "Weekend"
#                for(i=1;i<=maxdays;i++){
#                        if(a[i]=="") Dloads="0";
#                        else Dloads=a[i];
#
#                        if(i in wkndDate) printf i ",0," Dloads "\n";
#                        else printf i "," Dloads ",0\n";
#                }
		#### end of loads per month ####

		# print days of month
                for(i=1;i<=maxdays;i++){
			printf i;
			if(i<maxdays)
				printf ",";
		}
		printf "\nWeekdays:"

		# print weekdays
                for(i=1;i<=maxdays;i++){
                        if(a[i]=="") Dloads="0";
                        else Dloads=a[i];

                        if(i in wkndDate) printf "0";
                        else printf Dloads;

			if(i<maxdays)
				printf ",";
                }
		printf "\nWeekends:";

		# print wknds
                for(i=1;i<=maxdays;i++){
                        if(a[i]=="") Dloads="0";
                        else Dloads=a[i];

                        if(i in wkndDate) printf Dloads;
                        else printf "0";

			if(i<maxdays)
				printf ",";
                }
		printf "\n";


printf "|\n"



		#### print data for abstraction graph
		if(month<4)
			year--;			# Reduce the year by one if we are in the first quarter of the year

		printf "April,May,June,July,August,September,October,November,December,January,February,March,April\nPermitted:";
		# print permitted
		for(i=0;i<12;i++) {
			printf "%d,", (73000/12)*i;
		}
		printf "%d\nAbstracted:0", 73000;

		# first loop is May - Dec
		for(i=5;i<=12;i++){
			printf ",%d", delivered+=loads[year][i-1]*29.5;
		}
		year++;	# move to the next year
		# second loop is Jan - March
		for(i=1;i<=4;i++){
			if(i==1)
				printf ",%d", delivered+=loads[year-1][12]*29.5;
			else
				printf ",%d", delivered+=loads[year][i-1]*29.5;
		}
		#### end of abstraction data ####

	} ' "${LOGS_DIR}/load_log.txt"
