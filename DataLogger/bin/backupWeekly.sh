#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# backupWeekly.sh — Description
# Usage: backupWeekly.sh
# Author: Charlie Marshall
# License: MIT

DATE=$(date +"%d-%m-%Y")
BACKUP=backup_$DATE.tar.gz

# Backup scripts
tar -cvpzf backup_scripts.tar.gz --exclude=*.tar.gz $HOME/bin /etc/apcupsd/onbattery /etc/apcupsd/offbattery /etc/apcupsd/apctest.output /etc/apcupsd/apcupsd.conf ~/.bashrc $HOME/.dropbox_uploader /etc/maildroprc .getmail/getmailrc

tar -cvpzf backup_webServer.tar.gz --exclude=images --exclude=*.xspf --exclude=dist/js $WEB_SERVER_DIR/ # no JS as Gmail reject .js files even in zip files
tar -cvpzf backup_logs.tar.gz --exclude=Screenshot_App_Attachments "${LOGS_DIR}"/

echo -e "Backup" | mailx -A backup_scripts.tar.gz -A backup_webServer.tar.gz -A backup_logs.tar.gz -s "Weekly Scripts, logs and Web Backup $DATE" "user@domain"

# create tar of JS files and upload to dropbox as gmail will not accept js attachments
tar -cvpzf backup_webServer_JS_files_$DATE.tar.gz $WEB_SERVER_DIR/dist/js
tar -cvpzf backup_NodeJS_examples_$DATE.tar.gz $HOME/node_modules/omron-fins/examples $HOME/node_modules/omron-fins/lib/constants.js
dropbox_uploader.sh upload backup_webServer_JS_files_$DATE.tar.gz /Backups/scripts/Logger/
dropbox_uploader.sh upload backup_NodeJS_examples_$DATE.tar.gz /Backups/scripts/Logger/

rm backup_scripts.tar.gz backup_webServer.tar.gz backup_logs.tar.gz backup_webServer_JS_files_$DATE.tar.gz backup_NodeJS_examples_$DATE.tar.gz

# one liner:
# tar -cvpzf backup_logs.tar.gz --exclude=Screenshot_App_Attachments "${LOGS_DIR}"/ && mail -A backup_logs.tar.gz -s "logs attached" "user@domain"
