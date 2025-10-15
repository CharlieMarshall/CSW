#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# volumes.sh — A script to parse the log files and generate an HTML monthly volumes/profit table
# Usage: volumes.sh [-y YEAR] [-a] [-f] [-h]
#  -y YEAR      Year to display (default: $CURYEAR)
#  -a           Print all years data
#  -f           Switch to financial year (Apr-Mar)
#  -h           Show this help
#
# Author: Charlie Marshall
# License: MIT

CURYEAR=$(date +%Y)
CURYEAR='2022'
YEAR="$CURYEAR"
FINYR="no"
ALLYEARS="no"

usage() {
  cat <<EOF
Usage: $0 [-y %YYYY] [-a] [-f] [-h]
  -y YEAR      Year to display (default: $CURYEAR)
  -a           Print all years data
  -f           Switch to financial year (Apr-Mar)
  -h           Show this help
EOF
  exit 1
}

# ---- parse args ----
while getopts ":y:afh" opt; do
  case "$opt" in
    y) YEAR="$OPTARG" ;;
    a) ALLYEARS="yes" ;;
    f) FINYR="yes" ;;
    h) usage ;;
    :) echo "Option -$OPTARG requires an argument." >&2; usage ;;
    \?) echo "Invalid option: -$OPTARG" >&2; usage ;;
  esac
done
shift $((OPTIND-1))

