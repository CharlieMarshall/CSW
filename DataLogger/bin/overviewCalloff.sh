#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# overviewCalloff.sh — Output our orders showing how many hours we are ahead or behind the forecast and how many loads are outstanding
# Usage: overviewCalloff.sh
# Author: Charlie Marshall
# License: MIT

cd "${LOGS_DIR}" || exit
# use tac to read the file in reverse to save time
# $1 is the last delivered load and we add 1 to get the next load number
#
#
# Original code below:
####################
#awk '	FNR==NR && $8=="UNRELEASED"     { loaded++; next }
#	FNR==NR && $8!="UNRELEASED"	{ nextload=$1+1; nextfile }
#	FNR!=NR && $3>=nextload		{ print; ++count; }
#	END				{ printf "\nOutstanding Deliveries:\t%d\n", count; count-=loaded;
#					  printf "Outstanding Loads:\t%d\t%\047d litres", count, count*29500;
####################
#
# Amended to show time we are ahead / behind plan:
# note we now use tabs so the $x numbers have changed.
####################

cat calloffdate.txt

awk -F'\t' ' BEGIN{msg="late"}
	FNR==NR && $7=="UNRELEASED"     { loaded++; next }
	FNR==NR && $7!="UNRELEASED"	{ nextload=$1+1; nextfile; }
	FNR!=NR && $2==nextload		{ split($1,s,"[/ :]");
					  delay = (systime() - mktime(s[4]" "s[3]" "s[2]" "s[5]" 00 00") ) / 3600;
					  if(delay<0) msg="until due";
					  printf "%s\t%d hour(s) %s\n", $0, delay, msg;
					  ++count; }
	FNR!=NR && $2>nextload		{ print; ++count; }
	END				{ printf "\nOutstanding Deliveries:\t%d\n", count;	# count-=loaded; now on line below
					  printf "Outstanding Loads:\t%d\t%\047d litres", count-=loaded, count*29500;
	} ' <(tac load_log.txt) orders.txt

#	END				{ print "\nOutstanding Loads:\t" count } ' <(tac load_log.txt) orders.txt
#	FNR!=NR && $3>=nextload		{ print; if(++count>14)exit } ' <(tac load_log.txt) orders.txt

#nextLoad=$( tac load_log.txt | awk ' $8!="UNRELEASED" { print $1+1; exit } ' )
#awk -v nextload=$nextLoad ' $3 >= nextload { count++; print; if(count>14)exit; } ' orders.txt
