#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# updateTanker.sh — A script to add or amend to the tanker_log.txt file
# Usage: updateTanker.sh certNo tankerID CIPdate(DD/mm/YYYY HH:MM)
# Author: Charlie Marshall
# License: MIT

certNo="$1"
tankerID="$2"
CIPdate="$3"

cd "${LOGS_DIR}"/ || exit

if [[ -n "$certNo" ]]; then
	awk -v certno="$certNo" -v id="$tankerID" -v cipdate="$CIPdate" '
		BEGIN{ FS=OFS="\t"; expires="";
			if(cipdate!=""){
				split(cipdate,a,"/| |:");
				cipcalcdate=mktime(a[3]" "a[2]" "a[1]" "a[4]" "a[5]" 00");
				expires=strftime("%d/%m/%Y %R", cipcalcdate+86400*14)
			}
		}
		# if cert exists update the fields with new data
		$1==certno { certExists=1; $2=id; $3=cipdate; $4=expires }
		# print all lines, including the amended one
		{ print }
		# if cert did not exist, it is a new cert, print it at the end of the file
		END { if(certExists!=1){ print certno, id, cipdate, expires }
	} ' tanker_log.txt | sort -r > tanker_log.tmp

	cp tanker_log.tmp tanker_log.txt
	rm tanker_log.tmp
fi
