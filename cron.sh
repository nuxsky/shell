#!/bin/bash
# v1.0.0

profun() {
	if [ $1 = 'ecstore' ] || [ $1 = 'bbc' ]; then
	echo "* * * * * /data/www/$1/script/queue/queue.sh /usr/local/php$2/bin/php >/dev/null" >> $cronfile
	echo "* * * * * /usr/local/php$2/bin/php /data/www/$1/script/crontab/crontab.php >/dev/null" >> $cronfile
	fi
	if [ $1 = 'oms' ]; then
	echo "* * * * * /bin/sh /data/www/$1/app/taskmgr/check.sh" >> $cronfile
	echo "0 0 * * * /bin/sh /data/www/$1/app/taskmgr/cleanlogs.sh" >> $cronfile
	fi
	if [ $1 = 'crm' ]; then
	echo "* * * * * /bin/bash /data/www/$1/script/crontab.sh" >> $cronfile
	echo "0 2 * * * /bin/bash /data/www/$1/script/crontab_day.sh" >> $cronfile
	echo "30 * * * * /bin/bash /data/www/$1/script/crontab_hour.sh" >> $cronfile
	echo "*/15 * * * * /bin/bash /data/www/$1/script/crontab_plugin.sh" >> $cronfile
	fi
	
}
bkupsite() {
	echo "/bin/tar zcf /data/backup/data/$1-"'$gz'" /data/www/$1 --exclude=/data/www/$1/data --exclude=/data/www/$1/public" >> $bkupsh
	echo "/usr/local/mysql/bin/mysqldump -h 127.0.0.1 -u$1 -p'123456' db_$1 > /data/backup/data/$1-"'$File' >> $bkupsh
	echo  "" >> $bkupsh
}

if [ ! -d /data/backup ]; then
	mkdir -p /data/backup/data
fi

cronfile=/tmp/cronfile
bkupsh=/data/backup/backup.sh
scmsh=/data/backup/shopex-collect-mem.sh
:> $cronfile
echo -e '#!/bin/bash\nNow=$(date +"%d-%m-%Y--%H:%M:%S")\nFile=backup-$Now.sql\ngz=backup-$Now.tar.gz\n' > $bkupsh

for dir in `/bin/ls -la /data/www/ | grep "^d" | awk '{print $9}'`
do
	case $dir in
	ecstore)
		profun ecstore
		bkupsite ecstore
	;;
	bbc)
		profun bbc 54
		bkupsite bbs
	;;
	oms)
		profun oms
		bkupsite oms
	;;
	crm)
		profun	crm
		bkupsite crm
	;;
	esac
done

echo 'find /data/backup/data/ -mtime +10 -exec rm -f {} \;' >> $bkupsh
echo -e '#/bin/bash\n##回收php-fpm内存\n###made by shopex.cn\nKILLPID=$(ps aux|grep "php-fpm: pool"|grep -v grep |awk '"'{if(\$4>=1)print \$2}'"')\nDATE=$(date +%F-%T)\necho $KILLPID\nfor PIDS in $KILLPID\ndo\necho $DATE  $PIDS >>/tmp/killpid.logs\nkill -15 $PIDS\ndone' > $scmsh
echo '30 3 * * * sh /data/backup/backup.sh' > ${cronfile}.root
echo '20 */3 * * * sh /data/backup/shopex-collect-mem.sh' >> ${cronfile}.root

crontab -u www $cronfile
crontab ${cronfile}.root
rm -rf $cronfile ${cronfile}.root
