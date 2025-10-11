#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# updateLoad.sh — A script to update a loads details
# Usage: updateLoad.sh loadNo tankerID tankerCert loader sampler driver deldate(DD-MM-YYYY)
# Author: Charlie Marshall
# License: MIT

cd "${LOGS_DIR}" || exit

loadNo="$1"
tankerID="$2"
tankerCert="$3"
loader="$4"
sampler="$5"
driver="$6"
deldate="$7"

if [[ -n "$loadNo" ]]; then
	#sed "/^$loadNo/ s/$/\t$tankerID\t$tankerCert\t$loader\t$sampler\t$driver/" "${LOGS_DIR}"/load_log.txt > test.txt
	awk -v loadno="$loadNo" -v id="$tankerID" -v cert="$tankerCert" -v loader="$loader" -v sampler="$sampler" -v driver="$driver" -v deldate="$deldate" \
		' BEGIN{ FS=OFS="\t"; IGNORECASE=1 }
		$1==loadno { $8=id; $9=cert; $10=toupper(loader); $11=toupper(sampler); $12=driver; $7=deldate }
		{ print }
		' load_log.txt > load_log.tmp
	cp load_log.tmp load_log.txt # cp preserves files ownership
	rm load_log.tmp
fi
