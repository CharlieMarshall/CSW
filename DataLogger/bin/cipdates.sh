#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# cipdates.sh — Display in blocks, where we have performed a CIP, this is identified by a change in the PH level
# Usage: cipdates.sh
# Author: Charlie Marshall
# License: MIT

# using tac = data is read in reverse ie post cip is read first, then cleaning and finally pre cip data is read last
# for every line which has an Out Of Spec PH level, append it to cip[A|B($3)] and set the following data (NR+2) to be queeued for printing
# if the following NR+2 is recorded during CIP, it is appended to the cip[A|B] and then skipped (next)
# for any NR+2 which is not during CIP ie pre CIP, we print the post CIP data followed by all CIP data and then the pre CIP data and reset cip[]
tac "${LOGS_DIR}"/panel_log.txt | awk ' BEGIN { FS=OFS="\t"; print "Load","Date & Time","Point","Tank","PH","Cond","Temp" }
	NR>2 && ($5<6.5 || $5>8.5) { cip[$3]=cip[$3] $1 FS $2 FS $3 FS $4 FS $5 FS $6 FS $7"\n"; queue[NR+2]; next }
	NR in queue { print postcip[$3] cip[$3] $1 FS $2 FS $3 FS $4 FS $5 FS $6 FS $7"\n"; cip[$3]=""; next }
	{ postcip[$3]=$1 FS $2 FS $3 FS $4 FS $5 FS $6 FS $7 "\n"} ' | column -L -t -s $'\t'
