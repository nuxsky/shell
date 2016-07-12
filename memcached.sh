#!/bin/sh
# v1.0.0

meminit=/etc/init.d/memcached
if [ -n $1 ]; then
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
  ./configure --prefix=/usr/local/memcached --enable-64bit --enable-threads
  make && make install
fi

cp -f scripts/memcached.sysv $meminit
sed -i 's@PORT=11211@PORT=11233@g' $meminit
sed -i 's@USER=nobody@USER=memcached@g' $meminit
sed -i 's@CACHESIZE=64@CACHESIZE=2048@g' $meminit
sed -i "s@OPTIONS=\"\"@OPTIONS=\"-l $ipaddr\"@g' $meminit
chmod 755 $meminit
chkconfig ${meminit##*/} on
$meminit start