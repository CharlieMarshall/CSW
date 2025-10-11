#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# tableLoads.sh — Output an HTML table of load details
# Usage: tableLoads.sh searchTerm
# searchTerm ($1) is an optional search string. It is not an exact match ~ so we could type 'DRIVER' and get all 'DRIVER' loads
# Author: Charlie Marshall
# License: MIT

tac "${LOGS_DIR}/load_log.txt" | awk -v filter="$1" '
	BEGIN { FS="\t"; OFS="</td><td>"; IGNORECASE=1;
		print "\n<table  id=\"myTable\" class=\"table table-condensed table-bordered table-hover tablesorter\">\n \
		<thead>\n \
			<tr>\n \
				<th>Load No</th>\n \
				<th>Loading Date & Time</th>\n \
				<th>Point</th>\n \
				<th>Tank</th>\n \
				<th>PH</th>\n \
				<th>Cond</th>\n \
				<th>Delivery Date</th>\n \
				<th>Tanker ID</th>\n \
				<th>Tanker Cert</th>\n \
				<th>Loader</th>\n \
				<th>Sampler</th>\n \
				<th>Driver</th>\n \
			</tr>\n \
		</thead>\n \
		<tbody>";
	}
	$0 ~ filter { print "<tr><td><a href=\"#\" data-type=\"loadno\" data-value=\""$1"\">"$1"</a>" OFS $2 OFS $3 OFS $4 OFS $5 OFS $6 OFS $7 OFS $8 OFS \
		"<a href=\"#\" data-type=\"tankerCert\" data-value=\""$9"\">"$9"</a>" OFS $10 OFS $11 OFS $12 "</td></tr>" }
	END { print "\t\t</tbody>\n\t</table>" } '
