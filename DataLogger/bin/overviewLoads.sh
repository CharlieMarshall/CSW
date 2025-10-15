#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# overviewLoads.sh — Display details of the last 15 loads with an HTML link for the load number
# Usage: overviewLoads.sh
# Author: Charlie Marshall
# License: MIT

# We need to pad out the 'Load' heading as $1 has a lot of text and it will not align properly
tail -n 15 "${LOGS_DIR}"/load_log.txt | tac | awk ' BEGIN { FS=OFS="\t"; print "Load<span class=\"eeeeeeeeeempty\"></span>","Date & Time","Point","Tank","PH","Cond","Del Date","Tanker ID","Cert No","Loader","Sampler","Driver" }
	1 { $1="<a href=\"loads.php?loadNo="$1"\">"$1"</a>"; print $0 } ' | column -L -t -s $'\t'
