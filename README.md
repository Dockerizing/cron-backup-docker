# Cron Backup Docker

This docker container provides a backup cron job for a linked Virtuoso Triple Store.

## Usage instructions

The container can be executed through the following example command:

	docker run -d --link '<virtuoso container name>':virtuoso -e GIT_REPO='<ssh clone url>' -e GIT_EMAIL='<git email>' -e GIT_NAME='<git name>' -v '<.shh directory>':/root/.ssh '<docker image name>'

The container provides the following environment variables which could be set through the `-e` parameter:

* GIT_REPO needs to be a SSH URL like `git@github.com:GeorgesAlkhouri/cron-backup-docker.git`
* GIT_EMAIL needs to be set
* GIT_NAME needs to be set
* CRONTAB by default this is set to a midnight build `(0 0 * * *)`

To authenticate with the backup GitHub repository the container uses SSH. Therefore the hosts `.ssh` folder
will be injected to `/root/.ssh` in the containers file system through:

	-v '<.shh directory>':/root/.ssh
The hosts `.ssh` folder needs to contain the proper private ssh key and github.com needs to be added to 
the known_hosts file.

Finally the backup repository needs the public ssh key.




