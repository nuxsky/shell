#!/bin/sh
# v1.0.0

yum install vsftpd -y
sed -i 's/root/#root/g' /etc/vsftpd/ftpusers
sed -i 's/root/#root/g' /etc/vsftpd/user_list
sed -i 's/#chroot_list_/chroot_list_/g' /etc/vsftpd/vsftpd.conf
echo 'local_root=/data/ftp' >> /etc/vsftpd/vsftpd.conf
echo 'vftp' > /etc/vsftpd/chroot_list
mkdir /data/ftp
useradd -d /data/ftp -s /sbin/nologin -g ftp vftp
echo 'qwe123$%^' | passwd --stdin vftp
chown vftp.ftp -R /data/ftp
chkconfig vsftpd on
/etc/init.d/vsftpd start