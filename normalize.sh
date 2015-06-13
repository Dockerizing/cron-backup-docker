#!/usr/bin/env bash

ttl_file=$1
file_name=${ttl_file%.ttl}
tmp_nt='tmp.nt'

cp prefixes.ttl ${tmp_nt}
rapper -q -i turtle -o ntriples ${ttl_file} | sort -u >> ${tmp_nt}
sed \
    -e 's/"\([0-9]\{4\}\)"^^<http:\/\/www.w3.org\/2001\/XMLSchema#gYear>/"\1-01-01T00:00:00Z"^^<http:\/\/www.w3.org\/2001\/XMLSchema#gYear>/g' \
    -e 's/"\([0-9]\{4\}-[0-9]\{2\}\)"^^<http:\/\/www.w3.org\/2001\/XMLSchema#gYearMonth>/"\1-01T00:00:00Z"^^<http:\/\/www.w3.org\/2001\/XMLSchema#gYearMonth>/g' \
    -e 's/"\([0-9]\{2\}-[0-9]\{2\}\)"^^<http:\/\/www.w3.org\/2001\/XMLSchema#gMonthDay>/"0001-\1T00:00:00Z"^^<http:\/\/www.w3.org\/2001\/XMLSchema#gMonthDay>/g' \
    ${tmp_nt} > ${file_name}.nt
rm ${tmp_nt}
rapper -q -i turtle -o turtle ${file_name}.nt > ${ttl_file}
