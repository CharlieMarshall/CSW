#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# checkForNewLoad.sh — Adds a new load to the load_log.txt and sends a push notification to alert us when we detect a new load
# Usage: checkForNewLoad.sh
# Author: Charlie Marshall
# License: MIT

# 'load_log.txt'  contains a single line per load including delivery date
# Push notifications are sent every time a new connection / load is deteced
# Push Alarms are sent when the temperature, ph or conductivity is out of spec or the tank levels are low

cd "${LOGS_DIR}" || exit

#### We could change the input file to <(sort -u -k1,1 panel_log.txt) which may result in speed increase as it would be only unique loads
awk 'BEGIN { FS=OFS="\t"; numNewLoads=numMatchedLoads=0 }
	FILENAME==ARGV[1]				{ seen[$1]++; next }
	FILENAME==ARGV[2] && !seen[$1]++		{ numNewLoads++;
							  load[$2$3] = $3 " | " $10 " lts | " $11 " lt/m | " $12 " mins\n";
							  title[$2$3] = $1 " | " $8;
							  print $1,$2,$3,$4,$5,$6,"UNRELEASED","-","-","-","-","-";
							  # If flow rate is less than 100 lt/m send separate alarm without tank data, we sleep 5 so we can hear the alarm sound
							  if($11<100)
								system(" pushAlarm.sh \"" $1 " | checkForNewLoad.sh (redundant?) FLOW RATE ERROR\" \"" load[$2$3] "\" && sleep 5 ")
							}
	FILENAME==ARGV[4] && numMatchedLoads>=numNewLoads { exit }
	FILENAME==ARGV[4] && $2$3 in load { numMatchedLoads++; system("push.sh \"" title[$2$3] "\" \"" load[$2$3] $1 OFS $4 " m3" OFS $5 OFS $6 " m3" OFS $7 OFS $8 " \"")}
' load_log.txt panel_log.txt OFS=" | " <(tac tank_log.txt) | sort -n >> load_log.txt
##### End of second awk script

# while there are more then two unreleased loads mark the FIRST MATCHED 'UNRELEASED' load as released
while [ "$( grep -c 'UNRELEASED' load_log.txt )" -gt 2 ] ; do
	# Note the following line only works after adding our user to the www-data group &
	# setting the setgid bit of the parent folder chmod g+s parent_folder, parent folder must be owned by group www-data
	# Alternatively use (cant remember if mv or cp) : sed '0,/UNRELEASED/s/UNRELEASED/'"$(date +"%d-%m-%Y")"'/' load_log.txt > load_log.tmp && mv load_log.tmp load_log.txt
	sed -i '0,/UNRELEASED/s/UNRELEASED/'"$(date +"%d-%m-%Y")"'/' load_log.txt
done
