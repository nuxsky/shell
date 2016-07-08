#!/bin/sh
# v1.0.0

if [ $1 -gt 1024 ] && [ $1 -lt 65535 ]; then
/bin/sed -i "s@`grep "Port " /etc/ssh/sshd_config`@Port $1@g" /etc/ssh/sshd_config
/etc/init.d/sshd reload

iptables -F
iptables -P INPUT DROP
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p tcp -m multiport --dports 80,$1 -m state --state NEW -j ACCEPT
iptables -P OUTPUT DROP
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -p udp --dport 53 -m state --state NEW -j ACCEPT
iptables -A OUTPUT -p icmp -m icmp --icmp-type 8 -m state --state NEW -j ACCEPT
/etc/init.d/iptables save
/etc/init.d/iptables restart
fi
