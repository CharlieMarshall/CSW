#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# monthlyLabReport.sh — A script to email the monthly Lab results
# Usage: monthlyLabReport.sh
# Author: Charlie Marshall
# License: MIT

#cd ${HOME}/bin
# regexDate  %m prints numeric month eg January = '01'
# reportDate %B prints full month name eg 'January'
read -r regexDate reportDate < <(date +"%m/%Y %B-%Y" --d "-1 month")

# sorted by load number, print only results whose descriptions start with a number. Add PO to load number,
sort -k 2 "${LOGS_DIR}/lab_log.txt" | awk -v regex="$regexDate" ' BEGIN { FS=OFS="\t"; IGNORECASE=1; print "Cert No.","Sample", "Sample Date & Time","Coliform","E. coli","Enterococci","Pseudo","TVC 37","TVC 22" }
        $2 ~ /^[0-9]/ && $3 ~ regex  { print $1, "380504-"$2, $3, $5, $6, $7, $8, $9, $10 }' > "CSW_monthly_lab_results_${reportDate}.xls"

# commented out for uploading
# dropbox_uploader.sh -q upload "CSW_monthly_lab_results_${reportDate}.xls" folder

echo -e "Hello,\n\nPlease find lab results for $reportDate attached.\n\nKind regards\n\nCSW" | \
	mail -A "CSW_monthly_lab_results_${reportDate}.xls" -s "Monthly lab results from CSW" "user@domain"

rm "CSW_monthly_lab_results_${reportDate}.xls"
