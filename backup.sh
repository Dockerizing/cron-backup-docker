#!/bin/sh

## configuration
VIRTUSER="dba" # virtuoso username
VIRTPASS=$VIRTUOSO_ENV_PWDDBA # virtuoso password 
BACKUPDIR=$BACKUP_PATH # make sure this is in DirsAllowed in virtuoso.ini 
#DAYS=14 # files older then x days will be removed from the backup dir

## functions
function createbackup {
	ISQL=`which isql-vt`
	BACKUPDATE=`date +%y%m%d-%H%M`
  	$ISQL virtuoso $VIRTUSER $VIRTPASS <<ScriptDelimit
		backup_context_clear();
		checkpoint;
		backup_online('virt_backup_$BACKUPDATE#',150,0,vector('$BACKUPDIR'));
		exit;
ScriptDelimit
}

## program
mkdir -p $BACKUPDIR
createbackup
#find $BACKUPDIR -mtime +$DAYS -print0 | xargs -0 rm 2> /dev/null

cp -a $BACKUPDIR/. $GIT_REPO_PATH

rm -r $BACKUPDIR

# Push is possible if host .ssh contains 
# proper private key and github.com is added 
# to know_hosts 

git add -A
git commit -m "Cron backup commit."
git push origin master

