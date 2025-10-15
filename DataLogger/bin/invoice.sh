#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# invoice.sh — A script to create an pdf invoice which we can then email to our customer
# Usage: invoice.sh date eg invoice.sh 01-01-2017
# Author: Charlie Marshall
# License: MIT

cd "${LOGS_DIR}" || exit

if [ $# -eq 0 ]; then
	invoiceDate=$(date +%d-%m-%Y --d "yesterday") # if no date specified, default to yesterday
else
	invoiceDate="$1"
fi

invNumber=$( echo "$invoiceDate" | awk -F"-" '{ print substr($3,3)$2$1 } ') # Creates an invoice nuymber of YYDDMM
attachment="Invoice_$invNumber.pdf"
subject="Invoice $invNumber from Cotswold Spring Water"
email="user@domain"
message="Hello,\n\nPlease find invoice $invNumber attached.\n\nKind regards\n\nCotswold Spring Water"

# make a table of the loads dispatched on this date
invoices="$(awk -v iDate=$invoiceDate ' BEGIN{ORS="<br>"} $0 ~ iDate { a[$1]; loads++; } END{
		sales=loads*230;

	        print "<tr><td>" loads "</td><td>29,500 Litres of Spring Water</td><td>&pound;" sales \
		"</td><td>&pound;" sales*0.2 "</td><td>&pound;" sales*1.2 "</td></tr><tr><td><br><b>Load Numbers:</b><br> ";
			for (x in a){ print "380504-" x }

		# add padding to the invoice
		for (i=loads; i<21; i+=2) { print "<br>" }
} ' load_log.txt)"

# calculte the quantity field for the invoice
noInvoices="$( grep -c $invoiceDate load_log.txt )"

function createHTMLcert { # heredoc to create a HTML certificate
cat <<- _EOF_ > invoice.html
	<!DOCTYPE html>
        <HTML>
        <HEAD>
        <style>
		body { width:90%; padding:5px; margin-left: auto; margin-right: auto; font-family: "Times New Roman", Times, serif; }
                .centered p { text-align: center; }
		th { text-align:left; }
		th, td { padding: 5px; }
		.full { width: 100%; padding-top:20px }
        </style>
        <TITLE>Invoice</TITLE>
        </HEAD>

        <BODY>


	<table class="full"><tr><td>
		<b>CSW</b><br>
		Address Line1<br>
		Address Line 2<br>
		Address Line 3<br>
		Tel: telephone number<br>
		email<br>
		website<br></td>
	<td><img style="float:right" src="html_imgs/cswlogo.jpg" alt=""></td></tr></table>

	<table class="full"><tr><td>
	<b>Customer Address:</b><br>
        Address Line1<br>
        Address Line 2<br>
        Address Line 3<br>
	Postcode<br></td></tr></table>

	<table style="padding-top:20px; float:right">
	<tr><th>Invoice Number:</th><td>$invNumber</td></tr>
	<tr><th>Invoice Date:</th><td>$invoiceDate</td></tr>
	<tr><th>Account Ref:</th><td>REF</td></tr>
	<tr><th>Purchase Order:</th><td>000000</td></tr></table><br><br><br><br>

	<table class="full">
		<tr><th>Quantity</th><th>Product</th><th>Net</th><th>VAT</th><th>Total</th></tr>
		$invoices
		</td><td></td><td></td><td></td><td></td></tr></table><br><br><br><br>

	Payment Terms are strictly 30 days<br><br>
	Bank details for BACS payment:<br>
	Account Name: CSW<br>
	Sort Code: 00-00-00<br>
	Account Number: 00000000<br><br><br><br>

        <div class="centered"><p>CSW<br>
	Reg England No: 00000000 | VAT Reg No: 000 0000 00<p></div>

        </BODY>
        </HTML>
_EOF_
}

if [[ "$noInvoices" -gt "0" ]] ; then # Check we have dispatched goods this day
	createHTMLcert "$invoices" "$noInvoices" # create a HTML invoice
	#xvfb-run -a -- wkhtmltopdf -q invoice.html $attachment # create pdf from above HTML file
	wkhtmltopdf -q --disable-smart-shrinking --zoom 0.5 invoice.html $attachment # create pdf from above HTML file

	# TO STOP EMAILS COMING FROM www-data we need to use mail -a (taken from http://stackoverflow.com/questions/54725/change-the-from-address-in-unix-mail)
	eval "(echo -e \"$message\" ; uuencode $attachment $attachment)" | mail -a "From: user@domain" -s "$subject" "$email" # send invoice by email
        rm invoice.html "$attachment"
	echo -e "\nInvoice $invNumber for $invoiceDate has been sent!"
else
        echo -e "There were no loads dispatched on $invoiceDate"
fi
