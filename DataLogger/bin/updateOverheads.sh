#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# updateOverheads.sh — Updates a value in the overheads file
# Usage: updateOverheads.sh year month value eg updateOverheads.sh 2022 11 100
# Author: Charlie Marshall
# License: MIT

# month=$(echo $1 | sed 's/^0*//')	# to remove leading zeros from the month
# month=$(printf "%02d" $1)		# to add leading zero to the month

month=$1
year=$2
value=$3

sed -i "s/$year\t$month\t.*/$year\t$month\t$value/" "${LOGS_DIR}/overheads_log.txt"
############ script to add new years to overheads file:
# for yr in {2030..2040}; do for i in {1..12}; do echo -e "$yr\t$i\t" >> "${LOGS_DIR}/overheads_log.txt"; done; done;
