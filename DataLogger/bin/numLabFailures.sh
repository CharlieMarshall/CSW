#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# numLabFailures.sh — Outputs an HTML pre tag displaying lab failure rates for the calendar year
# Usage: numLabFailures.sh
# Author: Charlie Marshall
# License: MIT

#YEAR=$(date +%Y)
YEAR=2019

awk -F"\t" -v year="$YEAR" '
	BEGIN{ print "<pre>"; split("Coliforms|Ecoli|Entercocci|Pseudo|TVC 1 day 37|TVC 3 day 22|Pres Colifrom|Pres Ecoli|Pres Entercocci|Pres Pseudo",a,"|") }
	$3 !~ year	{ next } # skip previous years, we are only reporting this year
	$3  ~ year	{ numTests++ }
	$5 > 0		{ num[1]++ }
	$6 > 0		{ num[2]++ }
	$7 > 0		{ num[3]++ }
	$8 > 0		{ num[4]++ }
	$9 > 20		{ num[5]++ }
	$10 > 100	{ num[6]++ }
	$11 > 0		{ num[7]++ }
	$12 > 0		{ num[8]++ }
	$13 >= 0	{ num[9]++ }
	$14 >= 0	{ num[10]++ }
	END{
		if(numTests>0){
 		  printf "No. of tests " year ":\t%d\n\nTest\tNo. Failures\tPercentage\n", numTests;
 		  for(i=1; i<11; i++)
		    printf "%s:\t%d\t%.2f%\n", a[i], num[i], num[i]*(100/numTests);
                }
	printf "</pre>";
	} ' "${LOGS_DIR}/lab_log.txt" | column -L -t -s $'\t'
