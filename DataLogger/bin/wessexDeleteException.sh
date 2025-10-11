#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# wessexDeleteException.sh — Delete old lab exception emails
# Usage: wessexDeleteException.sh
# Author: Charlie Marshall
# License: MIT

# https://ostechnix.com/find-delete-oldest-file-x-files-directory/
# ls : List directory contents.
# -1t : 1(Number one) indicates that the output of ls should be one file per line. t indicates sort contents by modification time, newest first.
# tail : Output the last part of files.
# -n +11 : output the last NUM lines, instead of the last 10; or use -n +NUM to output starting with line NUM
# xargs : Build and execute command lines from standard input.
# -r : don't run if there are no files to delete

###### MAKE SURE WE CD IN TO THE DIR OTHERWISE WE WILL BE DELETING FILES FROM OUR CURRENT DIR!!!! #####
cd "${HOME}/Maildir/lab/exception/attachments/" || exit;

# may be better to use find over ls -1t
# we may need to use rm -f when running from cron or www-data. Check
ls -1t | tail -n +8 | xargs -r rm
