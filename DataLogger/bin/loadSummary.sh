#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# loadSummary.sh — A script to produce an HTML table of all the data (load, tank, tanker and lab) we have related to the specified load number
# Usage: loadSummary.sh loadNo eg loadSummary.sh 4444
# Author: Charlie Marshall
# License: MIT

cd "${LOGS_DIR}" || exit

awk -v loadno="$1" ' BEGIN { OFS="</td><td>"; FS="\t"; \
		print	"<b>Load: " loadno "</b>\n" \
			"<table id=\"fillTable\" class=\"table table-condensed table-bordered table-hover tablesorter\" style=\"padding: 10px;\">\n" \
			"<caption style=\"font-size:12pt\">Filling details</caption>" \
			"<thead>\n" \
                        	"<tr>\n" \
                                	"<th>Loading Date & Time</th>\n" \
                                	"<th>Point</th>\n" \
	                                "<th>Tank</th>\n" \
        	                        "<th>PH</th>\n" \
                	                "<th>Cond</th>\n" \
                        	        "<th>Temp</th>\n" \
                                	"<th>Status</th>\n" \
	                                "<th>Set Level</th>\n" \
        	                       	"<th>Pumped</th>\n" \
                	               	"<th>Speed</th>\n" \
                        	       	"<th>Mins Remain</th>\n" \
                               		"<th>Tank Level</th>\n" \
        	                       	"<th>Auto Fill</th>\n" \
	                               	"<th>Set Level</th>\n" \
                	               	"<th>Inlet</th>\n" \
	                        "</tr>\n" \
        	        "</thead>\n" \
                	"<tbody>";
	}
	FILENAME==ARGV[1] && $1==loadno && $8 != "OFFLINE" {			# panel_log.txt
		# store the print out in an array which we will use in the next file
		load[$2$3] = $2 OFS $3 OFS $4 OFS $5 OFS $6 OFS $7 OFS $8 OFS $9 OFS $10 OFS $11 OFS $12 OFS
		next;
	}
	FILENAME==ARGV[2] && $2$3 in load{							# tank_log.txt
		# print the load array using the date, time and point FOLLOWED by the tank details
		print "<tr><td>" load[$2$3] $4 OFS $5 OFS $6 OFS $7 "</td></tr>";
		next;
        }
	FILENAME==ARGV[3] && $2==loadno {					# lab_log.txt
		# we use a counter 'cert++' in case there are more then one certificate per load

		if ($5>0 || $6>0 || $7>0 || $8>0) {OFS="</td><td style=\"background: yellow\">"} #  add a yellow background if there is a failure
		lab[cert++] = $2 OFS $16 OFS $1 OFS $3 OFS $4 OFS $5 OFS $6 OFS $7 OFS $8 OFS $9 OFS $10 OFS $11 OFS $12 OFS $13 OFS $14 OFS "&pound;" $15;
		OFS = "</td><td>"; # reset it to normal
		next;
	}
	FILENAME==ARGV[4] {							# load_log.txt
		delcount[$9]++; # store the number of loads per every clearning cert
		if($1==loadno){
			cipCert=$9; delno=delcount[$9]; deldate=$7; loadersname=$10; samplersname=$11; driversname=$12;

			split($2,l,"/| |:");    # split the loading date and time
			loaddate=mktime(l[3]" "l[2]" "l[1]" "l[4]" "l[5]" 00");

			next;
		}
	}
	FILENAME==ARGV[5] && $1==cipCert {					# tanker_log.txt
		id=$2; cipdate=$3;
		split(cipdate,c,"/| |:");       cipcalcdate=mktime(c[3]" "c[2]" "c[1]" "c[4]" "c[5]" 00");
		nextfile;
	}

	END {
		print "</tbody></table>\n\n" \
			"<table  id=\"tankerTable\" class=\"table table-condensed table-bordered table-hover tablesorter\" style=\"padding: 10px;\">\n" \
			"<caption style=\"font-size:12pt\">Tanker details</caption>\n" \
                	"<thead>\n" \
                        	"<tr>\n" \
                                	"<th>Tanker ID</th>\n" \
	                                "<th>Cert No</th>\n" \
        	                        "<th>Del No</th>\n" \
                	                "<th>CIP Date & Time</th>\n" \
                        	        "<th>Days since CIP</th>\n" \
                                        "<th>Del Date</th>\n" \
	                                "<th>Loaders Name</th>\n" \
        	                        "<th>Samplers Name</th>\n" \
                	                "<th>Drivers Name</th>\n" \
	                        "</tr>\n" \
        	        "</thead>\n" \
                	"<tbody>";

		printf ( "<tr><td>%s</td><td><a href=\"#\" data-type=\"tankerCert\" data-value=\"%d\">%d</a></td><td>%d of %d</td><td>%s</td><td>%d</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td></tr>", \
			id, cipCert, cipCert, delno, delcount[cipCert], cipdate, (((loaddate-cipcalcdate)/60)/60)/24, deldate, loadersname,samplersname,driversname );

                print "</tbody></table>\n\n";

                #################

		if (cert!=""){		# print table if there is data. For some reason a blank table results in the filling table not being sortable

	                print "<table  id=\"labTable\" class=\"table table-condensed table-bordered table-hover tablesorter\" style=\"padding: 10px;\">\n" \
       			        "<caption style=\"font-size:12pt\">Lab results</caption>\n" \
                		"<thead>\n" \
		                        "<tr>\n" \
       			                        "<th>Load No</th>\n" \
       			                        "<th>SU No</th>\n" \
               			                "<th>Cert No</th>\n" \
                       			        "<th>Sample Date</th>\n" \
                                		"<th>Lab Received</th>\n" \
		                                "<th>Coliform</th>\n" \
       			                        "<th>E. coli</th>\n" \
               			                "<th>Enterococci</th>\n" \
                       			        "<th>Pseudo</th>\n" \
                        		        "<th>TVC 37</th>\n" \
       		                        	"<th>TVC 22</th>\n" \
	                	                "<th>Pres Coliform</th>\n" \
						"<th>Pres E. coli</th>\n" \
       			                         "<th>Pres Enterococci</th>\n" \
       			                        "<th>Pres Pseudo</th>\n" \
               			                "<th>Cost</th>\n" \
	                        	"</tr>\n" \
        		        "</thead>\n" \
       	        		"<tbody>";

               		for (i in lab){ print "<tr><td>" lab[i] "</td></tr>" }
                	print "</tbody></table>\n";
		}
	}' panel_log.txt tank_log.txt lab_log.txt load_log.txt tanker_log.txt
