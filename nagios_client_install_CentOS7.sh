#!/bin/sh

firewall-cmd --add-port=5666/tcp --permanent
firewall-cmd --add-port=5666/tcp

echo 本脚本需要以root权限运行
echo 确保下面软件包在当前目录下，nrpe-3.2.1.tar.gz，nagios-plugins-2.2.1.tar.gz
echo 运行脚本需要连接互联网下载依赖的软件包
echo
echo -e "您已经完成上面的所有条件了吗？（y/yes）  \c"
read answer
if [ ! $answer ];then
    echo 用户取消，未作更改。
    exit 1
elif [ $answer == yes -o $answer == y ] ; then
    echo
else
    echo 用户取消，未作更改。
    exit 1
fi

echo -e "您确认要开始安装么？（y/yes）  \c"
read answer
if [ ! $answer ];then
    echo 用户取消，未作更改。
    exit 1
elif [ $answer == yes -o $answer == y ] ; then
    echo
else
    echo 用户取消，未作更改。
    exit 1
fi

echo -e "请输入naigos服务器地址  \c"
read nagios_svr1
echo -e "请再输入一次  \c"
read nagios_svr2

while [ $nagios_svr1 != $nagios_svr2 ]
do
    echo -e "您的输入不正确，请重新输入naigos服务器地址  \c"
    read nagios_svr1
    echo -e "请再输入一次  \c"
    read nagios_svr2
done

yum -y install httpd php gd gd-devel wget unzip
yum -y install gcc glibc glibc-common make gettext automake autoconf 
yum -y install openssl-devel net-snmp net-snmp-utils perl-Net-SNMP perl-CGI
useradd -s /sbin/nologin nagios
usermod -a -G nagios apache
tar -zxf nagios-plugins-2.2.1.tar.gz
cd nagios-plugins-2.2.1
./configure
make & make install

cd
tar -zxf nrpe-3.2.1.tar.gz
cd nrpe-3.2.1/
./configure --enable-command-args
make all
make install
make install-plugin
make install-config
make install-inetd
echo >> /etc/services
echo '# Nagios services' >> /etc/services
echo 'nrpe    5666/tcp' >> /etc/services
make install-init
sed -i "/^allowed_hosts/s/$/,$nagios_svr2/" /usr/local/nagios/etc/nrpe.cfg
systemctl restart nrpe
