#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# getCallOffLocal.sh — Converts a calloff.pdf to a text file and then creates us an orders.txt populated with loads numbers and collection times
# Usage: getCallOffLocal.sh
# Author: Charlie Marshall
# License: MIT

cd "${LOGS_DIR}" || exit

dir=$HOME/Maildir/customer/attachments

# NOTE the getEmails.sh script prefilters the files, so only .pdf .xps .xlsx filetypes should reach here


#### function to convert a pdf call off to text and run it through awk to scrape all the data ####
function convert {

    #### IGNORE THIS COMMENTED BLOCK cant even remember what this commented line was for looks like it was retreiving the call off date and removing the blank spaces and tabs with sed
    # -m1 means only read the first occurence
    #    grep -m1 -E '[0-9]{2}/[0-9]{4}'| sed -e 's/^[ \t]*//' > orders.txt # as we output pdftotext to stdout we cant get the calloff date like this as we don't have a file  ####

    # pdftotext: output text-file is '-' = the text is sent to stdout
    pdftotext -layout calloff.pdf - | awk '
        BEGIN{ OFS="\t"; IGNORECASE=1; format = "%a %d/%m/%Y %H:%M"; m=split("Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec",d,"|");
                for(o=1;o<=m;o++){ months[d[o]]=sprintf("%02d",o) }
        }
	NR==1 && !/Call-Off/ 	{ exit }
	NF==2 			{ coDate = $1" "$2 }
	# we used [0-9] here as we have had mistakes and orders of 29,000 litres
        $0 ~ "29,[0-9]00" {
                if(match($0,"[0-3][0-9]-")) { $0=substr($0,RSTART) } # remove leading spaces and day of week

                # handle spaces in the wrong place  #### if(/[0-3][0-9]-[a-z][a-z][a-z]/) # normal output no spaces
                if(/[0-3][0-9]-[a-z][a-z] [a-z]/ || /[0-3][0-9]-[a-z] [a-z][a-z]/)      { loadDate= $1 $2;      loadTime=$3 }
                else                                                                    { loadDate= $1;         loadTime=$2 }

                split(loadTime,time,"[: ]");
                split(loadDate,days,"-");
                calMon=days[2];

                # Minus 1 hour to get collection times
                date = (strftime("%Y") " " months[calMon] " " days[1] " " time[1]-1 " " time[2] " 0")
                convertedDate=strftime(format, mktime(date))

                if($NF !~ "29,[0-9]00")     { print convertedDate, $NF }
                else                    { print convertedDate, "Forecast" }
        }
	END { print "Call off dated: " coDate "\n" > "calloffdate.txt" } ' > orders.txt

   echo -e "Call off attached" | mailx -A calloff.pdf -s "$(cat "${LOGS_DIR}"/calloffdate.txt)" "user@domain" # send cert by email

    rm "$f" calloff.pdf # delete xps file and temporary calloff.pdf
}

# check our email folder for file attachments and process them accordingly
ls "$dir" # debugging
if [ "$(ls -A "${dir}")" ]; then
  for f in "${dir}"/*; do
    type=$(file -b "$f")
    if [ "${type%%,*}" == "PDF document" ]; then
      echo "$f is a PDF file."
      cp "$f" calloff.pdf
      convert # function
    elif [ "${type%%,*}" == "Microsoft OOXML" ] || [ "${type%%,*}" == "Zip archive data" ]; then
      # hugo = XPS, Mindaugas = OOXML even when saved as XPS
      echo "converting OOXML / XPS to pdf"
      xpstopdf "$f" calloff.pdf # convert from xps to pdf
      convert # function
    else
      echo "File is not a PDF or a XPS."
      # exit; # do nothing with it, it will still exist next time so we should probably delete it or perhaps move it to a new folder
    fi
  done
fi
