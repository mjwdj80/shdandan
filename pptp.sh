#!/bin/sh

SERVER_IP=192.168.10.41
CLIENT_IPs=192.168.10.191-199
NETWORK=192.168.10.0
NETMASK=24
DNS1=8.8.8.8
DNS2=8.8.4.4

#yum -y install epel-release
#yum -y install pptpd

ETH=`ip add | grep BROADCAST | awk -F: '{print $2}'`

echo "localip $SERVER_IP" >> /etc/pptpd.conf
echo "remoteip $CLIENT_IPs" >> /etc/pptpd.conf

echo "ms-dns $DNS1" >> /etc/pptpd.conf
echo "ms-dns $DNS2" >> /etc/pptpd.conf

TERMINATER=yes
while [ $TERMINATER != "no" ]
do
    echo
    echo -e "Please input the account name:  \c"
    read USER_NMAE
    USER_PASSWORD=`echo $RANDOM`
    echo "$USER_NMAE pptpd $USER_PASSWORD *" >> /etc/ppp/chap-secrets
    echo "new account name:$USER_NMAE , password:$USER_PASSWORD"
    echo -e "add a new account?(input no to terminate):"
    read TERMINATER
done

echo net.ipv4.ip_forward=1 >> /etc/sysctl.conf
sysctl -p
echo 1 >/proc/sys/net/ipv4/ip_forward

firewall-cmd --permanent--add-masquerade

firewall-cmd --permanent --add-port=47/tcp
firewall-cmd --permanent --add-port=1723/tcp

firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -p gre -j ACCEPT
firewall-cmd --permanent --direct --add-rule ipv4 filter OUTPUT 0 -p gre -j ACCEPT

firewall-cmd --permanent --direct --add-rule ipv4 filter FORWARD 0 -i ppp0 -o $ETH -j ACCEPT
firewall-cmd --permanent --direct --add-rule ipv4 filter FORWARD 0 -i $ETH -o ppp0 -j ACCEPT

firewall-cmd --permanent --direct --passthrough ipv4 -t nat -I POSTROUTING -o $ETH -j MASQUERADE -s $NETWORK/$NETMASK

firewall-cmd --reload
systemctl restart pptpd
firewall-cmd --list-all

