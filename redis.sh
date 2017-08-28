#!/bin/sh
# v1.0.5
# redis安装脚本

[ $1 ] && [ ! $1 = 'wan' ] && [ ! $1 = 'lan' ]&& port=$1 && rdser=_$port || port=6379
rdsinit=/etc/init.d/redis$rdser
logfile=/data/logs/redis/redis$rdser.log
rdsdir=/usr/local/redis
rdsconf=${rdsdir}/conf/$port.conf

case ${!#} in
wan)
	ipaddr=$(ifconfig | grep 'inet ' | grep -v '127.0.0.1' | cut -d':' -f2 | cut -d' ' -f1 | egrep -v '^(10.|172.|192.)')
	;;
lan)
	ipaddr=$(ifconfig | grep 'inet ' | grep -v '127.0.0.1' | cut -d':' -f2 | cut -d' ' -f1 | egrep '^(10.|172.|192.)')
	;;
*)
	ipaddr=127.0.0.1
	;;
esac

if [ ! -d /usr/local/redis ];then
  cd /usr/local/src
  wget http://pkg.nuxsky.com/redis-3.2.10.tar.gz
  tar zxf redis-3.2.10.tar.gz
  mv /usr/local/src/redis-3.2.10 $rdsdir
  cd $rdsdir
  mkdir run conf
  mkdir -p /data/logs/redis
  make
fi

cp -f ${rdsdir}/utils/redis_init_script $rdsinit
sed -i 's@#$@# chkconfig: 2345 88 12@g' $rdsinit
sed -i "s@REDISPORT=6379@REDISPORT=$port@g" $rdsinit
sed -i "s@/usr/local/bin@${rdsdir}/src@g" $rdsinit
sed -i "s@shutdown\$@-h $ipaddr shutdown@g" $rdsinit
sed -i "s@/var/run/redis_@${rdsdir}/run/@g" $rdsinit
sed -i "s@/etc/redis@${rdsdir}/conf@g" $rdsinit
cp -f ${rdsdir}/redis.conf $rdsconf
sed -i 's@daemonize no@daemonize yes@g' $rdsconf
sed -i "s@port 6379@port $port@g" $rdsconf
sed -i "s@pidfile /var/run/redis_6379.pid@pidfile ${rdsdir}/run/${port}.pid@g" $rdsconf
sed -i "s@# bind 127.0.0.1@bind $ipaddr@g" $rdsconf
sed -i "s@logfile \"\"@logfile \"$logfile\"@g"  $rdsconf
sed -i "s@dir ./@dir /data/redis/$port@g"  $rdsconf
mkdir -p /data/redis/$port
chkconfig ${rdsinit##*/} on
$rdsinit start