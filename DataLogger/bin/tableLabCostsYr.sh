#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# tableLabCostsYr.sh — tableLabCosts.sh — Output an HTML table of our Lab costs
# Usage: tableLabCostsYr.sh
# Author: Charlie Marshall
# License: MIT

cd "${LOGS_DIR}" || exit

# Need to overwrite the year at the beginning of a new year
CURYEAR=$(date +%Y)
CURYEAR='2022'

while getopts ":y:af" opt; do
  case $opt in
    a) ALLYEARS='yes' ;;        # print all years data
    f) FINYR=yes ;;             # financial year required Apr - Mar
    y) YEAR=$OPTARG ;;          # specify the year
    \?)
      echo "Invalid option: -$OPTARG\nExiting..." >&2
      exit 1 ;;
    :) YEAR=$CURYEAR ;;         # no argument for -y supplied using current year
  esac
done

# INSERT PHP DROPDOWN MENU
php_print=`/usr/bin/php << 'EOF'
	<div id="test">
        	<form class="form-inline text-center" action="lab_results.php" method="POST">
	                <div class="form-group">
                	        <select class="form-control" id="year" name="year">
					<option value="">Select</option>
        	                        <optgroup label="Calendar Years">
	<?php
	  for($x=date("Y"); $x>2016; $x--)
	    echo '<option value="'.$x.'">'.$x.'</option>';
	?>
                        	                <option value="all">All</option>

                	                </optgroup>
        	                        <optgroup label="Tax Years">
	<?php
	  for($x=date("Y"); $x>2016; $x--)
	    echo '<option value="'.$x.'/'.($x+1).'">'.$x.' / '.($x+1).'</option>';
	?>
                                	</optgroup>
                        	</select>
                	</div>
        	</form>
	</div>
EOF`
# END OF PHP CODE

echo "$php_print" # Print above drop down menu

