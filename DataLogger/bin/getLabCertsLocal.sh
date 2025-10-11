#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# getLabCertsLocal.sh — A script to retrieve lab certificate files from the email server and parse them into a lab_log.txt file
# Usage: getLabCertsLocal.sh
# Author: Charlie Marshall
# License: MIT

cd "${HOME}/Maildir/lab/certs/attachments" || exit

# if folder is not empty parse each file
if [ "$(ls -A .)" ]; then
  for f in *; do

#    DELETE THIS LINE IF WORKING
#    if [ 0 -eq $(echo "$f" | grep -c $(sed -e 's/^0*//' -e 's/\..*$//') "${LOGS_DIR}/lab_log.txt") ]; then

     certNo=$((10#$(echo "${f}" | cut -d'.' -f 1)))       # remove leading 0s and remove file extension

     if [ 0 -eq $(grep -c "${certNo}" "${LOGS_DIR}/lab_log.txt") ]; then
	# pdftotext: output text-file is '-' = the text is sent to stdout
	pdftotext -layout -l 1 "$f" - | awk -v file="$f" ' BEGIN { OFS="\t"; IGNORECASE=1; coli=ecoli=enter=pseudo=tvc1=tvc3=pres_coli=pres_ecoli=pres_enter=pres_pseudo="-" }

		# function to trim the fluff off the end of the line and returns the lab result (last column)
		function getResult() {
		  sub(/(cfu)?\/(100ml|250ml|ml|1L).*$/, "" , $0);
#		  sub(/\/[1|2|ml].*$/, "" , $0);
		  return $NF
		}

		/Supersedes/						{ next }						# skip over this overwise it could read the old cert number
		/Report No/						{ cert=$NF; next }
		/Lab reference/						{ if($3 !~ /27000247/)  { assert_exit=1; exit }		# handles a certificate meant for another customer (received in error)
									  sub(/^.*27000247\//, "" , $0); su=$1; next }
       		/Sample taken/						{ sample_date=$3" "$4; next }
		/Sample received/					{ lab_rec=$3" "$4;
									  sub(/^.*ID:\s+/,"",$0);				# remove fluff to leave sample description in $0
									  sub(/(tanker\s+)|(ref\s+)|(\s+library.*$)/,"",$0);	# remove 'tanker', 'ref' & 'Library' from sample description
									  sample=tolower($0); next }

# NOTE in regex *=0 or more spaces, +=1 or more spaces. \s is a space
#
# NOTE there is NO spaces between the volumne and ml with 250ml samples eg /250ml
# NOTE there is a spaces between the volumne and ml with 100ml samples eg /100 ml
#
# NOTE there is a spaces between the back slash and the 250ml volumne in the sample description eg /Confirmed Enterococci / 250ml
# without this space the program would not work correctly and will need amending
#
# Brief explaination:
# On finding a match we remove, using getResult, all the line contents after the result
# This is a back slash followed immediately by the number of ml followed by 0 or more spaces and then ml and then all the remaining characters to the end of the line eg /250ml  0   3303
# Now we are left with the result column as the last column on the line, $NF, which we pass to our variable

		/Presumptive coliform bacteria/ && /cfu\/1L/		{ pres_coli=getResult(); cost+=4.28; next }
		/Presumptive coliform bacteria/ && /250\s*ml/		{ pres_coli=getResult(); cost+=4.75; next }
		/Presumptive coliform bacteria/	&& /100\s*ml/		{ pres_coli=getResult(); cost+=4.19; next }

		# As these are included in the coliform price we dont need to check the volume of the sample
		$1 ~ /Coliform/						{ coli=getResult(); next }
		/Presumptive E. coli/					{ pres_ecoli=getResult(); next }
		/Escherichia coli/					{ ecoli=getResult(); next }

	       	/Enterococci/ && /100\s*ml/				{ enter=getResult(); cost+=3.39; next }
	       	/Confirmed Enterococci/ && /250\s*ml/			{ enter=getResult(); cost+=4.03; next }

		/Presumptive Enterococci/ && /100\s*ml/			{ pres_enter=getResult(); cost+=3.51; next }
		/Presumptive Enterococci/ && /250\s*ml/			{ pres_enter=getResult(); cost+=4.12; next }

		/Pseudomonas aeruginosa/ && /250\s*ml/			{ pseudo=getResult(); cost+=4.05; next }
		/Pseudomonas aeruginosa/ && /100\s*ml/			{ pseudo=getResult(); cost+=3.94; next }

		/Pres P. aeruginosa/					{ pres_pseudo=getResult(); if(pres_pseudo>0) { cost+=6.06 } next }
		/Presumptive Pseudomonas aeruginosa/			{ pres_pseudo=getResult(); if(pres_pseudo>0) { cost+=3.94 } next }

		/Plate count 3 day/					{ tvc3=getResult(); cost+=3.46; next }
		/Plate count 1 day/					{ tvc1=getResult(); cost+=3.20; next }

		/Sample Deviations/||/UKAS accredited/			{ exit }

		END {
			if (!assert_exit){
                                print cert, sample, sample_date, lab_rec, coli, ecoli, enter, pseudo, tvc1, tvc3, pres_coli, pres_ecoli, pres_enter, pres_pseudo, cost, su;
				split(sample_date,a,"/| "); # some reason a[0] is a space
				system("dropbox_uploader.sh -q upload " file " /Certification/Testing/"a[3]); #a[3] holds year
			}
		}' # <(pdftotext -layout -l 1 $file -) # could use process substituion instead but that involves creating a tmp file
    fi
    rm "$f"
  done >> "${LOGS_DIR}/lab_log.txt"
fi
