#!/bin/bash
# v1.0.4
# 创建数据库

sqlfile=/tmp/sqlfile
sclog=/usr/local/src/sysconfig.log
[ $1 ] && site=$@ || site=$(ls /data/www -F | grep '/$' | cut -d'/' -f1)
echo "mysql:" > $sclog
:> $sqlfile

sqldata() {
    str=$(head -c 500 /dev/urandom | tr -dc 0-9a-zA-Z)
    echo -e "drop database if exists db_$1;\ncreate database db_$1 default character set utf8;\ngrant all on db_${1}.* to $1@'%' identified by '${str:0:16}';\nflush privileges;"  >> $sqlfile
    echo "db_$1 $1 ${str:0:16}" >> $sclog
}

for dir in $site
do
	sqldata $dir
done

/usr/local/mysql/bin/mysql -uroot --password='' < $sqlfile
rm -f $sqlfile