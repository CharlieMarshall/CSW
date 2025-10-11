#!/bin/bash
DATE=$(date +"%d-%m-%Y")
BACKUP="CSW_NodeJS_LED_$DATE.tar.gz"

tar -cvpzf ../"${BACKUP}" \
  backup.sh \
  csw_Multi_Coloured_LED.js \
  ../etc/systemd/system/led.service \
  ../fonts/9x15B.bdf

#eval "(echo -e \"Backups attached\" ; uuencode ${BACKUP} ${BACKUP})" | mail -s "CSW Node JS LED backup - $DATE" user@domain

#rm ${BACKUP}
