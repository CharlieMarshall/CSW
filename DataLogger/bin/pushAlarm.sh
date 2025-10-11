#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# pushAlarm.sh — Send a push alarm notification
# Usage: pushAlarm.sh title message
# Author: Charlie Marshall
# License: MIT

# usage ./push.sh "title" "message"

curl -s \
  --form-string "token=token" \
  --form-string "user=user" \
  --form-string "message=$2" \
  --form-string "sound=echo" \
  --form-string "title=$1" \
  --form-string "priority=1" \
  https://api.pushover.net/1/messages.json >/dev/null
