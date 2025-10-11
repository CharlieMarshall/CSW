#!/bin/bash
echo "Stopping mgetty service..."
sudo service mgetty stop
sleep 1
#python3 ../IteadSIM800/send_keep_alive_txt.py || pushAlarm.sh

BALANCE="$(python3 "${HOME}"/IteadSIM800/voda.py | tail -n 1 2>&1)"

curl -s \
  --form-string "token=token" \
  --form-string "user=user" \
  --form-string "message=$BALANCE" \
  --form-string "sound=tugboat" \
  --form-string "title=Gate Pi Vodafone PAYG Balance" \
  https://api.pushover.net/1/messages.json > /dev/null

echo "Starting mgetty service..."
sudo service mgetty start
