#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# openWeather.sh — A script to check the weatherforecast and report if freezing weather is expected
# Usage: openWeather.sh
# Author: Charlie Marshall
# License: MIT

alarmTemp=3

data=$(curl -s "http://api.openweathermap.org/data/2.5/forecast?id=2653137&APPID=****removed****&units=metric&cnt=40")

for i in {0..31}; do
#  echo $data | jq .list[$i].dt_txt | tr -d '"' | cut -d ' ' -f 1
  date=$(echo "$data" | jq .list["$i"].dt_txt)
  temp=$(echo "$data" | jq .list["$i"].main.temp_min)
  desc=$(echo "$data" | jq .list["$i"].weather[0].description)
#  echo -e "${date}\t{$desc}\t${temp}" | tr -d '"{}'
  echo -e "${date%:*}\t{$desc}\t${temp}" | tr -d '"{}' # %:* removes the seconds from the date
done | awk -v alarmTemp="$alarmTemp" '
#	{print $0 + "\302\260C"} # celcius symbol
#	{message = sprintf("%s%s\302\260C\n", message, $0)} # celcius symbol

	$NF=$NF-2 # Make an adjustment as it does not seem as accurate as accuweather!

	{  if($NF<alarmTemp) {
		alarm="1";
		message = sprintf("%s%s\302\260C\tWarning freezing conditions\n", message, $0) # celcius symbol
	  }
	  else  message = sprintf("%s%s\302\260C\n", message, $0) # celcius symbol
	}
	END{
		url = "\nhttps://www.accuweather.com/en/gb/tormarton/gl9-1/hourly-weather-forecast/708507"
		print message;
		if(alarm==1) { system("printf \"" message url "\" | mail -a \"From: user@domain\" -s\" Weather warning - Low temperatures forecast\" user@domain") }
	}'

# system("pushAlarm.sh \"" string "\" ");
#echo $data | jq .list[1].main.temp
#echo $data | jq .list[1].dt_txt

