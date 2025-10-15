#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# overviewGate.sh — Display the last 15 callers to open the gate
# Usage: overviewGate.sh
# Author: Charlie Marshall
# License: MIT

curl -m 5 -s "http://gate/call_list.txt" | tail -n 15 | tac
