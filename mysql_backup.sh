#!/bin/sh
BACK_FOLDER=/home/conf
MYSQL_PASSWORD=Wdj@0562
DB_HOST_IP=192.168.2.155
DB1=boblog
DB_USER=boblog
BACKUP_COMMAND=mysqldump

DATE=`date +%Y%m%d`

$BACKUP_COMMAND -h $DB_HOST_IP -u $DB_USER -p$MYSQL_PASSWORD $DB1 > $BACK_FOLDER/$DB1-$DATE.sql
