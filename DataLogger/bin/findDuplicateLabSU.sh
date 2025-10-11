#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# findDuplicateLabSU.sh — Display any duplicate Lab results, searching via their unique SU number
# Usage: findDuplicateLabSU.sh
# Author: Charlie Marshall
# License: MIT

# SU number is in field 16, so we use NF > 15 to only check the lines which have a recorded SU value, SINCE THE PO CHANGE THIS CAN BE REMOVED
awk -F"\t" ' 	NF>15	{ sub(/SU-/,"",$16 ); su[$16+0]++; sam[$16+0]=$2; }
		END	{ print "<pre>";
			for(i in su) { if( su[i]>1 ) print "<a target=\"_blank\" href=\"loads.php?loadNo="sam[i]"\">"sam[i]"</a> SU-" i; }
			print "</pre>"; } ' "${LOGS_DIR}"/lab_log.txt
