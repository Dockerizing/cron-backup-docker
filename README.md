# Cron Backup Docker
This docker container provides a cron job which backups a volume and uploads it to a GitHub repository.

## Usage instructions

The container can be executed through the following command: 

	docker run -d -e GITREPO='<ssh clone url>' -v '<.shh directory>':/root/.ssh -v '<backup directory>':/var/lib/cron-backup-docker

The containers environment variable `GITREPO`  is set through:

	-e GITREPO='<ssh clone url>'
`<ssh clone url>` needs to be a SSH URL like `git@github.com:GeorgesAlkhouri/cron-backup-docker.git`.

To authenticate with the backup GitHub repository the container uses SSH. Therefore the hosts `.ssh` folder
will be injected to `/root/.ssh` in the containers file system through:

	-v '<.shh directory>':/root/.ssh
The hosts `.ssh` folder needs to contain the proper private ssh key and github.com needs to be added to 
the known_hosts file.

Finally the backup repository needs the public ssh key.




