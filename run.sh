# Add crontab file in the cron directory
mkdir /etc/cron.d/backup-cron
touch /etc/cron.d/backup-cron/crontab

echo "$CRONTAB root /usr/bin/backup.sh >> /var/log/cron.log 2>&1" >> /etc/cron.d/backup-cron/crontab
echo "# An empty line is required at the end of this file for a valid cron file." >> /etc/cron.d/backup-cron/crontab
 
# Give execution rights on the cron job
chmod 0644 /etc/cron.d/backup-cron

# Add git identity
git config --global user.email $GIT_EMAIL
git config --global user.name $GIT_NAME

git clone $GIT_REPO $GIT_REPO_PATH

cron -f
