#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

#
# emailCofc.sh — A script to find all unreleased loads which have been delivered (all but the last 2 loads).
# Create a HTML certificate of conformance and then convert it to pdf.
# Email the pdf certificate and mark the loads as released
#
# if no date specified, releases yesterdays loads
# if a date is passed as a command argument use specified date "./emailCofc.sh 01-01-2018"
#
# Usage: emailCofc.sh date(Optional) eg emailCofc.sh DD-MM-YYYY
# Author: Charlie Marshall
# License: MIT

############# IF I WANT TO USE A HEADER ON THE load_log.xls file ie " LOAD NO, DATE etc " on LINE 1
# This command will output line 2 to end of file minus the last 2 lines: tail -n +2 load_log.xls | head -n -2

cd "${LOGS_DIR}" || exit

subject="Certificate of conformance"
email="user@domain"
message="Hello,\n\nPlease find certificates of conformity attached.\n\nKind regards\n\nCotswold Spring Water"

function createHTMLcert { # heredoc to create a HTML certificate
cat <<- _EOF_ > certificate.html
        <HTML>
        <HEAD>
        <style>
                body { padding:5px ; font-family:Arial, Helvetica, sans-serif}
                .centered p { text-align: center; }
        </style>
        <TITLE>Certificate of Conformance</TITLE>
        </HEAD>

        <BODY>
        <br><center><img src="html_imgs/cswlogo.jpg"><br>
        <H2>Certificate of Conformance</H2></center><br>

        <b>Product:</b> Spring Water<br><br><br>
        This certifies that the following loads / delivery note numbers:</p>

        <ul style="list-style: none;">
	$1
	</ul><br>

        Have been tested and approved for:

        <ul style="list-style: none;">
        Taste: No unusual taste<br>
        Odour: No unusual smell<br>
        Appearance: Clear, bright and free from taints<br>
        PH: Between 6.5 &ndash; 8.5<br>
        Conductivity: Between 500 &ndash; 700 &mu;S/cm</ul><br>

        <div class="centered"><p>Spring Water at source complies with the specification in the Natural Mineral Water,<br>
        Spring Water and Bottled Drinking Water (England) Regulations 2007.</p>

        <p><b>Signed:</b>
        <img src="html_imgs/signature.png" height="37px" width="186" hspace="20">
        <b>Certificate Date:</b> $(date +%d/%m/%Y --date "yesterday" )<br></p></div></br>

        <div class="centered"><p>Cotswold Spring Water, Dodington Ash, Chipping Sodbury, Bristol, BS37 6RX<br>
        Tel: 01454 312403 | user@domain | www.cotswold-spring.co.uk<p></div>
        </BODY>
        </HTML>
_EOF_
}

re='[0-3][0-9]-[0-1][1-9]-20[1-9][0-9]$' # match our date format
if [ $# -eq 0 ]; then
        date=$(date +%d-%m-%Y --date "yesterday") # if no date specified, released yesterdays loads
else
	if [[ $1 =~ $re ]] ; then # if command argument matches REGEX use specified date
		date=$1
	else
		echo "Invalid command argument. Date required 'dd-mm-yyyy'"
		exit 1;
	fi
fi

attachment="$date.pdf" # This needs to be after the above if statement

# awk script - To take current load_log.txt file, create a list of all loads released today seperated with HTML line breaks
#
# The HTML file with surplus <br>'s removed can print 20 loads
# When converted to pdf it is shrunk so we can now print 25+ load nunbers.
# Therefore we use a for loop in END as padding to keep the HTML footer at the bottom

listLoads=$( awk -v d="$date" ' $0 ~ d { count++; print "380504-" $1 "<br>" } END { for (i=count; i<25; ++i) print "<br>" }' load_log.txt)

# create certificate
if [[ "$listLoads" = 380504* ]] ; then # Check we have a valid certificate to send (not blank)
	echo -e "The following loads have been released:\n\n$listLoads"
        createHTMLcert "$listLoads" # make HTML page for certs
#	wkhtmltopdf -q --disable-smart-shrinking --zoom 0.55 certificate.html $attachment # create pdf from above HTML file
	wkhtmltopdf -q --enable-local-file-access certificate.html $attachment # create pdf from above HTML file
	echo -e "$message" | mail -A $attachment -s "$subject" "$email" # send cert by email

	# old email way using uuencode
	# eval "(echo -e \"$message\" ; uuencode $attachment $attachment)" | mail -a "From: user@domain" -s "$subject" "$email" # send cert by email

	rm certificate.html $attachment
else
	echo -e "There are no loads to be released!"
fi
