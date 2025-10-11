#!/bin/bash

function notify {
	curl -s \
	  --form-string "token=token" \
	  --form-string "user=user" \
	  --form-string "title=Gate opened" \
	  --form-string "message=$1" \
	  --form-string "sound=classical" \
	  https://api.pushover.net/1/messages.json > /dev/null 2>&1 &
}

# open the gate
# open_gate.py > /dev/null 2>&1 &

number=07111111111			# $1 is: ttyAMA0
DATE="$(date +"%d/%m/%Y %H:%M")"
LOG="/var/www/html/gate_calls.json"
id="$(awk -v number=$number -F' # ' ' \
		number ~ $1 { print $2; exit } \
		number=="INTERNAL" { print "NETWORK"; exit } \
	' /etc/mgetty/dialin.config)"

#echo -e "${DATE}\t${number}\t$id" >> ${LOG}

#sudo printf '{"time":"%s","name":"%s","number":"%s"}\n' "${DATE}" "$id" "$number" >> ${LOG}
jq --arg time "${DATE}" --arg number "$number" --arg id "$id" \
	'.gsm += [{"time":$time,"name":$id,"number":$number}]' /var/www/html/call_list.json > tmp.json && mv tmp.json /var/www/html/call_list.json

#notify "$id | $number"
# to change logging set debug to 4-9 in the config file /etc/mgetty/mgetty.config
# logging is also disabled in '/lib/systemd/system/mgetty.service' stop service add logging and restart
# replace with exit 1 if you want mgetty not to answer the call - it just keeps ringing
exit 0
