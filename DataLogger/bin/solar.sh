#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# solar.sh — Display HTML data (Power, Daily Yield and Total Yield) from our solar (PV) webserver
# Usage: solar.sh
# Author: Charlie Marshall
# License: MIT

curl -s http://$ip/home.ajax | jq -c '.[][]' \
  | awk -F "\"" ' BEGIN { print "<h5>Solar Panels</h5><table class=\"table table-condensed table-bordered table-hover table-striped\">" } \
{ print "<tr><td>"$2"</td><td>"$4"</td></tr>" } END { print "</table>" } '
