#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# restartServer.sh — Force restarts the HMIs web server.
# Usage: restartServer.sh
# Author: Charlie Marshall
# License: MIT

count=1;
response=$(curl http://$ip/image.bmp -s -w '%{http_code}' -o screenshot.bmp)

while (( response < 200 || response > 299 )); do
  (( count++ ))
  response=$(curl http://$ip/image.bmp -s -w '%{http_code}' -o screenshot.bmp)
  if [ "$count" -gt 9 ]; then
    echo "Failed to reset the Web Server! Is it offline?"
    exit 1;
  fi
done

echo "Success! After $count attempt(s) the Web Server was reset"
rm screenshot.bmp
exit 0
