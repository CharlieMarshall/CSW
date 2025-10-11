#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# findLabRetests.sh — Display an HTML <pre> tag of any lab retests (duplicate sample number)
# Usage: findLabRetests.sh
# Author: Charlie Marshall
# License: MIT

# we use $2+0 otherwise we will have text which is repeated eg borehole
# $2+0 > 0 to show only 2019 onwards but we had the PO reset to 0 in feb 2019
awk -F"\t" ' $2+0 > 4480 { sample[$2]++ } END { print "<pre>"; for(i in sample) { if( sample[i]>1 ) \
	print "<a target=\"_blank\" href=\"loads.php?loadNo="i"\">"i"</a>" } print "</pre>" } ' "${LOGS_DIR}"/lab_log.txt
