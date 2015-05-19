FROM ubuntu:latest
MAINTAINER Georges Alkhouri <georges.alkhouri@stud.htwk-leipzig.de>

RUN apt-get update
RUN apt-get install -y git

# Add git identity
RUN git config --global user.email "backup@imn.htwk-leipzig.de"
RUN git config --global user.name "Cron Backup"

# Add crontab file in the cron directory
ADD crontab /etc/cron.d/backup-cron
 
# Give execution rights on the cron job
RUN chmod 0644 /etc/cron.d/backup-cron

# Add backup script which the cron job is going to run
ADD backup.sh /usr/bin/

ADD run.sh /usr/bin/

RUN chmod +x /usr/bin/backup.sh
RUN chmod +x /usr/bin/run.sh

VOLUME "/var/lib/cron-backup-docker"

# Needed to push to git through ssh
VOLUME "/root/.ssh"
 
# Run the command on container startup
CMD /usr/bin/run.sh
