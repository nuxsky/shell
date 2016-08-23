#!/bin/sh
# v1.0.3
# memcached安装脚本

meminit=/etc/init.d/memcached
memdir=/usr/local/memcached

case $1 in
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

if [ ! -d /usr/local/memcached ]; then
  groupadd memcached
  useradd -g memcached -s /bin/fase memcached
  yum install libevent-devel -y
  cd /usr/local/src
  wget http://pkg.nuxsky.com/memcached-1.4.25.tar.gz
  tar zxf memcached-1.4.25.tar.gz
  cd memcached-1.4.25
  ./configure --prefix=$memdir --enable-64bit --enable-threads
  make && make install
  mkdir $memdir/run
fi

cp -f /usr/local/src/memcached-1.4.25/scripts/memcached.sysv $meminit
sed -i 's@PORT=11211@PORT=11233@g' $meminit
sed -i 's@USER=nobody@USER=memcached@g' $meminit
sed -i 's@CACHESIZE=64@CACHESIZE=1024@g' $meminit
sed -i "s@OPTIONS=\"\"@OPTIONS=\"-l $ipaddr\"@g" $meminit
sed -i "s@daemon memcached@daemon $memdir/bin/memcached@g" $meminit
sed -i 's@chown@# chown@g' $meminit
sed -i "s@/var/run/memcached/@$memdir/run/@g" $meminit
sed -i "s@/var/run/memcached.pid@$memdir/run/memcached.pid@g" $meminit
chmod 755 $meminit
chkconfig ${meminit##*/} on
$meminit start