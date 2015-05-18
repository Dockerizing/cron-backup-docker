ENV_GITREPO=$GITREPO

BACKUP_PATH=/var/lib/backup-repository

mkdir $BACKUP_PATH
git clone $ENV_GITREPO $BACKUP_PATH

cron -f