awk -v yr="$YEAR" -v curYr="$CURYEAR" -v finyr="$FINYR" -v allYrs="$ALLYEARS" '
	BEGIN {	FS=OFS="\t";

		# split does not work without declaring the 2D arrays so we initialise the first index to 0
		for(i=2016; i<=curYr; i++){
			loads[i][1]=0;
			lab[i][1]=0;
		}

		split("Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec",m,"|");

		# Add previous years data as the PO was reset
		split("0|10|46|80|120|87|168|135|67|117|125|108",loads[2016],"|");
		split("165|52|186|156|212|157|174|192|26|170|125|176",loads[2017],"|");
		split("165|149|159|181|240|235|219|236|178|158|154|148",loads[2018],"|");
		split("228|69",loads[2019],"|");

		split("48.24|478.99|961.02|1580.61|2382.57|1953.90|3345.92|2521.26|1188.78|2171.82|2199.63|1866.33",lab[2016],"|");
		split("2867.74|848.84|3277.75|2998.30|4024.56|3068.22|3241.25|3649.99|1455.85|3235.41|2341.19|3249.85",lab[2017],"|");
		split("3144.74|2759.66|2819.77|3516.54|4730.25|4535.82|4295.83|4611.35|3502.26|3057.99|3039.95|2852.55",lab[2018],"|");
		split("4412.51|1320.66",lab[2019],"|");

		# We only need to hold this informatino for the current year, when in 2020 we can delete these
		# Current years calculates averageLabCosts off No. tankers, previous years off No. Loads
		tankers[2019][1]=227;
		tankers[2019][2]=68;

		print "<table id=\"myTable\" class=\"table table-condensed table-bordered table-hover \" style=\"padding: 10px;\">\n" \
                        "<thead>\n" \
                                "<tr>\n" \
					"<th>Month</th>\n" \
                                        "<th>No. Loads</th>\n" \
                                        "<th>No. Litres</th>\n" \
                                        "<th>Sales</th>\n" \
                                        "<th>Overheads</th>\n" \
                                        "<th>Lab Costs</th>\n" \
                                        "<th>Capital Repaid</th>\n" \
                                        "<th>Profit</th>\n" \
                                "</tr>\n" \
                        "</thead>\n" \
                        "<tbody>";
	}
	# we remove the leading zero of the month to allow us to store it in an array ie Jan = [1] instead of [01]
	FNR==NR {		year=substr($7, 7, 4); month=substr($7, 4, 2); sub(/^0/,"",month); loads[year][month]++; next }
	FILENAME==ARGV[2] {	year=substr($3, 7, 4); month=substr($3, 4, 2); sub(/^0/,"",month); lab[year][month]+=$15; if($2 ~ /^[0-9]/) { if(!seen[$2]++) { tankers[year][month]++ } } }
	FILENAME==ARGV[3] {	ov[$1][$2]=$3 }		# $1 is the year. $2 is the month and $3 is the overhead value

	END {
		# loop through all the years and months and allocate a price for the sales and capital where applicable
		# cleaned with fictitious prices
		for(y=2016; y<=curYr; y++) {
			volHeader = volHeader "\t" y;	# store header for printing the volume graph data file
			for(i=1; i<=12; i++) {
				if( y==2016 ) {
					capLoad=65.50;
					salesLoad=150;
				}
				else if( y==2017 && i<9 ) {
	        	        	capLoad=68.90;
	       	        	        salesLoad=200;
				}
				else if ( y==2017 || y==2018 ) {
					capLoad=98.90;
					salesLoad=230;
				}
				else if ( y==2019 && i==1 ) {
					loadsOldPrices=154;	# hardcoded number of loads we had remaining at the end of 2018
					capLoad=(loadsOldPrices * 98.90) / loads[y][i];
					salesLoad=( (loadsOldPrices * 230) + ( (loads[y][i] - loadsOldPrices) * 136 ) ) / loads[y][i];
				}
				else if ( y==2019 || y==2020 || (y==2021 && i<4) ) {
					capLoad=0;
					salesLoad=136;
				}
				else if ( y==2021 ) {
					capLoad=0;
					salesLoad=138.38;
				}
				else if ( y>=2022 ) {
					capLoad=0;
					salesLoad=140.75;
				}

				# calculate data and store in arrays
				litres[y][i]=loads[y][i]*29500;
				cap[y][i]=loads[y][i]*capLoad;
				sales[y][i]=loads[y][i]*salesLoad;
				profit[y][i]=sales[y][i]-(cap[y][i] + ov[y][i] + lab[y][i]);

				# data needed for capital graph, no longer needed as we have repaid
				# capYr[y]+=cap[y][i];		# accumulate yearly capital repaid
				# totalSpent-=cap[y][i];	# deduct capital from total outlaid

				# if we are printing all data, print the main table now as we are looping through everything
				if(allYrs=="yes") {
					printf "<tr><td>%s %s</td><td>%d</td><td>%\047d</td><td>&pound;%\047.2f</td><td>&pound;%\047.2f</td><td>&pound;%\047.2f</td><td>&pound;%\047.2f</td><td>&pound;%\047.2f</td></tr>\n", \
					m[i] , y, loads[y][i] , litres[y][i] , sales[y][i] , ov[y][i] , lab[y][i] , cap[y][i] , profit[y][i];

				totalLoads+=loads[y][i]; totalLitres+=litres[y][i]; totalSales+=sales[y][i]; totalLab+=lab[y][i]; totalOver+=ov[y][i]; totalCap+=cap[y][i];
				totalTankers+=tankers[y][i];   # totalProfit+=profit; # totalProfit is not currently used
				}
			}
		}

		# print a calendar year
		if(allYrs!="yes" && finyr!="yes") {
			for(i=1; i<=12; i++) {
				printf "<tr><td>%s %s</td><td>%d</td><td>%\047d</td><td>&pound;%\047.2f</td><td>&pound;%\047.2f</td><td>&pound;%\047.2f</td><td>&pound;%\047.2f</td><td>&pound;%\047.2f</td></tr>\n", \
					m[i] , yr, loads[yr][i] , litres[yr][i] , sales[yr][i] , ov[yr][i] , lab[yr][i] , cap[yr][i] , profit[yr][i];
				totalLoads+=loads[yr][i]; totalLitres+=litres[yr][i]; totalSales+=sales[yr][i]; totalLab+=lab[yr][i]; totalOver+=ov[yr][i]; totalCap+=cap[yr][i];
				totalTankers+=tankers[yr][i];   # totalProfit+=profit; # totalProfit is not currently used
			}
		}
		# print a financial year
		else if(allYrs!="yes" && finyr=="yes") {
			for(i=4; i<=12; i++) {
				printf "<tr><td>%s %s</td><td>%d</td><td>%\047d</td><td>&pound;%\047.2f</td><td>&pound;%\047.2f</td><td>&pound;%\047.2f</td><td>&pound;%\047.2f</td><td>&pound;%\047.2f</td></tr>\n", \
					m[i] , yr, loads[yr][i] , litres[yr][i] , sales[yr][i] , ov[yr][i] , lab[yr][i] , cap[yr][i] , profit[yr][i];
				totalLoads+=loads[yr][i]; totalLitres+=litres[yr][i]; totalSales+=sales[yr][i]; totalLab+=lab[yr][i]; totalOver+=ov[yr][i]; totalCap+=cap[yr][i];
				totalTankers+=tankers[yr][i];   # totalProfit+=profit; # totalProfit is not currently used
			}
			yr++;
			for(i=1; i<=3; i++) {
				printf "<tr><td>%s %s</td><td>%d</td><td>%\047d</td><td>&pound;%\047.2f</td><td>&pound;%\047.2f</td><td>&pound;%\047.2f</td><td>&pound;%\047.2f</td><td>&pound;%\047.2f</td></tr>\n", \
					m[i] , yr, loads[yr][i] , litres[yr][i] , sales[yr][i] , ov[yr][i] , lab[yr][i] , cap[yr][i] , profit[yr][i];
				totalLoads+=loads[yr][i]; totalLitres+=litres[yr][i]; totalSales+=sales[yr][i]; totalLab+=lab[yr][i]; totalOver+=ov[yr][i]; totalCap+=cap[yr][i];
				totalTankers+=tankers[yr][i];   # totalProfit+=profit; # totalProfit is not currently used
			}
		}

		# print total
		printf "<tr><th>Total</th><th>%d</th><th>%\047d</th><th>&pound;%\047.2f</th><th>&pound;%\047.2f</th><th>&pound;%\047.2f</th><th>&pound;%\047.2f</th><th>&pound;%\047.2f</th></tr>\n", \
			totalLoads , totalLitres , totalSales , totalOver , totalLab , totalCap , totalSales - (totalOver + totalLab + totalCap);

		# handle division by 0 errors
		if(totalLoads>0){
			if(totalLab>0) {
				# if we are printing the current calendar year OR the current financial year: calculate the average cost per tanker otherwise per load
				if( (finyr!="yes" && curYr==yr) || (finyr=="yes" && curYr==yr-1) )
					averageLabCost = totalLab/totalTankers;
				else
					averageLabCost = totalLab/totalLoads;
			}
			if(totalOver>0)
				averageOverhead = totalOver/totalLoads;
			if(totalCap>0)
				averageCapital = totalCap/totalLoads;

			profitLoad = (totalSales/totalLoads) - ( averageCapital + averageLabCost + averageOverhead );

			# print  per load
			printf "<tr><td colspan="8">&nbsp;</td></tr>\n<tr><td>Per Load</td><td>1</td><td>29,500</td><td>&pound;%\047.2f</td><td>&pound;%\047.2f</td>" \
				"<td>&pound;%\047.2f</td><td>&pound;%\047.2f</td><td>&pound;%\047.2f</td></tr>\n",totalSales/totalLoads, averageOverhead, averageLabCost, averageCapital, profitLoad;
		}

		print "</tbody></table>"
		#### end of table of data ####

#print "Total tankers: " totalTankers ;
#print "Total Loads: " totalLoads ;

		#### print data for number of loads per month graph to 'vol.dat'

##### this block uses only one write to a file
##### WORKS FINE BUT NO REAL IMPROVEMENT
#		vol = "#Month" volHeader "\n";					# print header
#		for(i=1; i<=12; i++) {
#			vol = vol m[i] "\t";					# print month name
#			for(y=2016; y<=curYr; y++)
#				vol = vol loads[y][i]  "\t";		# print no. of loads per month for each year
#			vol = vol "\n";					# print newline
#		}
#		printf vol > "vol.dat";
######
###### OR
######
		print "#Month" volHeader > "vol.dat";				# print header
		for(i=1; i<=12; i++) {
			printf "%s\t", m[i] > "vol.dat";			# print month name
			for(y=2016; y<=curYr; y++)
				printf "%d\t", loads[y][i] > "vol.dat";		# print no. of loads per month for each year
			printf "\n" > "vol.dat";				# print newline
		}
		#### end of loads per month graph plotting ####


###### NO LONGER NEED A CAPITAL GRAPH
		#### print data for capital repayments graph to 'capital.dat' NOTE WE ARE USING TAB SEPARATORS ####
#		for(y=2016; y<=curYr; y++)
#			printf "%d\t%.2f\n", y, capYr[y] > "capital.dat";

		# printf "Oustanding %.2f\n", totalSpent  > "capital.dat"; # commented out line as we now display the number of remaining loads to clear the capital
#		printf "Oustanding (%.1f Loads)\t%.2f\n", totalSpent / capLoad, totalSpent  > "capital.dat";
		#### end of capital data ####
#####

	} ' "${LOGS_DIR}/load_log.txt" "${LOGS_DIR}/lab_log.txt" "${LOGS_DIR}/overheads_log.txt"

# plotCapital.pg &
plotVolume.pg &
wait
