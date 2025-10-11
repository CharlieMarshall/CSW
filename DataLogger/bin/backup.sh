#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# backup.sh — Description
# Usage: backup.sh
# Author: Charlie Marshall
# License: MIT

DATE=$(date +"%d-%m-%Y")
BACKUP=backup_$DATE.tar.gz

# Backup scripts
tar -cvpzf backup_scripts.tar.gz --exclude=*.tar.gz $HOME/bin /etc/apcupsd/onbattery /etc/apcupsd/offbattery /etc/apcupsd/apctest.output /etc/apcupsd/apcupsd.conf ~/.bashrc
tar -cvpzf backup_logs.tar.gz --exclude=Screenshot_App_Attachments "${LOGS_DIR}"/
tar -cvpzf backup_webServer.tar.gz --exclude=images --exclude=*.xspf --exclude=dist/js "${LOGS_DIR}"/ # no JS as Gmail reject .js files even in zip files

# Compress 3 archives into one archive
tar -cvpzf $BACKUP backup_scripts.tar.gz backup_logs.tar.gz backup_webServer.tar.gz

# Alternatively create one large archive althought this is larger = longer upload time
#tar -cvpzf $BACKUP --exclude=*.jp* --exclude=*.png --exclude=*.xps --exclude=*.xspf --exclude=*.js --exclude=$WEB_SERVER_DIR/dist \
#	$HOME/bin "${LOGS_DIR}" $WEB_SERVER_DIR

#eval "(echo -e \"Backups attached\" ; uuencode $BACKUP $BACKUP)" | mail --debug-level 2 -s "Weekly scripts and log backup $DATE" "user@domain"

#eval "(echo -e \"Backups attached\" ; uuencode $BACKUP $BACKUP)" | mail -a "From: user@domain" -s "Weekly scripts and log backup $DATE" "user@domain"
echo -e "Backups attached" | mailx -A $BACKUP -s "Weekly scripts and log backup $DATE" "user@domain"

# create tar of JS files and upload to dropbox as gmail will not accept js attachments
tar -cvpzf backup_webServer_JS_files.tar.gz $WEB_SERVER_DIR/dist/js $HOME/node_modules/omron-fins/examples/*.js
dropbox_uploader.sh upload backup_webServer_JS_files.tar.gz /Backups/scripts/

rm backup_scripts.tar.gz backup_logs.tar.gz backup_webServer.tar.gz backup_webServer_JS_files.tar.gz $BACKUP


# TODO seperate the backup to multiple emails
# one liner:
#
# tar -cvpzf backup_logs.tar.gz --exclude=Screenshot_App_Attachments "${LOGS_DIR}"/ && echo -e "" | mail -A backup_logs.tar.gz -s "logs attached" "user@domain"

