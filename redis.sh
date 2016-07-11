#!/bin/sh
# v1.0.1

case $1 in
kv)
  port=6380
  rdsinit=/etc/init.d/redis_kv
  ipaddr=`ifconfig | egrep 'inet addr:192|inet addr:10.|inet addr:172.' | head -1 | cut -d: -f2 | cut -d' ' -f1`
  ;;
qu)
  port=6390
  rdsinit=/etc/init.d/redis_qu
  ipaddr=`ifconfig | egrep 'inet addr:192|inet addr:10.|inet addr:172.' | head -1 | cut -d: -f2 | cut -d' ' -f1`
  ;;
*)
  port=6379
  rdsinit=/etc/init.d/redis
  ipaddr=127.0.0.1
  ;;
esac
rdsdir=/usr/local/redis
rdsconf=${rdsdir}/conf/${port}.conf

if [ ! -d /usr/local/redis ];then
  cd /usr/local/src
  wget http://pkg.nuxsky.com/redis-3.0.7.tar.gz
  tar zxf redis-3.0.7.tar.gz
  mv /usr/local/src/redis-3.0.7 $rdsdir
  cd $rdsdir
  mkdir run conf
  mkdir -p /data/logs/redis
  make
fi

cp -f ${rdsdir}/utils/redis_init_script $rdsinit
cp -f ${rdsdir}/redis.conf ${rdsdir}/conf/$port.conf
sed -i 's@#$@# chkconfig: 2345 90 10@g' $rdsinit
sed -i "s@REDISPORT=6379@REDISPORT=$port@g" $rdsinit
sed -i "s@/usr/local/bin@${rdsdir}/src@g" $rdsinit
sed -i "s@/var/run/redis_@${rdsdir}/run/@g" $rdsinit
sed -i "s@/etc/redis@${rdsdir}/conf@g" $rdsinit
sed -i 's@daemonize no@daemonize yes@g' $rdsconf
sed -i "s@port 6379@port $port@g" $rdsconf
sed -i "s@pidfile /var/run/redis.pid@pidfile ${rdsdir}/run/${port}.pid@g" $rdsconf
sed -i "s@# bind 127.0.0.1@bind $ipaddr@g" $rdsconf
sed -i 's@logfile ""@logfile "/data/logs/redis/redis.log"@g'  $rdsconf
chkconfig ${rdsinit##*/} on
$rdsinit start