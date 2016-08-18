#!/bin/sh
# v1.0.0
# YUM源更换为国内的阿里云源

[ ! -f /etc/yum.repos.d/CentOS-Base.repo.ori ] && mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.ori
wget http://mirrors.aliyun.com/repo/Centos-6.repo -O /etc/yum.repos.d/CentOS-Base.repo
wget http://mirrors.aliyun.com/repo/epel-6.repo -O /etc/yum.repos.d/epel.repo
yum clean all 
yum makecache