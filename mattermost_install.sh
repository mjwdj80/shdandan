#!/bin/sh

DB_IP=192.168.10.31
SERVER_IP=192.168.10.41
DB_PASSWORD=!qaz2wsx
DB_USER=mmuser
DB_ROOT_PASSWORD=123456
DB_NAME=mattermost

dnf -y install mariadb

echo "drop database $DB_NAME;
drop user $DB_USER@'%';
create user $DB_USER@'%' identified by '$DB_PASSWORD';
create database $DB_NAME;
grant all privileges on $DB_NAME.* to '$DB_USER'@'%';
quit" > db.sql

mysql -h $DB_IP -u root -p$DB_ROOT_PASSWORD < db.sql
rm -f db.sql

wget -c http://192.168.10.31/download/mattermost-5.32.1-linux-amd64.tar.gz
#wget -c https://releases.mattermost.com/5.32.1/mattermost-5.32.1-linux-amd64.tar.gz
tar -zxf mattermost-5.32.1-linux-amd64.tar.gz
mv mattermost /opt/
mkdir /opt/mattermost/data
useradd --system --user-group mattermost
chown -R mattermost:mattermost /opt/mattermost
chmod -R g+w /opt/mattermost
sed -i "/SiteURL/s/\"\"/\"http:\/\/$SERVER_IP\"/" /opt/mattermost/config/config.json
sed -i "/DriverName/s/postgres/mysql/" /opt/mattermost/config/config.json
sed -i "/\"DataSource\"/s/\"postgres.*\"/\"$DB_USER:$DB_PASSWORD@tcp\($DB_IP:3306\)\/mattermost?charset=utf8mb4,utf8\\\\u0026readTimeout=30s\\\\u0026writeTimeout=30s\"/" /opt/mattermost/config/config.json
firewall-cmd --add-port=8065/tcp --permanent
firewall-cmd --reload
#sudo -u mattermost /opt/mattermost/bin/mattermost &

#configure the service
echo '[Unit]
Description=Mattermost
After=syslog.target network.target

[Service]
Type=notify
WorkingDirectory=/opt/mattermost
User=mattermost
ExecStart=/opt/mattermost/bin/mattermost
PIDFile=/var/spool/mattermost/pid/master.pid
TimeoutStartSec=3600
LimitNOFILE=49152

[Install]
WantedBy=multi-user.target' > /etc/systemd/system/mattermost.service

chmod 664 /etc/systemd/system/mattermost.service
systemctl daemon-reload
systemctl enable mattermost
systemctl start mattermost
