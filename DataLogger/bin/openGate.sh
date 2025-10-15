#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# openGate.sh — A script to open our electric gate via an HTTP POST
# Usage: openGate.sh
# Author: Charlie Marshall
# License: MIT

curl -X POST -F "open=open" http://gate.localdomain
