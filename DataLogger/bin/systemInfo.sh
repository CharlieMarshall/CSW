#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# systemInfo.sh — Description
# Usage: systemInfo.sh
# Author: Charlie Marshall
# License: MIT

cd "${LOGS_DIR}"

cat /proc/device-tree/model
echo " ($(uname -m))"

echo -e "$(vcgencmd measure_temp | sed 's/=/\t/') \n" # require www-data to be in the video group: sudo usermod -G video www-data

cat /etc/os-release | awk -F"\"" '{print $2; exit}'

echo -e "Node Version: $(node -v)"
awk 'NR==2 { print "Bootstrap: " $3; exit}' $WEB_SERVER_DIR/dist/js/bootstrap3.min.js
echo -e "ChartJS: $(grep Chart.js $WEB_SERVER_DIR/accounts.php | cut -d'/' -f7)\n"

df -h | awk '/tmpfs/ { next } {print}'
echo -e "\nSystem $(uptime -p)\n"
echo -e "File Sizes:\n$(du -hc *_log*)\n"
echo -e "Lines of code:"
#wc -l *.{sh,pg,c} $WEB_SERVER_DIR/*.php | awk '
wc -l $HOME/node_modules/omron-fins/examples/*.js *.{sh,pg} $WEB_SERVER_DIR/*.php | awk '
	/.sh$/	{ sh+=$1;  next }
	/.pg$/	{ pg+=$1;  next }
	/.php$/	{ php+=$1; next }
	/.js$/	{ js+=$1; next }
#	/.c$/	{ c+=$1; next }
	END	{ OFS="\t"; print sh, "Bash\n" php, "Php\n" js, "Node.js\n" pg, "Gnuplot\n" $1, "Total" }'
#	END	{ OFS="\t"; print c, "C\n" sh, "Bash\n" php, "Php\n" pg, "Gnuplot\n" $1, "Total" }'

# Alternative single command (no pipes). Downside is lots of input files & slightly slower then 'wc -l' which is a built command.
#awk '	ENDFILE {
#		if(FILENAME ~ /.sh$/)		{ sh+=FNR }
#		else if(FILENAME ~ /.pg$/)	{ pg+=FNR }
#		else if(FILENAME ~ /.php$/)	{ php+=FNR }
#	}
#	END { OFS="\t"; print sh, "Bash\n" php, "Gnuplot\n"  php, "Php\n" NR, "Total" }' *.sh *.pg $WEB_SERVER_DIR/*.php
