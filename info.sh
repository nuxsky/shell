#!/bin/sh
# v1.0.0
# 查看系统信息

VERSION=$(cat /etc/issue | sed -n '1p')
CPUNUM=$(grep 'processor' /proc/cpuinfo | wc -l)
MEMSIZE=$(free -m | sed -n '2p' | awk '{print int($2/1000+0.5)}')
DISKSIZE=$(lsblk | grep 'db' | sed -n '1p' | awk '{print $4}')
LANIP=$(ifconfig | grep 'inet ' | grep -v '127.0.0.1' | cut -d':' -f2 | cut -d' ' -f1 | egrep '^(10.|172.|192.)')
WANIP=$(ifconfig | grep 'inet ' | grep -v '127.0.0.1' | cut -d':' -f2 | cut -d' ' -f1 | egrep -v '^(10.|172.|192.)')
[ $DISKSIZE ] || DISKSIZE=$(lsblk | grep 'da' | sed -n '1p' | awk '{print $4}')

echo "系统及版本号： $VERSION"
echo "CPU核心数量： ${CPUNUM}核"
echo "内存：${MEMSIZE}GB"
echo "硬盘： $DISKSIZE"
echo "IP: ${WANIP}(外）  ${LANIP}(内）"