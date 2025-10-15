#!/bin/bash
# usage ./push.sh "title" "message"
curl -s \
  --form-string "token=token" \
  --form-string "user=user" \
  --form-string "message=Could not communicate with GSM board" \
  --form-string "sound=echo" \
  --form-string "title=GSM error" \
  --form-string "priority=1" \
  https://api.pushover.net/1/messages.json > /dev/null
