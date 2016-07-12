#!/bin/sh
# v1.0.1

meminit=/etc/init.d/memcached
memdir=/usr/local/memcached
if [ ! $1 ]; then
  ipaddr=127.0.0.1
else
  ipaddr=`ifconfig | egrep 'inet addr:192|inet addr:10.|inet addr:172.' | head -1 | cut -d: -f2 | cut -d' ' -f1`
fi

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

cp -f $memdir/scripts/memcached.sysv $meminit
sed -i 's@PORT=11211@PORT=11233@g' $meminit
sed -i 's@USER=nobody@USER=memcached@g' $meminit
sed -i 's@CACHESIZE=64@CACHESIZE=2048@g' $meminit
sed -i "s@OPTIONS=\"\"@OPTIONS=\"-l $ipaddr\"@g" $meminit
sed -i "s@daemon memcached@daemon $memdir/bin/memcached@g" $meminit
sed -i 's@chown@# chown@g' $meminit
sed -i "s@/var/run/memcached/@$memdir/run/@g" $meminit
sed -i "s@/var/run/memcached.pid@$memdir/run/memcached.pid@g" $meminit
chmod 755 $meminit
chkconfig ${meminit##*/} on
$meminit start