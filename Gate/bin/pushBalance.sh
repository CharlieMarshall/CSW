#!/bin/bash
# usage ./pushBalance.sh "message"

curl -s \
  --form-string "token=token" \
  --form-string "user=user" \
  --form-string "message=$1" \
  --form-string "sound=tugboat" \
  --form-string "title=PAYG Balance" \
  https://api.pushover.net/1/messages.json > /dev/null
