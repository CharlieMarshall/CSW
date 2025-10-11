#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# overviewPanel.sh — Display the most recent data of our panel for A and B lines
# Usage: overviewPanel.sh
# Author: Charlie Marshall
# License: MIT

tail -n 2 "${LOGS_DIR}"/panel_log.txt | awk ' BEGIN{ FS=OFS="\t"; print "Load","Date & Time","Point","Tank","PH","Cond","Temp","Status","Set Level (lt)","Pumped (lt)","Flow Rate","Mins Remain" } $0 ' | column -L -t -s $'\t'
