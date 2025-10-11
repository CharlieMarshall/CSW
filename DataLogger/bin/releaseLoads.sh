#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# releaseLoads.sh — Manually change a loads status from UNRELEASED to RELEASED
# Usage: releaseLoads.sh
# Author: Charlie Marshall
# License: MIT

if [ "$1" = "one" ]; then
  awk ' BEGIN { print "The following loads have been marked as released:\n" } $0 ~ /UNRELEASED/ { print $1; exit }' "${LOGS_DIR}"/load_log.txt
  sed -i '0,/UNRELEASED/{s/UNRELEASED/'"$(date +"%d-%m-%Y")"'/}' "${LOGS_DIR}"/load_log.txt
else
  awk ' BEGIN { print "The following loads have been marked as released:\n" } $0 ~ /UNRELEASED/ { print $1 } ' "${LOGS_DIR}"/load_log.txt
  sed -i 's/UNRELEASED/'"$(date +"%d-%m-%Y")"'/g' "${LOGS_DIR}"/load_log.txt
fi
