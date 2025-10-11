#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# missingLab.sh — Outputs which loads do not have a corresponding lab certificate
# Usage: missingLab.sh
# Author: Charlie Marshall
# License: MIT

# For each lab result where the sample description begins with a number, store in array 'a'
# Print any load numbers from 'loads_log.txt' which are not found in array 'a'

# start from 2784 as we have some missing
awk -F"\t" -v fromLoad=3252 'FNR==NR && $2 ~ /^[0-9]/ && $2>fromLoad { a[$2]++ } FNR!=NR && $1>fromLoad && !a[$1] { print "<a target=\"_blank\" href=\"loads.php?loadNo="$1"\">"$1"</a><br>" }' "${LOGS_DIR}"/lab_log.txt "${LOGS_DIR}"/load_log.txt

# if we don't need to start from a load number we could use this
# awk 'FNR==NR && $2 ~ /^[0-9]/ { a[$2]++ } FNR!=NR && !a[$1] { print "<a target=\"_blank\" href=\"loads.php?loadNo="$1"\">"$1"</a><br>" }' "${LOGS_DIR}"/lab_log.txt "${LOGS_DIR}"/load_log.txt
