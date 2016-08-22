#!/bin/sh
# v1.0.1
# logrotate 日志文件分割

[ $1 ] || exit 1
for prg in $@
do
	[ -f /etc/logrotate.d/$prg ] || wget http://cfg.nuxsky.com/logrotate/$prg -O /etc/logrotate.d/$prg
done
