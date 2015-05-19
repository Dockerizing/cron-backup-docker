ENV_GITREPO=$GITREPO
ENV_ID_RSA=$GITRSA

BACKUP_PATH=/var/lib/backup-repository

# Enable authentication with ssh

mkdir /root/.ssh/
echo $ENV_ID_RSA >> /root/.ssh/id_rsa

mkdir $BACKUP_PATH
git clone $ENV_GITREPO $BACKUP_PATH

cron -f
