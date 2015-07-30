#!/usr/bin/env bash

bin="isql-vt"
host="store"
port=1111
user="dba"
password=${STORE_ENV_PWDDBA}

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

echo "[CRON] Getting dump from store"

run_virtuoso_cmd "dump_nquads('$STORE_BACKUP_PATH',1,10000000,0);"

cp -a ${STORE_BACKUP_PATH}/. ${GIT_REPO_PATH}/

echo "[CRON] Committing changes to git repository"

# maybe git add -u
git -C $GIT_REPO_PATH add -A
git -C $GIT_REPO_PATH commit -m "cron backup commit"
git -C $GIT_REPO_PATH push origin master

echo "[CRON] Backup down"
