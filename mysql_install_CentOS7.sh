#!/bin/sh
#数据库密码
db_password=123456

firewall-cmd --add-port=3306/tcp --permanent
firewall-cmd --add-port=3306/tcp

echo -e "需要从官网下载mysql安装包吗？（y/yes）  \c"
read answer
if [ ! $answer ];then
    echo 用户取消，请继续。
elif [ $answer == yes -o $answer == y ] ; then
    wget https://cdn.mysql.com//Downloads/MySQL-5.7/mysql-5.7.27-linux-glibc2.12-x86_64.tar.gz
else
    echo 用户取消，未下载，请继续。
fi

echo 本脚本需要以root权限运行。
echo 下载mysql-5.7.27-linux-glibc2.12-x86_64.tar.gz放在当前目录下。
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

yum -y install perl numactl*
tar -zxf mysql-5.7.27-linux-glibc2.12-x86_64.tar.gz
mv mysql-5.7.27-linux-glibc2.12-x86_64 /usr/local/mysql
rm -f mysql-5.7.27-linux-glibc2.12-x86_64.tar.gz
mkdir /usr/local/mysql/data
groupadd mysql
useradd -r -s /sbin/nologin -g mysql mysql -d /usr/local/mysql
chown -R mysql:mysql /usr/local/mysql
rm -f /etc/my.cnf
/usr/local/mysql/bin/mysqld --initialize --user=mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data/ 2> mysql.log
temp_db_passwd=`grep localhost mysql.log | sed -e 's/.*localhost: //'`
rm -f mysql.log
/usr/local/mysql/bin/mysql_ssl_rsa_setup --datadir=/usr/local/mysql/data/
echo '[mysqld]
basedir=/usr/local/mysql
datadir=/usr/local/mysql/data
port=3306
server_id=1
socket=/var/lib/mysql/mysql.sock

character_set_server = utf8mb4
collation_server = utf8mb4_unicode_ci
max_heap_table_size = 400M
max_allowed_packet = 16777216
join_buffer_size = 64M
tmp_table_size = 64M
innodb_buffer_pool_size = 2000M
innodb_doublewrite = OFF
innodb_flush_log_at_timeout = 3
innodb_read_io_threads = 32
innodb_write_io_threads = 16

[mysqld_safe]
log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid

[client]
socket=/var/lib/mysql/mysql.sock' > /etc/my.cnf
cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysql
sed -i "/^basedir/s/=.*/=\/usr\/local\/mysql/" /etc/init.d/mysql
sed -i "/^datadir=/s/=.*/=\/usr\/local\/mysql\/data/" /etc/init.d/mysql
chkconfig mysql on
echo 'export MYSQL_HOME="/usr/local/mysql"' >> /etc/profile
echo 'export PATH="$PATH:$MYSQL_HOME/bin"' >> /etc/profile
. /etc/profile
mkdir /var/lib/mysql
chown mysql:mysql /var/lib/mysql
service mysql restart
echo "set password=password('$db_password');
quit" > db_config.sql
/usr/local/mysql/bin/mysql -u root --connect-expired-password -p$temp_db_passwd < db_config.sql
rm -f db_config.sql
reboot
