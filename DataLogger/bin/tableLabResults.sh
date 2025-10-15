#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# tableLabResults.sh — A script to print an HTML table of our lab results. Can also be used to search via the $1 parameter
# $1 is the optional search string. It is not an exact match ~ so you could type a certificate no and just view that certificate
# Usage: tableLabResults.sh searchTerm(optional)
# Author: Charlie Marshall
# License: MIT

# OFS2 is used to add a critical class to the HTML. We then use JS / jquery in the webGUI to highlight any failures
tac "${LOGS_DIR}/lab_log.txt" | awk -v filter="$1" -v lines="$2" '
	BEGIN { FS="\t"; OFS="</td><td>"; OFS2="</td><td class=\"critical\">"; IGNORECASE=1; print "<table  id=\"myTable\" class=\"table table-condensed table-bordered table-hover tablesorter\" style=\"padding: 10px;\">\n \
                <thead>\n \
                        <tr>\n \
                                <th>Cert No</th>\n \
                                <th>Reference</th>\n \
                                <th>Sample</th>\n \
                                <th>Sample Date</th>\n \
                                <th>Lab Received</th>\n \
                                <th>Coliform</th>\n \
                                <th>E. coli</th>\n \
                                <th>Enterococci</th>\n \
                                <th>Pseudo</th>\n \
                                <th>TVC 37</th>\n \
                                <th>TVC 22</th>\n \
                                <th>Pres Coliform</th>\n \
                                <th>Pres E. coli</th>\n \
                                <th>Pres Enterococci</th>\n \
                                <th>Pres Pseudo</th>\n \
                                <th>Cost</th>\n \
                        </tr>\n \
                </thead>\n \
		<tbody>\n";
	}
	$0 ~ filter {
		count++;	# this is used to save manually making changes on a new year as the tablesorter will not work with an empty table
		#if($1<119991) { exit } # TEMP to hide certs

		# $2 contains the sample description, if it begins with a number it will be a load number so we add a HTML link
		if($2 ~ /^[0-9]/)
			$2 = "<a href=\"loads.php?loadNo="$2"\">"$2"</a>";
		print "<tr><td>";
		split($3, sampleDate,"[/ :]"); # note sampleDate[3] is the sampled year
		print "<a href=\"file:///E:/Dropbox/Certification/Testing/" sampleDate[3] "/" sprintf("%08d",$1) ".pdf\">"$1"</a>" OFS $16 OFS $2 OFS $3 OFS $4 OFS2 $5 OFS2 $6 OFS2 $7 OFS2 $8 OFS $9 OFS $10 OFS $11 OFS $12 OFS $13 OFS $14 OFS "&pound;" $15;
		print "</td></tr>";
		if(NR==lines) { exit }
	}
#	lines==1 && NR>75	{ exit }
	END { if(count==0) print "<tr><td></td></tr>"; print "\t\t</tbody></table>" } '
