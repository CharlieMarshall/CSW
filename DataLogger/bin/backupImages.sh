#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# backupImages.sh — Description
# Usage: backupImages.sh
# Author: Charlie Marshall
# License: MIT

DATE=$(date +"%d-%m-%Y")
BACKUP=backup_images_$DATE.tar.gz

# Backup scripts
tar -cvpzf $BACKUP $WEB_SERVER_DIR/images/BackTankerTransXS.png $WEB_SERVER_DIR/images/waterTankTransXS.png $WEB_SERVER_DIR/images/BackTankerTrans.png $WEB_SERVER_DIR/images/waterTankTrans.png $WEB_SERVER_DIR/images/ajax-loader.gif $WEB_SERVER_DIR/images/logo.png

echo -e "Backup" | mailx -A $BACKUP -s "Web GUI Images Backup $DATE" "user@domain"

dropbox_uploader.sh upload $BACKUP /Backups/scripts/Logger/

rm $BACKUP
