#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# tableLabCosts.sh — Output an HTML table of our Lab costs
# Usage: tableLabCosts.sh
# Author: Charlie Marshall
# License: MIT

cd "${LOGS_DIR}" || exit

YEAR=$(date +%Y)
YEAR='2022'

php_print=`/usr/bin/php << 'EOF'
	<div id="test">
        	<form class="form-inline text-center" action="lab_results.php" method="POST">
	                <div class="form-group">
                	        <select class="form-control" id="year" name="year">
					<option value="">Select</option>
        	                        <optgroup label="Calendar Years">
	<?php
	  for($x=date("Y"); $x>2015; $x--)
	    echo '<option value="'.$x.'">'.$x.'</option>';
	?>
                        	                <option value="all">All</option>

                	                </optgroup>
        	                        <optgroup label="Tax Years">
	<?php
	  for($x=date("Y"); $x>2014; $x--)
	    echo '<option value="'.$x.'/'.($x+1).'">'.$x.' / '.($x+1).'</option>';
	?>
                                	</optgroup>
                        	</select>
                	</div>
        	</form>
	</div>
EOF`

echo "$php_print" # Print above drop down menu


# Replace '$7', delivered date, for '$2' to base results on date of filling
awk -v year=$YEAR ' BEGIN { FS="\t"; OFS="</td><td>"; \
	print "<table id=\"myTable2\" class=\"table table-condensed table-bordered table-hover\" style=\"padding: 10px;\">\n" \
                        "<thead>\n" \
			"<tr><th>Month</th><th>Tanker tests</th><th>Tanker re-tests</th><th>Other tests</th><th>Total tests</th><th>Pres Pseudo</th><th>Lab Spend</th>" \
			"<th>Cost per Tanker</th><th>Commutes</th><th>Commute Costs (45ppm)</th><th>Commute per load</th><th>True load cost</th></tr>\n" \
			"</thead>\n<tbody>\n" }

	FNR==NR && $3 ~ year {
		# we remove the leading zero of the month to allow us to store it in an array ie Jan = [1] instead of [01]
		month=substr($3, 4, 2); sub(/^0/,"",month); lab[month]+=$15; res[month]++;
		if($2 ~ /^[0-9]/)
			if(seen[$2]++) dup[month]++; else tanks[month]++;
		else other[month]++			# if the sample description does not begin with a number it is an other test NOT a tanker test
	}
	FNR==NR && $4 ~ year {				# calculate the trips to the lab
		split($4,date,"/");			# break up date
		sub(/^0/,"",date[1]);			# day of month
		sub(/^0/,"",date[2]);			# month of year
		if(!seenCommute[date[1]date[2]]++){
			trips[date[2]]++;		# add commute to month
			tripCosts[date[2]]+=13.5;	# add cost of commute, hardcoded 13.50
		}
	}

	FNR==NR && $14 != "-" { pPseudo[month]++ }

	############### We are not currently using the load_log.txt file
#	FNR!=NR { yr=substr($7, 7, 4); month=substr($7, 4, 2); sub(/^0/,"",month); loads[yr][month]++; next }

	END {
		######### MANUAL CORRECTION ########################################################
#		if(year==2017){
#			lab[1]+=32.88;				# 1076-1077 were loaded and sampled in December 2016, cost £32.88
#			res[1]+=2; tanks[1]+=2;			# add two to the number of results for the two December 2016 samples
#		}
		####################################################################################

		m=split("Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec",d,"|");

		#### print table of data ####
		for(i=1; i<=m; i++) {
			totalLab+=lab[i];
#			totalLoads+=loads[year][i];
			totalRes+=res[i];
			totalTankers+=tanks[i];
			totalOther+=other[i];
			totalPseudo+=pPseudo[i];
			totalDup+=dup[i];
			totalTrips+=trips[i];
			totalTripCosts+=tripCosts[i];
			if(lab[i]==0 || tanks[i]==0){ averageTanker=0; commuteLoad=0 }
			else { #averageLoad=lab[i]/loads[year][i];
				averageTanker=lab[i]/tanks[i]; commuteLoad=tripCosts[i]/tanks[i] }
			# if we want to show number of loads add loads[i] & totalLoads
			printf"<tr><td>%s"OFS"%d"OFS"%d"OFS"%d"OFS"%d"OFS"%d"OFS"&pound;%\047.2f"OFS"&pound;%\047.2f"OFS"%d"OFS"&pound;%\047.2f"OFS"&pound;%\047.2f"OFS"&pound;%\047.2f</td></tr>\n", \
				d[i], tanks[i], dup[i], other[i], res[i], pPseudo[i], lab[i], averageTanker, trips[i], tripCosts[i], commuteLoad, averageTanker+commuteLoad ;

		}
		printf("\n<tr><th>Total</th><th>%d</th><th>%d</th><th>%d</th><th>%d</th><th>%d</th><th>&pound;%\047.2f</th><th>&pound;%\047.2f</th><th>%d</th><th>&pound;%\047.2f</th><th>&pound;%\047.2f**</th><th>&pound;%\047.2f**</th></tr>\n", \
			totalTankers, totalDup, totalOther, totalRes, totalPseudo, totalLab, totalLab/totalTankers, totalTrips, totalTripCosts, totalTripCosts/totalTankers, (totalLab/totalTankers)+ (totalTripCosts/totalTankers) );
		printf "<tr><td colspan="12">&nbsp;</td></tr>\n"
		print "<tr><td>Target</td><td colspan="6">&nbsp;" OFS "&pound;19.50</td><td colspan="4">&nbsp;</td></tr>\n</tbody></table>\n" \
			"Cost per tanker = lab spend / number of tanker tests<br>" \
			"Commute per load = Commute costs / number of tanker tests<br>True load cost = cost per load + commure per load<br><br>\n" \
			"Method change for Presumptive Pseduo: 20/11/2017<br><br>\n" \
			"* Average<br>\n" ;

# print "total Loads " totalLoads;

	} ' lab_log.txt # load_log.txt
#	} ' 2016/lab_log2016.txt load_log.txt
