#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# flowComp.sh — A script to check whether we need to be flow compensating and sets the tank level appropriately on the specfied storage tank, location H26, on the PLC
# Usage: flowComp.sh
# Author: Charlie Marshall
# License: MIT

# CURL POST and fetch the cookie
curl -s -c timeViewCookie -d 'method=POST&data%5BUser%5D%5Busername%5D=username&data%5BUser%5D%5Bpassword%5D=password' -X POST http://www.timeview2.net/
#
latestAlarm=$(curl -sb timeViewCookie -L http://www.timeview2.net/ | sed -n '/<th class=\"actions\">Actions<\/th><\/tr>/{n;n;n;n;n;p}') # print the 5th line after our match
#latestAlarm=$(curl -sb timeViewCookie -L http://www.timeview2.net/ | sed -n '/<th class=\"actions\">Actions<\/th><\/tr>/{n;n;n;n;n;n;n;n;n;n;n;n;n;n;n;p}') # fetches the second alarm 10th line after match
echo "$latestAlarm" | xargs # xargs removes the leading spaces
#
#
runscript="${HOME}/node_modules/omron-fins/examples/setTankLevel.js"
#
# grep -q (Quiet); do not write anything to standard output.  Exit immediately with zero status if any match is found, even if an error was detected
if   echo "$latestAlarm" | grep -q "Return to Normal";	then echo "Reducing Compensation: Setting Tank level to 0";	node "$runscript" 0;
elif echo "$latestAlarm" | grep -q "Flows are below";	then echo "Increasing Compensation: Setting Tank level to 110";	node "$runscript" 110;
else echo "An error occured"; exit 1; fi
#
# Alternative one liner but no failsafe eg does not handle fetching an incorrect line
#if curl -s -b mycookies -L http://www.timeview2.net/ | sed -n '/<th class=\"actions\">Actions<\/th><\/tr>/{n;n;n;n;n;p}' | grep -q "Return to Normal"; then echo "Turn TANK OFF"; else echo "Turn TANK ON"; fi
