#!/bin/sh
# v1.0.3
# 网站代码、数据库定时任务备份脚本，备份文件保留10天

bkupsite() {
	[ -f sysconfig.log ] && dbpass=$(grep $1 sysconfig.log | cut -d' ' -f3) || dbpass='123456'
	echo "/bin/tar zcf /data/backup/data/$1-\$gz /data/www/$1 --exclude=/data/www/$1/data" >> $bkupsh
	echo -e "/usr/local/mysql/bin/mysqldump -h $dbaddr -u$1 -p'$dbpass' db_$1 > /data/backup/data/$1-\$File\n" >> $bkupsh
}

[ -d /data/backup ] || mkdir -p /data/backup/data
[ ! -f /usr/local/mysql/bin/mysqldump ] && mkdir -p /usr/local/mysql/bin && wget http://dl.nuxsky.com/mysqldump -O /usr/local/mysql/bin/mysqldump && chmod u+x /usr/local/mysql/bin/mysqldump
[ $1 ] && [[ ${!#} =~ '.' ]] && dbaddr=$1 || dbaddr='127.0.0.1'
[ $1 ] && [[ ! $1 =~ '.' ]] && site=$@ || site=$(ls /data/www -F | grep '/$' | cut -d'/' -f1)
bkupsh=/data/backup/backup.sh
echo -e "#!/bin/bash\nNow=\$(date +\"%d-%m-%Y--%H:%M:%S\")\nFile=backup-\$Now.sql\ngz=backup-\$Now.tar.gz\n" > $bkupsh

for dir in $site
do
	[ -d /data/www/$dir ] && [ ! $dir = 'xxx' ] && [ ! $dir = 'zl' ] && bkupsite $dir
done

echo 'find /data/backup/data/ -mtime +10 -type f -exec rm -f {} \;' >> $bkupsh
[[ $(crontab -l) =~ 'backup.sh' ]] || echo '30 03 * * * /bin/sh /data/backup/backup.sh' >> /var/spool/cron/root