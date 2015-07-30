#!/usr/bin/env bash

bin="isql-vt"
host="store"
port=1111
user="dba"
password=${STORE_ENV_PWDDBA}

test_connection () {
    if [[ -z $1 ]]; then
        echo "[ERROR] missing argument: retry attempts"
        exit 1
    fi

    t=$1

    run_virtuoso_cmd 'status();'
    while [[ $? -ne 0 ]] ;
    do
        echo -n "."
        sleep 1
        echo $t
        let "t=$t-1"
        if [ $t -eq 0 ]
        then
            echo "timeout"
            return 2
        fi
        run_virtuoso_cmd 'status();'
    done
}

run_virtuoso_cmd () {
  VIRT_OUTPUT=`echo "$1" | "$bin" -H "$host" -S "$port" -U "$user" -P "$password" 2>&1`
  VIRT_RETCODE=$?
  if [[ $VIRT_RETCODE -eq 0 ]]; then
    echo "$VIRT_OUTPUT" | tail -n+5 | perl -pe 's|^SQL> ||g'
    return 0
  else
    echo -e "[ERROR] running the these commands in virtuoso:\n$1\nerror code: $VIRT_RETCODE\noutput:"
    echo "$VIRT_OUTPUT"
    let 'ret = VIRT_RETCODE + 128'
    return $ret
  fi
}

#TODO: ssh-add specific key
eval $(ssh-agent)

echo "[INFO] setting git up"

git config --global user.email $GIT_EMAIL
git config --global user.name $GIT_NAME

git clone $GIT_REPO $GIT_REPO_PATH

echo "[INFO] waiting for store to come online"

: ${CONNECTION_ATTEMPTS:=10}
test_connection "${CONNECTION_ATTEMPTS}"

if [ $? -eq 2 ]; then
    echo "[ERROR] store not reachable"
    exit 1
fi

echo "[INFO] create procedure dump_nquads"

#See http://virtuoso.openlinksw.com/dataspace/doc/dav/wiki/Main/VirtRDFDumpNQuad
run_virtuoso_cmd "CREATE PROCEDURE dump_nquads ( IN dir VARCHAR := 'dumps' , IN start_from INT := 1 , IN file_length_limit INTEGER := 100000000 , IN comp INT := 1 ) { DECLARE inx, ses_len INT ; DECLARE file_name VARCHAR ; DECLARE env, ses ANY ; inx := start_from; SET isolation = 'uncommitted'; env := vector (0,0,0); ses := string_output (10000000); FOR (SELECT * FROM (sparql define input:storage \"\" SELECT ?s ?p ?o ?g { GRAPH ?g { ?s ?p ?o } . FILTER ( ?g != virtrdf: ) } ) AS sub OPTION (loop)) DO { DECLARE EXIT HANDLER FOR SQLSTATE '22023' { GOTO next; }; http_nquad (env, \"s\", \"p\", \"o\", \"g\", ses); ses_len := LENGTH (ses); IF (ses_len >= file_length_limit) { file_name := sprintf ('%s/output%06d.nq', dir, inx); string_to_file (file_name, ses, -2); IF (comp) { gz_compress_file (file_name, file_name||'.gz'); file_delete (file_name); } inx := inx + 1; env := vector (0,0,0); ses := string_output (10000000); } next:; } IF (length (ses)) { file_name := sprintf ('%s/output%06d.nq', dir, inx); string_to_file (file_name, ses, -2); IF (comp) { gz_compress_file (file_name, file_name||'.gz'); file_delete (file_name); } inx := inx + 1; env := vector (0,0,0); } } ;"

echo "[INFO] create crontab and start cron"

touch /etc/cron.d/backup-cron
touch /var/log/cron.log

#Need to set env variables new for cron
echo "STORE_BACKUP_PATH=$STORE_BACKUP_PATH" >> /etc/cron.d/backup-cron
echo "STORE_ENV_PWDDBA=$STORE_ENV_PWDDBA" >> /etc/cron.d/backup-cron
echo "STORE_BACKUP_PATH=$STORE_BACKUP_PATH" >> /etc/cron.d/backup-cron
echo "GIT_REPO_PATH"=$GIT_REPO_PATH >> /etc/cron.d/backup-cron
echo "$CRONTAB root . $HOME/.profile; /usr/bin/backup.sh >> /var/log/cron.log 2>&1" >> /etc/cron.d/backup-cron
echo "# An empty line is required at the end of this file for a valid cron file." >> /etc/cron.d/backup-cron

# Give execution rights on the cron job
chmod 0644 /etc/cron.d/backup-cron

cron && tail -f /var/log/cron.log
