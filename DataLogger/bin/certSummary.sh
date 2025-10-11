#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# certSummary.sh — A script to show the loads and lab results for every load for a specified tanker certificates in HTML
# Usage: certSummary.sh certNo eg ./certSummary.sh 206744
# Author: Charlie Marshall
# License: MIT

certNo="$1"

cd "${LOGS_DIR}" || exit

echo -e "<b>All loads delivered by:</b><br>\n"

awk -v certno="$certNo" 'BEGIN { FS="\t"; OFS="</td><td>"; }

	# Find matching cert in tanker_log
        FILENAME = ARGV[1] && $1==certno {
                split($3,c,"/| |:");	cipdate=mktime(c[3]" "c[2]" "c[1]" "c[4]" "c[5]" 00");
		printf "Tanker: %s, CIP Cert No: %d<br>CIP Date and Time: %s<br>\n\n", $2, certno, $3;
		nextfile;
        }
	# Find all loads with matching tanker cert
	FILENAME = ARGV[2] && $9==certno {
		split($2,l,"/| |:");
		loaddate=mktime(l[3]" "l[2]" "l[1]" "l[4]" "l[5]" 00");
		load[++i]=$1 FS $2 FS (((loaddate-cipdate)/60)/60)/24 FS $7 FS $3 FS $4 FS $5 FS $6 FS $10 FS $11 FS $12;
		a[$1]++; next;
	}
	FILENAME = ARGV[3] && $2 in a {
		b[$2]="<td><a href=\"#\" data-type=\"loadno\" data-value=\""$2"\">"$2"</a>" OFS $1 OFS $3 OFS $4 OFS $5 OFS $6 OFS $7 OFS $8 OFS $9 OFS $10 \
                        OFS $11 OFS $12 OFS $13 OFS $14 OFS "&pound;"$15"</td>";
	}
	END {
		print "<table  id=\"fillTable\" class=\"table table-condensed table-bordered table-hover tablesorter\" style=\"padding: 10px;\">\n" \
                	"<thead>\n" \
                        	"<tr>\n" \
                                	"<th>Del No</th>\n" \
	                                "<th>Load No</th>\n" \
        	                        "<th>Loading Date & Time</th>\n" \
                	                "<th>Days since CIP</th>\n" \
                        	        "<th>Del Date</th>\n" \
	                                "<th>Point</th>\n" \
        	                        "<th>Tank</th>\n" \
                	                "<th>PH</th>\n" \
                        	        "<th>Cond</th>\n" \
                                	"<th>Loaders Name</th>\n" \
	                                "<th>Samplers Name</th>\n" \
        	                        "<th>Drivers Name</th>\n" \
	                        "</tr>\n" \
	                "</thead>\n" \
	                "<tbody>";

		for (x in load) {
			split(load[x],l,FS);
			printf "<tr><td>%d" OFS "<a href=\"#\" data-type=\"loadno\" data-value=\"%d\">%d</a>" OFS "%s" OFS "%d" OFS "%s" OFS "%s" OFS "%d" OFS \
								"%.2f" OFS "%.1f" OFS "%s" OFS "%s" OFS "%s</td></tr>\n" \
								, x, l[1], l[1], l[2], l[3], l[4], l[5], l[6], l[7], l[8], l[9], l[10], l[11];
		}
                print "</tbody></table>\n\n";


		# lab results
		print "<table id=\"labTable\" class=\"table table-condensed table-bordered table-hover tablesorter\" style=\"padding: 10px;\">\n" \
			"<caption style=\"font-size:12pt\">Lab results</caption>\n" \
			"<thead>\n" \
				"<tr>\n" \
                                        "<th>Del No</th>\n" \
        	                        "<th>Load No</th>\n" \
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

		for (y in b)
			print "<tr><td>"++del"</td>"b[y]"</tr>";

		print "\t\t</tbody></table>\n";

	}' tanker_log.txt load_log.txt lab_log.txt
