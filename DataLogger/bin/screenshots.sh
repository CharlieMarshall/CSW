#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# screenshots.sh — A script to generate screenshots from our varoius CCTV systems
# Usage: screenshots.sh -h # for usage
# Author: Charlie Marshall
# License: MIT

# Settings for OLD hikvision DVR (DS-7204HWI-SH)
#
# rtsp://ip_address:port_number/codec/channel/main_or_sub/av_stream
# codec (mpeg4/h264), channel (ch01/ch02), stream (main, sub) and the â€œav_streamâ€ needs to be added to the end.
#
# Example:
# rtsp://admin:password@ip:554/mpeg4/ch1/main/av_stream
# rtsp://admin:password@ip:554/h264/ch4/sub/av_stream
#
# The stream portion (main and sub) indicate two separate streams on the camera.
# The main stream offers high resolutions and the sub stream offers low resolutions.
#
#
# For new NVR at CSW
#
# rtsp://username:password@ip:port/Streaming/Channels/channel&substream
# Example:
# rtsp://admin:password@ip:554/Streaming/Channels/202
#
# Channels 1-16 available, only 6 cameras installed therefore we are padding the stream with a leading 0
# Stream 1=high res, 2=low res

DIR="$LOGS_DIR/Screenshot_App_Attachments"
port="554"
device=custom; # default to custom
channel=1 # default to 1 in case channl no specified
stream=2 # default to low res streams
date=$(date +"%d-%m-%Y-%H:%M")
user="admin"
emailAddress=user@domain

usage="$(basename "$0") - A script to grab screen shots from network devices and send them as email attachments\n
Options\n\
\t-d,--device\n\t\t1 = Unit 1A CCTV\n\t\t2 = Unit 3 CCTV\n\t\t3 = Unit 8 CCTV\n\t\tloading = Rear loading bay cameras\n\t\tpanel = Cotswold PLC panel\n\t\tpi = Raspberry Pi Camera\n\t\tall = All devices\n\t\tcustom = Customisied devices [default]\n\
\t-c,--channel\n\t\tall (devices 1-3)\n\t\t1-4 (devices 1 & 2)\n\t\t1-6 (device 3)\n\
\t-q,--quality\n\t\t1 = High res (device 3)\n\t\t2 = Low Res (device 3) [default]\n\
\t-e,--email\n\t\t Receipient email address\n\n\
Example usage:\n$(basename "$0") -d 1 -c 4\n$(basename "$0") -d 3 -c all -q 1\n$(basename "$0") -d panel -e example@domain.com"

while [[ $# -gt 0 ]]
do
key="$1"

case $key in
	-d|--device)
	device="$2"
	shift # past argument
	;;
	-c|--channel)
	channel="$2"
	shift # past argument
	;;
	-q|--quality)
	stream="$2"
	shift # past argument
	;;
	-e|--email)
	emailAddress="$2"
        shift # past argument
	;;
	*) # catch everything else
	echo -e "$usage"
	exit 1
esac
shift # past argument or value
done

function dvr {
	password="password"
	if [ "$1" -eq 1 ]
	then
		ip="xxx.xxx.xxx.xxx"
	else
		ip="xxx.xxx.xxx.xxx"
	fi
	encodeStream "rtsp://${user}:${password}@${ip}:${port}/h264/ch$2/main/av_stream" "${DIR}/cctv${1}-${2}02.jpeg"
}

function nvr {
	ip="xxx.xxx.xxx.xxx"
        password="password"

	encodeStream "rtsp://${user}:${password}@${ip}:${port}/Streaming/Channels/${1}""0${stream}" "${DIR}/cctv3-${1}0${stream}.jpeg"
}

function panel {
	echo "Retrieving panel screenshot"
	curl "${panelip}/image.png" -o "${DIR}/panel.png"
}

function pi {
	echo "Taking Pi photo"
	raspistill -w 860 -h 640 -n -e jpg -q 10 -th none -o "${DIR}/pi.jpg"
}

function encodeStream {
	echo "Encoding stream to $2"
	avconv -loglevel fatal -rtsp_transport tcp -i "$1" -frames 1 -y "$2"
}

function email {
#	echo "Sending email ..."
	emailCommand="(echo \"Screenshots attached\";"
	for f in "${DIR}"/*
	do
		emailCommand+="uuencode $f $f ; "
	done
	emailCommand+=") | mail -a \"From: user@domain\" -s \"Screenshots - $date\" $emailAddress"
	eval $emailCommand
}

case "$device" in
	1|2)
	if [ "$channel" = "all" ]
	then
		i=1
                while [ "$i" -lt 5 ]
		do
			dvr "$device" "$i"
			i=$((i+1))
		done
	else
		dvr "$device" "$channel"
	fi
	;;
	3)
	if [ "$channel" = "all" ]
        then
                i=1
                while [ "$i" -lt 7 ]
                do
                        nvr "$i"
                        i=$((i+1))
                done
        else
                nvr "$channel"
        fi
	;;
	panel)
	panel
	;;
	pi)
	pi
	;;
	custom)
#	dvr 1 4 #commented for now as camera is not working
	nvr 1
	nvr 2
	nvr 4
	nvr 5
	nvr 6
	panel
	;;
        loading)
	nvr 5
        nvr 6
        ;;
	all)
	i=1
	while [ $i -lt 5 ]
	do
		dvr 1 $i
		dvr 2 $i
		nvr $i # loop over first for channels
		i=$((i+1))
	done # fetch remainig 2 channels
	nvr 5
	nvr 6
	panel
	pi
	;;
	*)
	echo "Invalid device argument"
	exit 1
esac

email
rm "${DIR}"/*
