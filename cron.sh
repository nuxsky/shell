#!/bin/bash
# v1.0.3
# 添加网站计划任务

[ $1 ] && site=$@ || site=$(ls /data/www -F | grep '/$' | cut -d'/' -f1)

for dir in $site
do
	case $dir in
	*ecstore|*bbc)
		[ $dir = 'bbc' ] && pvs='54'
		[[ $(crontab -uwww -l) =~ $dir ]] || echo -e "* * * * * /data/www/$dir/script/queue/queue.sh /usr/local/php$pvs/bin/php >/dev/null\n* * * * * /usr/local/php$pvs/bin/php /data/www/$dir/script/crontab/crontab.php >/dev/null" >> /var/spool/cron/www
		;;
	*oms)
		[[ $(crontab -uwww -l) =~ $dir ]] || echo -e "* * * * * /bin/sh /data/www/$dir/app/taskmgr/check.sh\n0 0 * * * /bin/sh /data/www/$dir/app/taskmgr/cleanlogs.sh" >> /var/spool/cron/www
		;;
	*crm)
		[[ $(crontab -uwww -l) =~ $dir ]] || echo -e "* * * * * /bin/bash /data/www/$dir/script/crontab.sh\n0 2 * * * /bin/bash /data/www/$dir/script/crontab_day.sh\n30 * * * * /bin/bash /data/www/$dir/script/crontab_hour.sh\n*/15 * * * * /bin/bash /data/www/$dir/script/crontab_plugin.sh" >> /var/spool/cron/www
		;;
	esac
done