#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# backupDaily.sh — Description
# Usage: backupDaily.sh
# Author: Charlie Marshall
# License: MIT

DATE=$(date +"%d-%m-%Y")
BACKUP=backup_$DATE.tar.gz

tar -cvpzf $BACKUP --exclude=Screenshot_App_Attachments "${LOGS_DIR}"/*_log.txt
echo -e "Backup" | mailx -A $BACKUP -s "Daily log backup attached $DATE" "user@domain"
rm $BACKUP
