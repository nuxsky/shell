#!/bin/sh
# v1.0.0

if [ ! $1 ]; then exit; fi
rpm -qa | grep xinetd
if [ $? = 1 ]; then yum install -y xinetd; fi
rpm -qa | grep rsync
if [ $? = 1 ]; then yum install -y rsync; fi
rpm -qa | grep lsyncd
if [ $? = 1 ]; then yum install -y lua lsyncd; fi

if [ ! -d /data/logs/sync ]; then mkdir -p /data/logs/sync; else rm -f /data/logs/sync/*; fi
touch /etc/rsync_exclude.lst
echo -e "log file = /data/logs/sync/rsyncd.log\npid file = /data/logs/sync/rsyncd.pid\nlock file = /var/run/rsync.lock\nuse chroot = yes\n[www]\npath = /data/www\nhosts allow = $1\nuid = www\ngid = www\nread only = false" > /etc/rsyncd.conf
echo -e "settings {\n                logfile = \"/data/logs/sync/lsyncd.log\",\n                statusFile = \"/data/logs/sync/lsyncd.stat\",
                statusInterval =1,\n        }\nsync{\n                default.rsync,\n                source=\"/data/www/\",\n                target=\"$1::www\",\n                exclude = { \".*\", \"*.log\" },\n                excludeFrom=\"/etc/rsync_exclude.lst\",\n                init=false,\n        rsync     = {\n                binary = \"/usr/bin/rsync\",\n                archive = true,\n                compress = true,\n                verbose   = true\n                }\n}" > /etc/lsyncd.conf

grep 'inotify' /etc/sysctl.conf
if [ $? = 1 ]; then
echo '65535000' >  /proc/sys/fs/inotify/max_user_watches
echo  'fs.inotify.max_user_watches=65535000' >>  /etc/sysctl.conf
fi
sed -i 's@yes@no@g' /etc/xinetd.d/rsync
chkconfig xinetd on
chkconfig lsyncd on
/etc/init.d/xinetd restart
/etc/init.d/lsyncd restart