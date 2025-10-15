#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# overviewCIP.sh — Description
# Usage: overviewCIP.sh
# Author: Charlie Marshall
# License: MIT

date=$(date +%Y-%m-%d-%H-%M)
awk -v date=$date ' BEGIN{ FS=OFS="\t"; print "Tanker ID", "Cert No", "CIP Date & Time", "CIP Expires", "Days Since CIP"}
	$2 ~ /GEZ0001S/	&& a==0 { a++; tanker[1]=$0; next }
	$2 ~ /GEZ0002S/	&& b==0 { b++; tanker[2]=$0; next }
	$2 ~ /GEZ0003S/	&& c==0 { c++; tanker[3]=$0; next }
	$2 ~ /GEZ0004S/	&& d==0 { d++; tanker[4]=$0; next }
	$2 ~ /GEZ0005S/	&& e==0 { e++; tanker[5]=$0; next }
	a && b && c && d && e !=0 { exit } 	# When we have found a certificate for all five tankers exit the body
	END{
		split(date,x,"-"); now=mktime(x[1]" "x[2]" "x[3]" "x[4]" "x[5]" 00");
		for(i=1;i<=5;i++) {
			split(tanker[i],fields,"\t");
			cipdate=fields[3];
			split(cipdate,y,"/| |:");
			cipcalcdate=mktime(y[3]" "y[2]" "y[1]" "y[4]" "y[5]" 00");
	                printf( "%s\t%d\t%s\t%s\t%d\n", fields[2], fields[1], fields[3], fields[4], (((now-cipcalcdate)/60)/60)/24 );
		}
	} ' "${LOGS_DIR}"/tanker_log.txt | column -L -t -s $'\t'

tac "${LOGS_DIR}"/panel_log.txt | awk ' BEGIN { FS=OFS="\t"; print "\nLast Load","Date & Time","Point","Tank","PH","Cond","Temp" }
	NR>2 && ($5<7 || $5>8.5) { cip[$3]=cip[$3] $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$7"\n"; queue[NR+2]; next }
	NR in queue { print postcip[$3] cip[$3] $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$7; cip[$3]=""; if(++count==1) {print ""; next} exit }
	{ postcip[$3]=$1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$7"\n" } ' | column -L -t -s $'\t'
