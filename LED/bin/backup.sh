#!/bin/bash
DATE=$(date +"%d-%m-%Y")
BACKUP="CSW_NodeJS_LED_$DATE.tar.gz"

tar -cvpzf ../"${BACKUP}" \
  ../etc/systemd/system/led.service \
  backup.sh \
  *.js* \
  ../readme.txt \
  ../fonts/9x15B.bdf

#eval "(echo -e \"Backups attached\" ; uuencode ${BACKUP} ${BACKUP})" | mail -s "CSW Node JS LED backup - $DATE" user@domain

#rm ${BACKUP}
