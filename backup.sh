#!/usr/bin/env bash

bin="isql-vt"
host="store"
port=1111
user="dba"
password=${STORE_ENV_PWDDBA}
cmd="${bin} ${host}:${port} ${user} ${password}"

### Needs adjustment BEGIN

cd $BACKUP_PATH

exec 3<&0

for graph_file in *.graph;
do
    exec 0< ${graph_file}
    read graph
    echo ${graph}
    ${cmd} exec="dump_one_graph ('${graph}', '/tmp/graphdump_');"
    cp /tmp/graphdump_000001.ttl ${graph_file%.graph}
    echo ${graph_file%.graph}
    ./normalize.sh ${graph_file%.graph}
done

exec 0<&3

### Needs adjustment END

cd $GIT_REPO_PATH

echo "commit changes ..."

# maybe git add -u
git add -A
git commit -m "cron backup commit"
git push origin master