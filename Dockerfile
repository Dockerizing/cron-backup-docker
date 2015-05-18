FROM ubuntu:latest
MAINTAINER Georges Alkhouri <georges.alkhouri@stud.htwk-leipzig.de>

RUN apt-get update
RUN apt-get install -y git

# Enable authentication with ssh

RUN mkdir /root/.ssh/
ADD id_rsa /root/.ssh/id_rsa

# Create known_hosts
RUN touch /root/.ssh/known_hosts
RUN ssh-keyscan github.com >> /root/.ssh/known_hosts

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
 
# Run the command on container startup
CMD /usr/bin/run.sh
