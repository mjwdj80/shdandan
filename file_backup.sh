#!/bin/sh

#Author: Danjun.Wang
#E-mail:mjwdj1980@gmail.com

DATE=`date +%Y%m%d`

if [ -z $2 ]; then
  clear
  echo Pleas input the source folder and the destination folder.
  echo Usage: command source_folder destination_folder
  echo Example: back.sh /home/share /home/backup
  sleep 30
  exit
fi

if [ ! -d $2 ]; then
  clear
  echo Backup Harddisk does not exist! Please check the system!
  sleep 1800
  exit
else
  mkdir $2/$DATE
fi

if [ ! -d $1 ]; then
  echo $1 does not exist! Please check the the system and try again!
  sleep 1800
else
  clear
  echo Start copy $1 to $2/$DATE/
  cp -rf $1                  $2/$DATE/
  ls $2/$DATE/
  echo $1 was backup.
fi

