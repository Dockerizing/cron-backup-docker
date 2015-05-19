#!/bin/sh

BACKUP_PATH=/var/lib/backup-repository
VOLUME_PATH=/var/lib/cron-backup-docker

cd $VOLUME_PATH
tar -czf backup.tar.gz ./

cp backup.tar.gz $BACKUP_PATH

rm backup.tar.gz

cd $BACKUP_PATH

# Push is possible if host .ssh contains 
# proper private key and github.com is added 
# to know_hosts 

git add -A
git commit -m "Cron backup commit."
git push origin master

