#!/bin/sh
# v1.0.0
# 安装jdk

wget http://dl.nuxsky.com/jdk-8u101-linux-x64.tar.gz
tar zxf jdk-8u101-linux-x64.tar.gz -C /usr/local
rm -f jdk-8u101-linux-x64.tar.gz
echo -e '\nexport JAVA_HOME=/usr/local/jdk1.8.0_101\nexport PATH=$JAVA_HOME/bin:$PATH' >> /etc/profile
. /etc/profile