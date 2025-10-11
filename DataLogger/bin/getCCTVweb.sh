#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# getCCTVweb.sh — Takes a screenshot of channels 4, 5 & 6 of CSW CCTV and saves them as jpegs. Defaults to stream 2 which is low res
# Usage: getCCTVweb.sh
# Author: Charlie Marshall
# License: MIT

for i in {4..6}; do
  ffmpeg -loglevel fatal -rtsp_transport tcp \
    -i "rtsp://admin:password@ip:554/Streaming/Channels/$i""02" "$WEB_SERVER_DIR/images/cctv/cctv3-$i""02.jpeg" \
    -frames 1 -y "$DIR/cctv/cctv3-$i""02.jpeg"
done
