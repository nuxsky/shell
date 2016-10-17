#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# VAR ***************************************************************************************
BIZDir='/tmp';
SysName='';
SysBit='';
Cpunum='';
RamTotal='';
RamSwap='';
InstallModel='';
Domain=`ifconfig  | grep 'inet addr:'| egrep -v ":192.168|:172.1[6-9].|:172.2[0-9].|:172.3[0-2].|:10.|:127." | cut -d: -f2 | awk '{ print $1}'`;
MysqlPass='';
StartDate='';
StartDateSecond='';
PHPDisable='';


# Function List *****************************************************************************
function InstallMcrypt()
{
     rpm -ivh http://ftp.wyaopeng.com/package/libmcrypt-2.5.8-9.el6.x86_64.rpm
}

function InstallNginx()
{
     rpm -ivh http://ftp.wyaopeng.com/package/nginx-1.8.0-1.el6.x86_64.rpm
     chkconfig nginx on;
}

function InstallPhp53()
{
     rpm -ivh http://ftp.wyaopeng.com/package/php-5.3.29-1.el6.x86_64.rpm;
     chkconfig php-fpm on;
 }

function InstallPhp54()
{
     rpm -ivh http://ftp.wyaopeng.com/package/php-5.4.45-1.el6.x86_64.rpm;
     chkconfig php-fpm54 on;
}

function InstallPhp56()
{
     rpm -ivh http://ftp.wyaopeng.com/package/php-5.6.19-1.el6.x86_64.rpm;
     chkconfig php-fpm56 on;
}

function CheckSystem()
{
        [ $(id -u) != '0' ] && echo '[Error] Please use root to install Nginx+PHP.' && exit;
        egrep -i "centos" /etc/issue && SysName='centos';
        [ "$SysName" == ''  ] && echo '[Error] Your system is not supported install Nginx+PHP' && exit;

        SysBit='32' && [ `getconf WORD_BIT` == '32' ] && [ `getconf LONG_BIT` == '64' ] && SysBit='64';
        [ "$SysBit" == '32'  ] && echo '[Error] Your system is 32SysBit,need 64SysBit' && exit;

        Cpunum=`cat /proc/cpuinfo | grep 'processor' | wc -l`;
        RamTotal=`free -m | grep 'Mem' | awk '{print $2}'`;
        RamSwap=`free -m | grep 'Swap' | awk '{print $2}'`;
        echo "${SysBit}Bit, ${Cpunum}*CPU, ${RamTotal}MB*RAM, ${RamSwap}MB*Swap";
        physicalNumber=0
        coreNumber=0
        logicalNumber=0
        HTNumber=0
        logicalNumber=$(grep "processor" /proc/cpuinfo|sort -u|wc -l)
        physicalNumber=$(grep "physical id" /proc/cpuinfo|sort -u|wc -l)
        coreNumber=$(grep "cpu cores" /proc/cpuinfo|uniq|awk -F':' '{print $2}'|xargs)
        #HTNumber=$((logicalNumber / (physicalNumber * coreNumber)))
        echo "********************* CPU Information *************"
        echo "Logical CPU Number(逻辑CPU个数)    : ${logicalNumber}"
        echo "Physical CPU Number(物理CPU个数)   : ${physicalNumber}"
        echo "CPU Core Number(每个CPU的核数)     : ${coreNumber}"
        echo "HT Number(超线程)                  : ${HTNumber}"
        echo "***************************************************"
        echo '================================================================';
        
        RamSum=$[$RamTotal+$RamSwap];
        [ "$SysBit" == '32' ] && [ "$RamSum" -lt '250' ] && \
        echo -e "[Error] Not enough memory install LNMP. \n(32bit system need memory: ${RamTotal}MB*RAM + ${RamSwap}MB*Swap > 250MB)" && exit;

        if [ "$SysBit" == '64' ] && [ "$RamSum" -lt '480' ];  then
                echo -e "[Error] Not enough memory install LNMP. \n(64bit system need memory: ${RamTotal}MB*RAM + ${RamSwap}MB*Swap > 480MB)";
                [ "$RamSum" -gt '250' ] && echo "[Notice] Please use 32bit system.";
                exit;
        fi;
        
        [ "$RamSum" -lt '600' ] && PHPDisable='--disable-fileinfo';
}

