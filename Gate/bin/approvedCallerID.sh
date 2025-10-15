#!/bin/bash
#
# A script which parses mgetty config to get the caller ID of the person calling the gate.
# Logs that the gate was opened and by who with a timestamp
# Sends a push notification
# Opens the gate
#
# Author: Charlie Marshall

# semd a push notification that the gate has opened
function notify {
	curl -s \
	  --form-string "token=token" \
	  --form-string "user=user" \
	  --form-string "title=Gate opened" \
	  --form-string "message=$1" \
	  --form-string "sound=classical" \
	  https://api.pushover.net/1/messages.json > /dev/null 2>&1 &
}

# send a wol packe to my desktop if it is a weekday between 7am and 10am
# requires etherwake (apt-get install)
function wol {
	read -r day hour < <(date +"%u %-H") # populate variables with numerical day of week and non padded hour
	if [[ day -lt 6 && hour -lt 12 && hour -gt 06 ]]; then
		wakeonlan -i 192.168.100.254 aa:aa:aa:aa:aa:aa
		# notify "$id | Sent magic packet"
	fi
}

# Caller ID has already been approved by mgetty so we can open the gate via the python script
open_gate.py > /dev/null 2>&1 &

# save the number, caller ID and timestamp for logging
number=$2 # $1 is: ttyAMA0
DATE=$(date +"%d/%m/%Y %H:%M")
id="$(awk -v number="$number" -F' # ' ' BEGIN { if(number=="INTERNAL") { print "NETWORK"; exit } } $1 ~ number { print $2; exit } ' /etc/mgetty/dialin.config)"

# if Charlie Marshall opens, no need to log. call the wol function
if [[ "$id" = "Charlie Marshall" ]]; then
	wol
else
	# Add to log file and send push notification
	echo -e "${DATE}\t${number}\t$id" >> /var/www/html/call_list.txt
	notify "$id | $number"
fi

exit 0

# to change logging set debug to 4-9 in the config file /etc/mgetty/mgetty.config
# logging is also disabled in '/lib/systemd/system/mgetty.service' stop service add logging and restart
# replace with exit 1 if you want mgetty not to answer the call - it just keeps ringing


##### OLD UNUSED JSON command #####
#jq --arg time "${DATE}" --arg number "$number" --arg id "$id" \
#       '.gsm += [{"time":$time,"name":$id,"number":$number}]' /var/www/html/call_list.json > tmp.json && mv tmp.json /var/www/html/call_list.json
##### END #####
