#!/bin/sh

#Author: Danjun.Wang
#E-mail:mjwdj1980@gmail.com

#数据库密码
db_password=123456
zabbix_db_password=123456

firewall-cmd --add-port=80/tcp --permanent
firewall-cmd --add-port=10051/tcp --permanent
firewall-cmd --add-port=80/tcp
firewall-cmd --add-port=10051/tcp

echo -e "您已经安装了mysql安装包吗？（y/yes）  \c"
read answer
if [ ! $answer ];then
    echo 用户取消，请继续。
elif [ $answer == yes -o $answer == y ] ; then
    echo 请继续。
else
    echo 用户取消，未下载，请继续。
fi

echo 本脚本需要以root权限运行，并已经安装好mysql数据库。
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

rpm -Uvh https://repo.zabbix.com/zabbix/4.2/rhel/7/x86_64/zabbix-release-4.2-1.el7.noarch.rpm
yum -y install zabbix-server-mysql zabbix-web-mysql zabbix-agent
echo "create database zabbix character set utf8 collate utf8_bin;
grant all privileges on zabbix.* to zabbix@localhost identified by '$zabbix_db_password';
quit" > zabbix_db_config.sql
/usr/local/mysql/bin/mysql -u root --connect-expired-password -p$db_password < zabbix_db_config.sql
rm -f zabbix_db_config.sql
zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | /usr/local/mysql/bin/mysql -uzabbix --connect-expired-password -p$zabbix_db_password zabbix
sed -i "/^# DBPassword/s/$/$zabbix_db_password/;/^# DBPassword/s/#//" /etc/zabbix/zabbix_server.conf
sed -i '/date.timezone/s/date.timezone.*/date.timezone Asia\/Shanghai/;/date.timezone/s/ #//' /etc/httpd/conf.d/zabbix.conf
systemctl enable zabbix-server zabbix-agent httpd
systemctl restart zabbix-server zabbix-agent httpd
