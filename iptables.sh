#!/bin/sh
# v1.0.1
# 获取ssh监听端口，配置防火墙策略

PORT=$(netstat -nlp | grep sshd | sed -n '1p' | cut -d':' -f2 | cut -d ' ' -f1)
[ ! $PORT ] && exit 1

iptables -F
iptables -P INPUT DROP
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p tcp -m multiport --dports 80,$PORT -m state --state NEW -j ACCEPT
iptables -A INPUT -p icmp --icmp-type 8 -m state --state NEW -j ACCEPT
iptables -P OUTPUT ACCEPT
/etc/init.d/iptables save
/etc/init.d/iptables restart