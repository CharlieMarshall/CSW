#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# findDuplicateTankers.sh — Find Duplicate tankers in the tanker_log.txt file
# Usage: findDuplicateTankers.sh
# Author: Charlie Marshall
# License: MIT

awk 'x[$1]++ >0  { print "cert number " $1 " is duplicated"}' "$LOGS_DIR"/tanker_log.txt