# Replace '$7', delivered date, for '$2' to base results on date of filling
awk -v yr=$YEAR -v curYr=$CURYEAR -v finyr=$FINYR -v allYrs=$ALLYEARS ' BEGIN { FS="\t"; OFS="</td><td>"; \

	# store previous years due to PO change
	tanks[2019][1]=227; dup[2019][1]=0; other[2019][1]=2; res[2019][1]=229; pPseudo[2019][1]=5; lab[2019][1]=4412.51; trips[2019][1]=25; tripCosts[2019][1]=337.5;
	tanks[2019][2]=68; dup[2019][2]=0; other[2019][2]=1; res[2019][2]=69; pPseudo[2019][2]=0; lab[2019][2]=1320.66; trips[2019][2]=9; tripCosts[2019][2]=121.5;
	# end of historic data

	print "<table id=\"myTable2\" class=\"table table-condensed table-bordered table-hover\" style=\"padding: 10px;\">\n" \
                        "<thead>\n" \
			"<tr><th>Month</th><th>Tanker tests</th><th>Tanker re-tests</th><th>Other tests</th><th>Total tests</th><th>Pres Pseudo</th><th>Lab Spend</th>" \
			"<th>Cost per Tanker</th><th>Commutes</th><th>Commute Costs<br> (&pound;20 per trip)</th><th>Commute per load</th><th>True load cost</th></tr>\n" \
			"</thead>\n<tbody>\n" }

        # we remove the leading zero of the month to allow us to store it in an array ie Jan = [1] instead of [01]
	FNR==NR	{
			year=substr($3, 7, 4); month=substr($3, 4, 2); sub(/^0/,"",month); lab[year][month]+=$15; res[year][month]++;
#			if($2 ~ /^[0-9]/)
			if($2 ~ /^([0-9]|blends)/)
				if(seen[$2]++) dup[year][month]++; else tanks[year][month]++;
			else other[year][month]++ # if the sample description does not begin with a number it is an other test NOT a tanker test

			# calculate the trips to the lab
			split($4,date,"/| ");	# break up date
			sub(/^0/,"",date[1]);	# day of month
			sub(/^0/,"",date[2]);	# month of year
			# date[3] is the year	# year

			if(!seenCommute[date[3]][date[2]][date[1]]++){
				trips[date[3]][date[2]]++;		# add commute to month
				tripCosts[date[3]][date[2]]+=20;	# add cost of commute, hardcoded 20 based on prompt
			}
			if($14 != "-") { pPseudo[year][month]++ }
        }


        END {
                # Add 2016 lab data as our records do not match the labs invoice, we are over by 221.73
#                split("48.24|478.99|961.02|1580.61|2382.57|1953.90|3345.92|2521.26|1188.78|2171.82|2199.63|1866.33",lab2016,"|");
#                for(w=1;w<=12;w++){
#                        lab[2016][w]+=lab2016[w];       # we += to include the 32.88 found in 2017, 1076-77
#                }
                # end of previous years

                split("Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec",m,"|");

                for(y=2017; y<=curYr; y++) {
                        for(i=1; i<=12; i++) {

				# if we are printing all data, print the main table now as we are looping through everything
				if(allYrs=="yes") {

					# handle division by 0
		                        if(lab[y][i]==0 || tanks[y][i]==0){
						averageTanker[y][i]=0;
						commuteLoad[y][i]=0;
					}
        		                else {
						# averageLoad=lab[y][i]/loads[y][i];
                		                averageTanker[y][i]=lab[y][i]/tanks[y][i];
						commuteLoad[y][i]=tripCosts[y][i]/tanks[y][i];
					}

					printf"<tr><td>%s %s"OFS"%d"OFS"%d"OFS"%d"OFS"%d"OFS"%d"OFS"&pound;%\047.2f"OFS"&pound;%\047.2f"OFS"%d"OFS"&pound;%\047.2f"OFS"&pound;%\047.2f"OFS"&pound;%\047.2f</td></tr>\n", \
						m[i], y, tanks[y][i], dup[y][i], other[y][i], res[y][i], pPseudo[y][i], lab[y][i], averageTanker[y][i], trips[y][i], tripCosts[y][i], commuteLoad[y][i], averageTanker[y][i]+commuteLoad[y][i] ;

	                	        totalTankers+=tanks[y][i];
        	        	        totalDup+=dup[y][i];
        	                	totalOther+=other[y][i];
        	                	totalRes+=res[y][i];
	        	                totalPseudo+=pPseudo[y][i];
					totalLab+=lab[y][i];
                	        	totalTrips+=trips[y][i];
	                        	totalTripCosts+=tripCosts[y][i];
				}
                        }
                }
                # print a calendar year
                if(allYrs!="yes" && finyr!="yes") {
                        for(i=1; i<=12; i++) {

	                        if(lab[yr][i]==0 || tanks[yr][i]==0){
					averageTanker[yr][i]=0;
					commuteLoad[yr][i]=0
				}
        	                else {
					# averageLoad=lab[yr][i]/loads[yr][i];
                	                averageTanker[yr][i]=lab[yr][i]/tanks[yr][i];
					commuteLoad[yr][i]=tripCosts[yr][i]/tanks[yr][i];
				}

				printf"<tr><td>%s %s"OFS"%d"OFS"%d"OFS"%d"OFS"%d"OFS"%d"OFS"&pound;%\047.2f"OFS"&pound;%\047.2f"OFS"%d"OFS"&pound;%\047.2f"OFS"&pound;%\047.2f"OFS"&pound;%\047.2f</td></tr>\n", \
					m[i], yr, tanks[yr][i], dup[yr][i], other[yr][i], res[yr][i], pPseudo[yr][i], lab[yr][i], averageTanker[yr][i], trips[yr][i], tripCosts[yr][i], commuteLoad[yr][i], averageTanker[yr][i]+commuteLoad[yr][i] ;

                	        totalTankers+=tanks[yr][i];
       	        	        totalDup+=dup[yr][i];
       	                	totalOther+=other[yr][i];
       	                	totalRes+=res[yr][i];
        	                totalPseudo+=pPseudo[yr][i];
				totalLab+=lab[yr][i];
               	        	totalTrips+=trips[yr][i];
                        	totalTripCosts+=tripCosts[yr][i];
                        }
                }
                # print a financial year
                else if(allYrs!="yes" && finyr=="yes") {
                        for(i=4; i<=12; i++) {

	                        if(lab[yr][i]==0 || tanks[yr][i]==0) {
					averageTanker[yr][i]=0;
					commuteLoad[yr][i]=0;
				}
        	                else {
					# averageLoad=lab[yr][i]/loads[yr][i];
                	                averageTanker[yr][i]=lab[yr][i]/tanks[yr][i];
					commuteLoad[yr][i]=tripCosts[yr][i]/tanks[yr][i];
				}

				printf"<tr><td>%s %s"OFS"%d"OFS"%d"OFS"%d"OFS"%d"OFS"%d"OFS"&pound;%\047.2f"OFS"&pound;%\047.2f"OFS"%d"OFS"&pound;%\047.2f"OFS"&pound;%\047.2f"OFS"&pound;%\047.2f</td></tr>\n", \
					m[i], yr, tanks[yr][i], dup[yr][i], other[yr][i], res[yr][i], pPseudo[yr][i], lab[yr][i], averageTanker[yr][i], trips[yr][i], tripCosts[yr][i], commuteLoad[yr][i], averageTanker[yr][i]+commuteLoad[yr][i] ;


                	        totalTankers+=tanks[yr][i];
       	        	        totalDup+=dup[yr][i];
       	                	totalOther+=other[yr][i];
       	                	totalRes+=res[yr][i];
        	                totalPseudo+=pPseudo[yr][i];
				totalLab+=lab[yr][i];
               	        	totalTrips+=trips[yr][i];
                        	totalTripCosts+=tripCosts[yr][i];
                        }
                        yr++;
                        for(i=1; i<=3; i++) {

	                        if(lab[yr][i]==0 || tanks[yr][i]==0) {
					averageTanker[yr][i]=0;
					commuteLoad[yr][i]=0;
				}
        	                else {
					# averageLoad=lab[yr][i]/loads[yr][i];
                	                averageTanker[yr][i]=lab[yr][i]/tanks[yr][i];
					commuteLoad[yr][i]=tripCosts[yr][i]/tanks[yr][i];
				}

				printf"<tr><td>%s %s"OFS"%d"OFS"%d"OFS"%d"OFS"%d"OFS"%d"OFS"&pound;%\047.2f"OFS"&pound;%\047.2f"OFS"%d"OFS"&pound;%\047.2f"OFS"&pound;%\047.2f"OFS"&pound;%\047.2f</td></tr>\n", \
					m[i], yr, tanks[yr][i], dup[yr][i], other[yr][i], res[yr][i], pPseudo[yr][i], lab[yr][i], averageTanker[yr][i], trips[yr][i], tripCosts[yr][i], commuteLoad[yr][i], averageTanker[yr][i]+commuteLoad[yr][i] ;

                	        totalTankers+=tanks[yr][i];
       	        	        totalDup+=dup[yr][i];
       	                	totalOther+=other[yr][i];
       	                	totalRes+=res[yr][i];
        	                totalPseudo+=pPseudo[yr][i];
				totalLab+=lab[yr][i];
               	        	totalTrips+=trips[yr][i];
                        	totalTripCosts+=tripCosts[yr][i];
                        }
                }

		printf("\n<tr><th>Total</th><th>%d</th><th>%d</th><th>%d</th><th>%d</th><th>%d</th><th>&pound;%\047.2f</th><th>&pound;%\047.2f</th><th>%d</th><th>&pound;%\047.2f</th><th>&pound;%\047.2f**</th><th>&pound;%\047.2f**</th></tr>\n", \
			totalTankers, totalDup, totalOther, totalRes, totalPseudo, totalLab, totalLab/totalTankers, totalTrips, totalTripCosts, totalTripCosts/totalTankers, (totalLab/totalTankers)+ (totalTripCosts/totalTankers) );
		printf "<tr><td colspan="12">&nbsp;</td></tr>\n"
		print "<tr><td>Target</td><td colspan="6">&nbsp;" OFS "&pound;20.75</td><td colspan="4">&nbsp;</td></tr>\n</tbody></table>\n" \
			"Cost per tanker = lab spend / number of tanker tests<br>" \
			"Commute per load = Commute costs / number of tanker tests<br>True load cost = cost per load + commure per load<br><br>\n" \
			"Method change for Presumptive Pseduo: 20/11/2017<br><br>\n" \
			"* Average<br>\n" ;

	} ' lab_log.txt
