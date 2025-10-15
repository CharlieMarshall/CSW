#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# emailSnapshot.sh — # Script which sends an email showing a snapshot of our storage tanks levels and a list of the loads 30 loads delivered
# Usage: emailSnapshot.sh noLoads(optional) eg emailSnapshot.sh 10 # for 10 loads
# Author: Charlie Marshall
# License: MIT

if [ $# -eq 0 ]; then
	noLoads=30
else
        noLoads=$1
fi

cd "${LOGS_DIR}" || exit

emailTo="user@domain"

total=$(tail -n 3 "${LOGS_DIR}/tank_log.txt" | awk -F"\t" ' { total+=$4 } END {print total}')	# accumulator of our 3 storage tanks
#unreleased=$(tail -2 "${LOGS_DIR}/load_log.txt" | awk -F"\t" ' BEGIN {printf "( "} $7=="UNRELEASED" { printf $1 " " } END { printf ")"} ')

message="Snapshot of CSW at $(date '+%d/%m/%Y %H:%M') \
	\n\nVolume of water in our storage tanks: $total m3 \
	\n\nList of the last $noLoads collected loads:\n\n"


# Generate a table of the last X delivered loads and 2 unreleased loads
message+=$(tail -$(($noLoads + 2)) load_log.txt | awk ' \
	BEGIN	{ FS=OFS="\t"; print "Load No", "Collection Time", "Tanker", "Driver" }
		{ load[++y]=$1; loadTime[y]=$2; delDate[y]=$7; driver[y]=$12;  sub(/GEZ000/, "", $8); tanker[y]=$8 }
	END	{ for (i=length(load); i>=1; i--) {
			if(delDate[i]=="UNRELEASED")
				print load[i], "LOADED";
			else {
				if(loadTime[i+2]=="")
					print load[i], "DELIVERED", tanker[i], driver[i];
				else
					print load[i], loadTime[i+2], tanker[i], driver[i];
			}
		}
	}' | column -t -s $'\t' | pr -t -o 5)

message+="\n\nNOTE: Collection times are actually the connection time of 2 subsequent loads. It is assumed that there are two tankers in our yard and these are both loaded.\n"

# send email without attachment
printf "$message" | mail -a "From: user@domain" -s "Last $noLoads loads collected from CSW" "$emailTo"


# Uncomment for debugging
#printf "$message" | mail -a "From: user@domain" -s "Last $noLoads loads collected from CSW" "user@domain"
#printf "$message"

# send email with attachment
#
# get cctv screenshot
# avconv -loglevel fatal -rtsp_transport tcp -i "rtsp://admin:password@ip:554/Streaming/Channels/601" -frames 1 -y cctv.jpeg
#
#emailCommand="(echo -e \"$message\"; uuencode cctv.jpeg cctv.jpeg ; ) | mail \
#	-a \"From: user@domain\" \
#	-s \"Last 20 loads collected from Cotswold\" \
#	user@domain"
#eval "$emailCommand"
#rm cctv.jpeg
