#!/bin/sh
# v1.0.0

rdsdir=/usr/local/redis

if [ $1 -eq 'kv' ]; then
  port=6380
  rdsinit=/etc/init.d/redis_kv
else if [ $ -eq 'qu' ]; then
  port=6390
  rdsinit=/etc/init.d/redis_qu
  else
    port=6379
	rdsinit=/etc/init.d/redis
  fi
fi

rdsconf=${rdsdir}/conf/${port}.conf

if [ ! -d /usr/local/redis ];then
  cd /usr/local/src
  wget http://pkg.nuxsky.com/redis-3.0.7.tar.gz
  tar zxf redis-3.0.7.tar.gz
  mv /usr/local/src/redis-3.0.7 $rdsdir
  cd $rdsdir
  mkdir run conf
  make
fi



cp ${rdsdir}/utils/redis_init_script $rdsinit
cp ${rdsdir}/redis.conf ${rdsdir}/conf/$port.conf
sed -i "s@#$@# chkconfig: 2345 90 10/g" $rdsinit
sed -i "s@/usr/local/bin@${rdsdir}/src@g" $rdsinit
sed -i "s@/var/run/redis_@${rdsdir}/run/@g" $rdsinit
sed -i "s@/etc/redis@${rdsdir}/conf@g" $rdsinit
sed -i "s@daemonize no@daemonize yes@g" $rdsconf
sed -i "s@pidfile /var/run/redis.pid@pidfile ${rdsdir}/run/${port}.pid@g" $rdsconf
sed -i "s@# bind 127.0.0.1@bind 127.0.0.1@g" $rdsconf
sed -i 's@logfile ""@logfile "/data/logs/redis/redis.log"@g'  $rdsconf

chkconfig ${rdsinit##*/} on
$rdsinit start


