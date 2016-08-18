#!/bin/sh
# v1.0.0
# 创建data磁盘卷，挂载到/data。从安全方面考虑，未设置成自动获取磁盘名称，需手动输入（如：xvdb）

[ ! $1 ] && exit 1
DISKSIZE=(lsblk | grep $1 | sed -n '1p' | cut -d 'G' -f1 |  awk '{if($4<=200) {print $4-2} else {print $4-5}}')
pvcreate /dev/$1
vgcreate vg_data /dev/$1
lvcreate -n lv_data -L ${DISKSIZE}G vg_data
mkfs.ext4 /dev/mapper/vg_data-lv_data
[ ! -d /data ] && mkdir /data
mount -t ext4 /dev/mapper/vg_data-lv_data /data

echo '/dev/mapper/vg_data-lv_data /data		ext4	defaults	0 0' >> /etc/fstab