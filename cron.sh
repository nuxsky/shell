#!/bin/bash
# v1.0.2

profun() {
	if [ $1 = 'ecstore' ] || [ $1 = 'bbc' ]; then
	echo "* * * * * /usr/local/php$2/bin/php /data/www/$1/script/queue/queue.sh >/dev/null" >> $cronfile
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
	dbpass=`grep $1 sysconfig.log | cut -d' ' -f3`
	echo "/bin/tar zcf /data/backup/data/$1-\$gz /data/www/$1 --exclude=/data/www/$1/data --exclude=/data/www/$1/public" >> $bkupsh
	echo -e "/usr/local/mysql/bin/mysqldump -h 127.0.0.1 -u$1 -p'$dbpass' db_$1 > /data/backup/data/$1-\$File\n" >> $bkupsh
}

[ -d /data/backup ] || mkdir -p /data/backup/data
cronfile=/tmp/cronfile
bkupsh=/data/backup/backup.sh
:> $cronfile
echo -e "#!/bin/bash\nNow=\$(date +\"%d-%m-%Y--%H:%M:%S\")\nFile=backup-\$Now.sql\ngz=backup-\$Now.tar.gz\n" > $bkupsh

for dir in `/bin/ls -la /data/www/ | grep "^d" | awk '{print $9}'`
do
	case $dir in
	ecstore)
		profun ecstore
		bkupsite ecstore
	;;
	bbc)
		profun bbc 54
		bkupsite bbc
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

echo 'find /data/backup/data/ -mtime +10 -type f -exec mv {} /tmp \;' >> $bkupsh
echo '30 03 * * * /bin/sh /data/backup/backup.sh' > ${cronfile}.root
echo '20 */3 * * * /bin/sh /data/backup/shopex-collect-mem.sh' >> ${cronfile}.root
echo "01 00 * * * /bin/sh /data/backup/cut_ngx_log.sh >/dev/null 2>&1" >> ${cronfile}.root
[ -f /data/backup/shopex-collect-mem.sh ] || wget -P /data/backup http://cfg.nuxsky.com/php/shopex-collect-mem.sh
[ -f /data/backup/cut_ngx_log.sh ] || wget -P /data/backup http://cfg.nuxsky.com/nginx/cut_ngx_log.sh

crontab -u www $cronfile
crontab ${cronfile}.root
rm -f $cronfile ${cronfile}.root