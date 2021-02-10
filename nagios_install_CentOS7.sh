#!/bin/sh
#Password of Database
NAGIOS_PASSWORD=123456

firewall-cmd --add-port=80/tcp --permanent
firewall-cmd --add-port=80/tcp

echo 本脚本需要以root权限运行
echo 确保下面软件包在当前目录下，nrpe-3.2.1.tar.gz，nagios-plugins-2.2.1.tar.gz，nagios-4.4.4.tar.gz
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

yum -y install epel-release httpd php gd gd-devel wget unzip mailx expect gcc glibc glibc-common make 
yum -y install gettext automake autoconf openssl-devel net-snmp net-snmp-utils perl-Net-SNMP perl-CGI

tar -zxf nagios-4.4.4.tar.gz
cd nagios-4.4.4
./configure
make all
useradd nagios
usermod -a -G nagios apache
make install
make install-init
systemctl enable nagios
systemctl enable httpd
make install-commandmode
make install-config
make install-webconf
echo "#!/bin/expect
set timeout 10
spawn htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin
expect \"New password:\"
send \"$NAGIOS_PASSWORD\\r\"
expect \"password:\"
send \"$NAGIOS_PASSWORD\\r\"
interact" > nagios_password
chmod 755 nagios_password
./nagios_password
rm -f nagios_password

cd
tar -zxf nagios-plugins-2.2.1.tar.gz
cd nagios-plugins-2.2.1
./configure
make & make install
sed -i 's/use_authentication=1/use_authentication=0/g' /usr/local/nagios/etc/cgi.cfg
systemctl restart httpd
systemctl restart nagios

