#!/bin/bash
echo "Stopping mgetty service..."
sudo service mgetty stop
sleep 1
resetGSM.py
sleep 5
echo "Starting mgetty service..."
sudo service mgetty start

#curl -s \
#          --form-string "token=token" \
#          --form-string "user=user" \
#          --form-string "title=Gate Reset" \
#          --form-string "message=Gate Reset" \
#          --form-string "sound=magic" \
#          https://api.pushover.net/1/messages.json > /dev/null 2>&1 &
