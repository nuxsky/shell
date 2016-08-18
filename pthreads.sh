#!/bin/sh
# 安装php-pthreads v1.0.1

[ ! -f /etc/yum.repos.d/shopex-lnmp.repo ] && wget mirrors.shopex.cn/shopex/shopex-lnmp/shopex-lnmp.repo -P /etc/yum.repos.d/ && yum clean metaddata && yum makecache
[ ! -d /usr/local/php-pthreads ] && yum install php-pthreads.x86_64 -y