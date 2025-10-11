#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# invoiceDetails.sh — A script to display an invoice which can be copy / pasted into out accounting software
# Usage: invoiceDetails.sh or invoiceDetails.sh date eg invoiceDetails.sh 22-02-2022
# Author: Charlie Marshall
# License: MIT

invoiceDate=$1
# Note price is hardcoded to the current price
loadPrice=100

if [ $# -eq 0 ] || [ -z "$1" ] || [ "$1" = $(date +%d-%m-%Y) ] ; then
	invoiceDate=$(date +%d-%m-%Y) # no arguments supplied default to today
#	echo -e "<b>Displaying today's invoice, note this does not include unreleased loads</b>\n"
fi

echo -e "Date:\t$invoiceDate\nA/C:\tREF\nPO:\tLeave blank (PO is hard coded into the Sage report)\nCode:\tWater\n\nComment lines (copy and paste):"

awk -v iDate=$invoiceDate -v price=$loadPrice ' BEGIN{ORS=","} $0 ~ iDate { if(++loads==11){ print "\n" $1} else{ print $1} } \
	END{net=loads*price; vat=net*0.2; total=net+vat; 	printf "\n\nLoads:\t" loads "\n\nNet:\t" net "\nVAT:\t" vat "\nTotal:\t" total "\n" }
' "${LOGS_DIR}/load_log.txt"

echo -e "\n\n<b>Accounting shortcut keys</b>\nF3 = Edit Item Line\nAlt+S = Save Invoice"
