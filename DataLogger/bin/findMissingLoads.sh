#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# findMissingLoads.sh — Find and display any missing load numbers from the load_log.txt
# Usage: findMissingLoads.sh
# Author: Charlie Marshall
# License: MIT

echo -e "Note 2609 was skipped by customer\n"
awk ' NR==1 {first=$1}; {a[$1]=$1} END { for(i=first;i<=$1;i++) if(!a[i]) print i } ' "${LOGS_DIR}"/load_log.txt
