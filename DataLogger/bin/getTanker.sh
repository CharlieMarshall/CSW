#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# getTanker.sh — Find and return JSON tanker certificate details
# Usage: getTanker.sh certno eg getTanker.sh 207844
# Author: Charlie Marshall
# License: MIT

awk -F"\t" -v certno="$1" ' certno==$1 { printf "{\"tanker\":\"%s\",\"cipdate\":\"%s\"}\n", $2, $3 } ' "${LOGS_DIR}"/tanker_log.txt
