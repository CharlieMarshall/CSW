#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# wessexExceptionArray.sh — A script to parse and put into an HTML table the Lab Exception Reports
# Usage: wessexExceptionArray.sh
# Author: Charlie Marshall
# License: MIT
#
# first two lines of the awk body are the old script missingLab.sh
# if reads the lab_log.txt and makes a note of all sample names
# it then reads the load_log.txt file and finds the ones which are not present and saves them to the samples array

# Dealing with Exception report: pre merging with the missing lab report it started like so: awk -v RS='<[^>]+>' -v ORS=""
#
# Works by striping off all the HTML: awk -v RS='<[^>]+>' -v ORS=""
# It ignores all the lines before the Date in the header Wessex Water Laboratory Exception Report for DATE
# It then takes the next non blank line as a sample description and set it into the variable sample and an array samples
# It then reads until it find the lines (Con|Act)&nbsp;upper as these preceed the number of bacteria and a Pres Pseudo does not have a Act... line
# Now we know the next line has the number of bacteria we save it into the variable count and keep a marker of previous data incase there are more failues on this sample
# Then it matches the type of failure and adds it to the array. Resets sample to 0 so we can look for a new sample

cd "${HOME}/Maildir/lab/exception/attachments/" || exit

awk -F"\t" -v fromLoad=3252 '
BEGIN { OFS="</td><td>"; OFS2="</td><td class=\"critical\">"; \
	print "<table id=\"myTable\" class=\"table table-condensed table-bordered table-hover tablesorter\" style=\"padding: 10px;\">\n \
                <thead>\n \
                        <tr>\n \
                                <th>Sample</th>\n \
                                <th>Reference</th>\n \
                                <th>Loaded</th>\n \
                                <th>Sampled</th>\n \
                                <th>Coliform</th>\n \
                                <th>E. coli</th>\n \
                                <th>Enterococci</th>\n \
                                <th>Pseudo</th>\n \
                                <th>TVC 37</th>\n \
                                <th>TVC 22</th>\n \
                                <th>Pres Coliform</th>\n \
                                <th>Pres E. coli</th>\n \
                                <th>Pres Enterococci</th>\n \
                                <th>Pres Pseudo</th>\n \
                        </tr>\n \
                </thead>\n \
                <tbody>\n";
        }

	FILENAME==ARGV[1] && $2 ~ /^[0-9]/ && $2>fromLoad 	{ a[$2]++; next }	# store all load numbers from the lab_log.txt into array a
	FILENAME==ARGV[2] && $1>fromLoad && !a[$1]		{ if(++i==1) { oldestLoad=$1; } samples[$1]=$1; loaded[$1]=$2; next }	# add missing certificates to the samples array

	FNR==1			{ start=0 }			# set start to 0 for each file
	/202[1-5]$/ && FILENAME!=ARGV[0] && FILENAME!=ARGV[1]	{ start++; next; }	# sets start to 1 on detecting WESSEX WATER - LABORATORY EXCEPTION REPORT for 26/11/2021. We will now read all subsequent lines
	start==0		{ next; }			# skip all lines until we have reached the martker eg after the header info

	!/^[a-z]|[A-Z]|[0-9]/	{ next; }			# skip all blank lines NF==0 was not enough here
	/.*\{/ || /^&nbsp;/	{ next; }			# this stops a &nbsp being printed on a line which begins wih <div> and is full of CSS
	/^Page/			{ next; }			# skip the page lines otherwise these are detected as new samples
	/^SU-/			{ SU[sample]=$0; }		# record the SU number
	/\/20[2-5]/ && FILENAME!=ARGV[0] && FILENAME!=ARGV[1]	{ sampledDate[sample]=$0 }		# record the sample date and time

	# record the type of failure
	/^Coliform&nbsp;bacteria/				{ coli[sample]=count; sample=0; next;}
	/^Escherichia&nbsp;coli/				{ ecoli[sample]=count; sample=0; next; }
	/^Confirmed&nbsp;Enterococci&nbsp;\/&nbsp;250ml/	{ enter[sample]=count; sample=0; next;}
	/^Pseudomonas&nbsp;aeruginosa&nbsp;\/&nbsp;250ml/	{ pseudo[sample]=count; sample=0; next; }

	/^Plate&nbsp;count&nbsp;3&nbsp;day&nbsp;@&nbsp;22°C/	{ tvcone[sample]=count; sample=0; next;}
	/^Plate&nbsp;count&nbsp;1&nbsp;day&nbsp;@&nbsp;37°C/	{ tvcthree[sample]=count; sample=0; next; }

	/^Presumptive&nbsp;coliform&nbsp;bacteria/		{ prescoli[sample]=count; sample=0; next; }
	/^Pres&nbsp;P.&nbsp;aeruginosa&nbsp;\/&nbsp;250ml/	{ prespseudo[sample]=count; sample=0; next; }
	/^Presumptive&nbsp;Enterococci&nbsp;\/&nbsp;250ml/	{ presenter[sample]=count; sample=0; next; }
	/^Presumptive&nbsp;E.&nbsp;coli/			{ presecoli[sample]=count; sample=0; next; }

	/(Con|Act)&nbsp;upper/		{ value=1; next; }	# indicates the next line we handle will be the value. NOTE Pres PA does not have a Act&nbsp;upper line only a Con&nbsp;upper

	sample==0 && /^COMMENTS/	{ nextfile; }		# Was expecting a sample so there must be no exceptions! Is cleaner than the following alternative line
#	/No&nbsp;exceptions&nbsp;to&nbsp;report&nbsp;today/	{ delete samples[sample]; nextfile; }	# we need to delete the sample from the array if there were no exceptions (the first line COMMENTS is added as a sample
	sample==0 && /^\//		{ sample=prevSample; sampledDate[sample]=prevSampledDate; SU[sample]=prevSU; next; }	# this handles when there are multiple failures on one sample. Normally begins with a /250ml Otherwise the sample is labeled as 250ml. 
			#Check this works for 1 Litre
	sample==0			{ sample=$0; samples[$0]=$0; next; }	# this will get the sample number. It is the first line read and also the first line read after value is set to 0 in the line below
	value==1 			{ count=$0; prevSampledDate=sampledDate[sample]; prevSample=samples[sample]; prevSU=SU[sample]; value=0; } # this line holds the number of bacteria. We set previous readings incase we need to reference them for more failures on this sample

#	start>0				{ print NR "\t" $0 "\n" }	# print all non blank lines for debugging

	END	{
		for( i in samples )
			# only print exceptions we do not have certificates for and any text based eg borehole or blends etc
			if(i>=oldestLoad) {
				if(i ~ /^[0-9]/)
					print "<tr><td><a target=\"_blank\" href=\"loads.php?loadNo="i"\">"i"</a>" OFS SU[i] OFS loaded[i] OFS sampledDate[i] OFS2 coli[i] OFS2 ecoli[i] OFS2 enter[i] OFS2 pseudo[i] OFS tvcone[i] OFS tvcthree[i] OFS prescoli[i] OFS presecoli[i] OFS presenter[i] OFS prespseudo[i] "</td></tr>\n";
				else
					print "<tr><td>" i OFS SU[i] OFS loaded[i] OFS sampledDate[i] OFS2 coli[i] OFS2 ecoli[i] OFS2 enter[i] OFS2 pseudo[i] OFS tvcone[i] OFS tvcthree[i] OFS prescoli[i] OFS presecoli[i] OFS presenter[i] OFS prespseudo[i] "</td></tr>\n";
			}
		print "\t\t</tbody></table>"
	}' "${LOGS_DIR}/lab_log.txt" "${LOGS_DIR}/load_log.txt" RS="<[^>]+>" ORS="" *
