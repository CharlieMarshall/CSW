#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# weatherAlert.sh — Description
# Usage: weatherAlert.sh
# Author: Charlie Marshall
# License: MIT

# Script to send weather warnings via email when there is a risk of freezing
warningTemp="2"         # temperature at which email alerts are sent

# get date in ' Mmm d' format
dateToday=$(date +"%b %-d")
dateTomorrow=$(date +"%b %-d" -d '1 day')
dateDayAfter=$(date +"%b %-d" -d '2 day')

# Note HTML page layout changes throughout the day so this script will work only during day hours, issues will occur if run at night
# ignore first four dates as they are 'My Recent Locations' on the webpage source, exit after reading 3 days of weather

# use ':' as a deliminator
IFS=: read todayHigh todayLow todayText tomorrowHigh tomorrowLow tomorrowText dayAfterHigh dayAfterLow dayAfterText < \
	<(awk '$0 ~ /<span class=\"large-temp/ && ++counter>4 {
		sub(/^.*<span class=\"large-temp\">/,"",$0);		sub(/&deg;<\/span>.*$/,"",$0); printf $0 ":"; getline;
		sub(/^.*<span class=\"small-temp\">\//,"",$0); 		sub(/&deg;(C|)<\/span>.*$/,"",$0); printf $0 ":"; getline; getline;
		sub(/^.*<span class=\"cond\">/,"",$0);			sub(/<\/span>.*$/,"",$0); printf $0 ":";
		if(counter>6) {exit}
	} ' <(curl -s 'https://www.accuweather.com/en/gb/tormarton/gl9-1/daily-weather-forecast/708507' \
		-H 'user-agent: Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.77 Safari/537.36'))
# NOTE we needed to change this line to spoof the user-agent as it was getting rejected!
# old line: #<(wget -q -O- http://www.accuweather.com/en/gb/tormarton/gl9-1/daily-weather-forecast/708507))

# Body of email
message="Ensure mains water hoses are left running.\n
Today: $todayText\n\tHigh:\t$todayHigh°\n\tLow:\t$todayLow°\n
${dateTomorrow}: $tomorrowText\n\tHigh:\t$tomorrowHigh°\n\tLow:\t$tomorrowLow°\n
${dateDayAfter}: $dayAfterText\n\tHigh:\t$dayAfterHigh°\n\tLow:\t$dayAfterLow°\n"

printf "$message"	# Debugging

# if any of the temperatures are <= to the warning temperature send email alert
if [ "$todayHigh" -le "$warningTemp" ] || [ "$todayLow" -le "$warningTemp" ] ; then
	printf "$message" | mail -a "From: user@domain" -s "Weather warning, Today $dayToday $dateToday - Low temperatures forecast" user@domain
elif [ "$tomorrowHigh" -le "$warningTemp" ] || [ "$tomorrowLow" -le "$warningTemp" ] ; then
	printf "$message" | mail -a "From: user@domain" -s "Weather warning, Tomorrow $dayTomorrow $dateTomorrow - Low temperatures forecast" user@domain
elif [ "$dayAfterHigh" -le "$warningTemp" ] || [ "$dayAfterLow" -le "$warningTemp" ] ; then
	printf "$message" | mail -a "From: user@domain" -s "Weather warning, $dayDayAfter $dateDayAfter - Low temperatures forecast" user@domain
fi

