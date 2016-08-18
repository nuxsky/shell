#!/bin/sh
# v1.0.1
# lsyncd+rsyncd代码同步方案部署，修改监控的文件数量限制为6553500

[ ! $1 ] && exit
[ ! -f /usr/sbin/xinetd ] && yum install xinetd -y
[ ! -f /usr/bin/rsync ] && yum install rsync -y
[ ! -f /usr/bin/lsyncd ] && yum install lua lsyncd -y
[ ! -d /data/logs/sync ] && mkdir -p /data/logs/sync || rm -f /data/logs/sync/*
[ $(cat /proc/sys/fs/inotify/max_user_watches) -eq '8192' ] && echo '6553500' > /proc/sys/fs/inotify/max_user_watches && echo  'fs.inotify.max_user_watches=6553500' >> /etc/sysctl.conf
[ $2 ] && DATA="$2/data" || DATA=$(find /data/www/ -maxdepth 2  -type d -name 'data' | xargs -n1 echo | sed -n '1p' | awk -F 'www/' '{print $2}')
echo $DATA > /etc/rsync_exclude.lst
wget http://cfg.nuxsky.com/sync/lsyncd.conf -O /etc/lsyncd.conf 
wget http://cfg.nuxsky.com/sync/rsyncd.conf -O /etc/rsyncd.conf
sed -i "s,192.168.0.1,$1,g" /etc/{lsyncd,rsyncd}.conf
sed -i 's@yes@no@g' /etc/xinetd.d/rsync

chkconfig xinetd on
chkconfig lsyncd on
/etc/init.d/xinetd restart
/etc/init.d/lsyncd restart