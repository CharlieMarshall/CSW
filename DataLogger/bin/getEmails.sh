#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# getEmails.sh — A script which checks for new emails, downloads and extracts required attachments and deals with the attachments
# filter for the emails can be found here: /etc/maildroprc
# Usage: getEmails.sh
# Author: Charlie Marshall
# License: MIT

function delJunkAttachments {
  find "$1" -type f ! -iname "*.pdf" ! -iname "*.xps" ! -iname "*.xlsx" -exec rm {} \; # find and delete any unrequired attachments such as signatures
}

# if we want to test a new function we can use getmail -a but it will process all emails from the Inbox so we may want to delete the files off the server first
getmail	-n
#       -n, --new		retrieve only unread messages
#       -d, --delete		delete messages from server after retrieving
#       -l, --dont-delete	do not delete messages from server after retrieving
#       -a, --all		retrieve all messages

# if there are any emails, folder is not empty (ls -A):
#   munpack -C moves to that dir and decodes attachments
#   delete email file
#   delete any unwanted attachments
#   run required scripts which handles attachments

#### Annual Forecasts ####

if [ "$(ls -A "${HOME}"/Maildir/forecast/new)" ]; then
  munpack -C "${HOME}"/Maildir/forecast/attachments/ "${HOME}"/Maildir/forecast/new/* #unpack
  rm "${HOME}"/Maildir/forecast/new/* # remove email
  delJunkAttachments "${HOME}"/Maildir/forecast/attachments/
  annualForecast.sh &
fi

#### Call Offs ####

if [ "$(ls -A "${HOME}"/Maildir/customer/new)" ]; then
  munpack -C "${HOME}"/Maildir/customer/attachments/ "${HOME}"/Maildir/customer/new/* #unpack
  rm "${HOME}"/Maildir/customer/new/* # remove email
  delJunkAttachments "${HOME}"/Maildir/customer/attachments/
  getCallOffLocal.sh &
fi

#### Lab Certificates ####

if [ "$(ls -A "${HOME}"/Maildir/lab/certs/new)" ]; then
  munpack -C "${HOME}"/Maildir/lab/certs/attachments/ "${HOME}"/Maildir/lab/certs/new/* # unpack
  rm "${HOME}"/Maildir/lab/certs/new/* # remove email
  delJunkAttachments "${HOME}"/Maildir/lab/certs/attachments/
  getLabCertsLocal.sh &
fi

#### Cost Summary ####

if [ "$(ls -A "${HOME}"/Maildir/lab/costSummary/new)" ]; then
  munpack -C "${HOME}"/Maildir/lab/costSummary/attachments/ "${HOME}"/Maildir/lab/costSummary/new/* # unpack
  rm "${HOME}"/Maildir/lab/costSummary/new/* # remove email
  delJunkAttachments "${HOME}"/Maildir/lab/costSummary/attachments/

# why are using a loop here? can't we just to pdttotext -layout $HOME/Maildir/lab/costSummary/attachments/* output.txt

  for f in "${HOME}"/Maildir/lab/costSummary/attachments/*; do
    # dropbox_uploader.sh upload "$f" /CostSummary.PDF	# command to upload file to dropbox
    # convert pdf to txt saves us doing this every button click. Also means we are overwritting an existing file so the file permissions are not changed
    # as we need www-data to be able to read the file, so saves a mv and a chmod command
    pdftotext -layout "$f" "${LOGS_DIR}"/CostSummary.txt
    rm "$f"
  done
fi

#### Lab Exception Reports ####

if [ "$(ls -A "${HOME}"/Maildir/lab/exception/new)" ]; then
  munpack -C "${HOME}"/Maildir/lab/exception/attachments/ "${HOME}"/Maildir/lab/exception/new/* # unpack
  chmod -R -v a+r "${HOME}"/Maildir/lab/exception/attachments/	# we need to change permissions otherwise www-data can not read and process the exceptions
  rm "${HOME}"/Maildir/lab/exception/new/* # remove email
  rm "${HOME}"/Maildir/lab/exception/attachments/*.desc		# delete .desc files
#  push.sh "New Exception report found" "$(ls -l "${HOME}"/Maildir/lab/exception/attachments/* | cut -d " " -f 8-10)"
  # nothing to do here as the table is created on demand
fi


# Now we are using maildrop I don't think we get any zip files as attachments. getmail used to zip up multiple attachmenmts.
# The following line finds all zip files and unzip them, this handles .zip & .zip.1, .zip.2 etc and then deletes them:
# find . -maxdepth 1 -regex '\./.*\.zip.*' -exec unzip -o {} \; -exec rm {} \;
