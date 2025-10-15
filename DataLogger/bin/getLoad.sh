#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# getLoad.sh — Display in JSON load details
# Usage: getLoad.sh loadno eg getLoad.sh 4444
# Author: Charlie Marshall
# License: MIT

awk -F'\t' -v loadno="$1" -v matches=0 '
	$1==loadno	{ printf "{\"tanker\":\"%s\",\"cert\":\"%s\",\"loader\":\"%s\",\"sampler\":\"%s\",\"driver\":\"%s\",\"delDate\":\"%s\"}\n", $8, $9, toupper($10), toupper($11), $12, $7; matches++; exit }
	END		{ if(matches==0) printf "{\"tanker\":\"\",\"cert\":\"\",\"loader\":\"\",\"sampler\":\"\",\"driver\":\"\",\"delDate\":\"\"}\n"; }
' "${LOGS_DIR}"/load_log.txt
