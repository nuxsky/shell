#!/bin/sh

yum install -y perl gcc gcc-c++ autoconf automake make sudo wget libxml2-devel libcap-devel libtool-ltdl-devel
cd /usr/local/src
wget http://www.squid-cache.org/Versions/v3/3.5/squid-3.5.26.tar.gz
tar zxf squid-3.5.26.tar.gz
cd squid-3.5.26
useradd -M -s /sbin/nologin squid
./configure --prefix=/usr/local/squid --localstatedir=/data/squid --enable-gnuregex --enable-async-io=240 --enable-icmp --enable-snmp --enable-cache-digests --enable-default-err-language="Simplify_Chinese" --enable-linux-netfiter --enable-delay-pools --with-filedescriptors=65536  --disable-loadable-modules
make && make install
wget http://cfg.nuxsky.com/squid/squid -O /etc/init.d/squid && chmod +x /etc/init.d/squid
wget http://cfg.nuxsky.com/squid/squid.conf -O /usr/local/squid/etc/squid.conf
chown squid.squid -R /data/squid
/usr/local/squid/sbin/squid -z
chkconfig squid on