function InstallBasePackages()
{
  if [ "$SysName" == 'centos' ]; then
    echo '[Bizsov YUM  Installing] **************************************************';
#cat >> /etc/hosts <<EOF
#221.236.12.140 mirrors.sohu.com 
#EOF
rm -rf /etc/yum.repos.d/*
#if [ -f /etc/yum.repos.d/ecos.repo ] ;then
    curl  http://mirrors.shopex.cn/shopex/shopex-lnmp/shopex-lnmp.repo >/etc/yum.repos.d/ecos.repo
#fi;

/bin/cat >> /etc/yum.repos.d/ecos.repo << EOF

[centos]
name=centos-$releasever -mirrors.sohu.com
baseurl=http://mirrors.aliyun.com/centos/\$releasever/os/\$basearch/
gpgkey=http://mirrors.aliyun.com/centos/\$releasever/os/\$basearch/RPM-GPG-KEY-CentOS-\$releasever
gpgcheck=0
enable=1

[centos-update]
name=centos-update -$releasever -mirrors.sohu.com
baseurl=http://mirrors.aliyun.com/centos/\$releasever/updates/\$basearch/
gpgkey=http://mirrors.aliyun.com/centos/\$releasever/updates/\$basearch/RPM-GPG-KEY-CentOS-\$releasever
gpgcheck=0
enable=1

[epel]
name=epel-$releasever - epel
baseurl=http://mirrors.aliyun.com/epel/\$releasever/\$basearch/
gpgkey=http://mirrors.aliyun.com/epel/RPM-GPG-KEY-EPEL-\$releasever
gpgcheck=0
enable=1

[epel-testing]
name=epel-testing-$releasever - epel-testing
baseurl=http://mirrors.aliyun.com/epel/testing/\$releasever/\$basearch/
gpgkey=http://mirrors.aliyun.com/epel/RPM-GPG-KEY-EPEL-\$releasever
gpgcheck=0
enable=1

EOF

# **************************************
                yum clean all;
                yum repolist ;
                echo "*         soft   nofile       65535" >>/etc/security/limits.conf
                echo "*         hard   nofile       65535" >>/etc/security/limits.conf
                for packages in tty wget make vim install gcc gcc-c++ openssl openssl-devel ncurses ncurses-devel autoconf libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel  glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel libidn libidn-devel   openldap openldap-devel nss_ldap openldap-clients openldap-servers pcre pcre-devel  zlib zlib-devel ; do 
                        echo "[${packages} installing] ..... >>";
                        yum -y install $packages; 
                done;

# EOF **********************************
/bin/cat >> /etc/sysctl.conf << EOF
#Customer
net.ipv4.ip_forward = 0  
net.ipv4.conf.default.rp_filter = 1  
net.ipv4.conf.default.accept_source_route = 0  
kernel.sysrq = 0  
kernel.core_uses_pid = 1  
net.ipv4.tcp_syncookies = 1  
kernel.msgmnb = 65536  
kernel.msgmax = 65536  
kernel.shmmax = 68719476736  
kernel.shmall = 4294967296  
net.ipv4.tcp_max_tw_buckets = 6600000  
net.ipv4.tcp_sack = 1  
net.ipv4.tcp_window_scaling = 1  
net.ipv4.tcp_rmem = 4096 87380 4194304  
net.ipv4.tcp_wmem = 4096 16384 4194304  
net.core.wmem_default = 8388608  
net.core.rmem_default = 8388608  
net.core.rmem_max = 16777216  
net.core.wmem_max = 16777216  
net.core.netdev_max_backlog = 262144  
net.core.somaxconn = 262144  
net.ipv4.tcp_max_orphans = 3276800  
net.ipv4.tcp_max_syn_backlog = 262144  
net.ipv4.tcp_timestamps = 0  
net.ipv4.tcp_synack_retries = 1  
net.ipv4.tcp_syn_retries = 1  
net.ipv4.tcp_tw_recycle = 1  
net.ipv4.tcp_tw_reuse = 1  
net.ipv4.tcp_mem = 94500000 915000000 927000000  
net.ipv4.tcp_fin_timeout = 1  
net.ipv4.tcp_keepalive_time = 1200  
net.ipv4.ip_local_port_range = 1024 65535
# Over
EOF
# **************************************

/sbin/sysctl -p


 fi
}

function InstallReady()
{
        mkdir -p $BIZDir/conf;
        mkdir -p $BIZDir/packages/untar;
        chmod 777 $BIZDir/packages;

        mkdir -p $BIZDir/bizlnmp/;

        cd $BIZDir/packages;
}

function Getfile()
{
        randstr=$(date +%s);
        cd $BIZDir/packages;

        if [ -s $1 ]; then
                echo "[OK] $1 found.";
        else
                echo "[Notice] $1 not found, download now......";
                if ! wget -c --tries=3 ${2}?${randstr} ; then
                        echo "[Error] Download Failed : $1, please check $2 ";
                        exit;
                else
                        mv ${1}?${randstr} $1;
                fi;
        fi;
}

function InstallMysql()
{

    rpm -ivh http://ftp.wyaopeng.com/package/mysql-5.6.27-1.el6.x86_64.rpm;
    chkconfig mysqld on;
       
# EOF **********************************
cat > /etc/ld.so.conf.d/mysql.conf<<EOF
/usr/local/mysql/lib/mysql
/usr/local/lib
EOF
# **************************************

}


# Install Function  *********************************************************

# LNMP Installing ****************************************************************************
CheckSystem;
InstallBasePackages;
InstallReady
InstallMcrypt
InstallNginx
InstallPhp53
#InstallPhp54
#InstallPhp56
InstallMysql
