#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# wessexCostSummary.sh — A script which compares the Labs received cost summary to our own records, lab_log.txt
# Finds and displays any discrepancies, and prints out all the data on the items within the cost summary
# Usage: wessexCostSummary.sh
# Author: Charlie Marshall
# License: MIT

cd "${LOGS_DIR}" || exit

if [ ! -f CostSummary.txt ]; then
	echo "<div class=\"alert alert-danger alert-dismissable\"><a href=\"\" class=\"close\" data-dismiss=\"alert\" aria-label=\"close\">×</a>File not found, file must be called CostSummary.pdf</div>"
	exit 1
fi

# store in a[] the HTML print out of every line in the lab results (seem inefficient to do this on every line)
# store in cost[] the cost of each sample
# when a match is found add the line to print to matches[], accumulate the cost of the sample in total

#pdftotext -layout CostSummary.pdf costSum.tmp # replaced this line by piping it using process substitution
awk ' BEGIN { FS="\t"; OFS="</td><td>" }
	# function to trim the £ and thousand seperator from the financial values
	function removeFin() {
	  sub(/£/,"", $NF); sub(/\,/,"", $NF);
	}

	FNR==NR {
		su = substr($16,0,9);	# BUG? - we need this as otherwise $16 does not work normally for some reason

		# Add links to our loads
		if($2 ~ /^[0-9]/)
			$2 = "<a target=\"_blank\" href=\"loads.php?loadNo="$2"\">"$2"</a>";

		split($3, sampleDate,"[/ :]"); # note sampleDate[3] is the sampled year
		a[su]="<a href=\"file:removedpath" sampleDate[3] "/" sprintf("%08d",$1) ".pdf\">"$1"</a>" OFS su OFS $2 OFS $3 OFS $4 OFS $5 OFS $6 OFS $7 OFS $8 OFS $9 OFS $10 OFS $11 OFS $12 OFS $13 OFS $14 OFS "&pound;"$15;
		cost[su]=$15; next

		# replace above line with the following to match on report number instead of SU
		# a[$1]=$1 OFS "SU-"$16 OFS $2 OFS $3 OFS $4 OFS $5 OFS $6 OFS $7 OFS $8 OFS $9 OFS $10 OFS $11 OFS $12 OFS $13 OFS $14 OFS "&pound;"$15; cost[$1]=$15; next
	}

	# Replace $3 with $NF for the next two lines if we revert to matching to a report number instead of the SU
	FNR!=NR && /Report No.:/ && a[$3]	{ matches[numMatches++]=a[$3]; total+=cost[$3]; su=$3; next }
	FNR!=NR && /Report No.:/ && !a[$3]	{
						  su=$3;
						  miss[++numMissing]=$3;
						  next;
						  # Change above line to the following to show the report number and the sample description too:
						  # miss[++numMissing]=$3 "\t" $NF;
						  # getline; missDesc[numMissing]=$0; next;
						}
	FNR!=NR && /^\s+£/			{
						  sub(/£/,"", $NF);
						  # check if our cost do not match the labs && our cost is not 0 eg missing a cert, as we dont want to flag it here
						  if( (cost[su] != $NF+0) && (cost[su] != 0) ) {
						    cots[++numDiff]=cost[su]; labs[numDiff]=$0; sudiff[numDiff]=su;
						  }
						  next;
						}

	FNR!=NR && /Report Date/		{ reportDate=$NF; next }
	FNR!=NR && /Net Total/			{ removeFin(); netTotal=$NF; next }
	FNR!=NR && /VAT/			{ removeFin(); vat=$NF; next }
	FNR!=NR && /Gross Total/		{ removeFin(); grossTotal=$NF; next}

	END{
		printf "<pre>Report Date:\t%s\n\n", reportDate;

		if(numDiff!=0)		{
						print "We have the following discrepencies:\n";
						print "\t\tCSW\t\tLab"
						for(i=1;i<=numDiff;i++)
						    # only print discrepencies not missing one as we print them below without prices for quickly copy and pasteing into an email
						    printf "%s\t&pound;%.2f\t\t\t&pound;%.2f\n", sudiff[i], cots[i], labs[i];
						print "";
					}

		if(numMissing!=0)	{
						print "We are missing certificates for the following references:\n";
						  for(i=1;i<=numMissing;i++) print miss[i]; # "\t"  missDesc[i];
						print "";
					}

		print "\t\tCSW\t\tLab"
		printf "Net Total:\t&pound;%.2f\t\t&pound;%.2f", total, netTotal;
		printf "\nVAT Total:\t&pound;%.2f\t\t\t&pound;%.2f", total*0.2, vat;
		printf "\nGross Total:\t&pound;%.2f\t\t&pound;%.2f</pre>", total*1.2, grossTotal;

		print "<table  id=\"myTable\" class=\"table table-condensed table-bordered table-hover tablesorter\" style=\"padding: 10px;\">\n \
			<thead>\n \
				<tr>\n \
					<th>Cert No</th>\n \
					<th>Reference</th>\n \
					<th>Sample Desc</th>\n \
					<th>Sample Date</th>\n \
					<th>Lab Received</th>\n \
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
					<th>Cost</th>\n \
				</tr>\n \
			</thead>\n \
			<tbody>\n"

			# using one print statement causes irregular printing, outputting in the wrong order
			for(y=0;y<numMatches;y++){
				print "<tr><td>" matches[y];
				print "</td></tr>";
			}
		print "\t\t\t</tbody>\n\t\t</table>";
	}
' lab_log.txt FS=" " CostSummary.txt
