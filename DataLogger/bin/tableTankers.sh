#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# tableTankers.sh — Output an HTML table of tank information
# Usage: tableTankers.sh or tableTankers.sh searchTerm eg tableTankers.sh 5S
# Author: Charlie Marshall
# License: MIT

# $1 is the optional search string. By using '~' it is not an exact match
awk -v filter="$1" ' BEGIN { FS="\t"; OFS="</td><td>"; IGNORECASE=1;
	print "<table  id=\"tankerTable\" class=\"table table-condensed table-bordered table-hover tablesorter\" style=\"padding: 10px;\"> \
                <thead> \
                        <tr> \
                                <th>Cert No</th> \
                                <th>Tanker ID</th> \
                                <th>CIP Date & Time</th> \
                                <th>CIP Expires</th> \
                        </tr> \
                </thead> \
                <tbody> "
}
$0 ~ filter { print "<tr><td><a href=\"loads.php?tankerCert="$1"\">"$1"</a>" OFS $2 OFS $3 OFS $4 "</td></tr>" }

END { print "</tbody></table>" } ' "${LOGS_DIR}/tanker_log.txt"
