#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# push.sh — Send a push notification
# Usage: push.sh title message
# Author: Charlie Marshall
# License: MIT

# usage ./push.sh "message"

curl -s \
  --form-string "token=token" \
  --form-string "user=user" \
  --form-string "title=$1" \
  --form-string "message=$2" \
  https://api.pushover.net/1/messages.json >/dev/null
