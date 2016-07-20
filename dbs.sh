#!/bin/bash
# v1.0.3

sclog=/usr/local/src/sysconfig.log
sqlfile=/tmp/sqlfile
echo "mysql:" > $sclog
:> $sqlfile

sqldata() {
    str=`head -c 500 /dev/urandom | tr -dc 0-9a-zA-Z`
    str=${str:0:16}
    echo -e "drop database if exists db_$1;\ncreate database db_$1 default character set utf8;\ngrant all on db_${1}.* to $1@'%' identified by '$str';\nflush privileges;"  >> $sqlfile
    echo "db_$1 $1 $str" >> $sclog
}

if [ $1 ]; then sqldata $1; else
    for dir in `/bin/ls -la /data/www/ | grep "^d" | awk '{print $9}'`
    do
        case $dir in
        ecstore)
            sqldata ecstore
        ;;
        bbc)
            sqldata bbc
        ;;
        oms)
            sqldata oms
        ;;
        crm)
            sqldata crm
        ;;
        esac
    done
fi

/usr/local/mysql/bin/mysql -uroot --password='' < $sqlfile
rm -f $sqlfile