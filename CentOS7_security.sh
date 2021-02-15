#!/bin/sh

#Author: Danjun.Wang
#E-mail:mjwdj1980@gmail.com
#version 1.0.0		2/15/2021

#密码策略，密码长度
password_len=10

#密码策略，密码使用期限（天数）
password_date=30

#允许ssh登录的账号
ssh_user=user_admin

#允许ssh登录的IP地址
ssh_ip=192.168.2.200

#更改ssh端口号
ssh_port=222


echo "如果同意请输入yes或者y, 否则将不做任何改动。"
echo

echo -e "你想要设定高级密码策略么？  \c"
read answer
if [ ! $answer ];then
    echo 用户取消，未作更改。
elif [ $answer == yes -o $answer == y ] ; then
    sed -i "/^PASS_MAX_DAYS/s/PASS_MAX_DAYS.*/PASS_MAX_DAYS    $password_date/" /etc/login.defs
    sed -i "/^PASS_MIN_LEN/s/PASS_MIN_LEN.*/PASS_MIN_LEN    $password_len/" /etc/login.defs
    echo 您的密码长度必须为$password_len位
    echo 您的密码最长可以用$password_date天
    echo
else
    echo 用户取消，未作更改。
    echo
fi

echo -e "你要限制使用su的用户么  \c"
read answer
if [ ! $answer ];then
    echo 用户取消，未作更改。
elif [ $answer == yes -o $answer == y ] ; then
    sed -i "/pam_wheel.so use_uid/s/^#//" /etc/pam.d/su
    useradd -p `openssl passwd -1 -salt '123'  123` $ssh_user
    usermod -G wheel $ssh_user
    echo 现在只有$ssh_user可以成为root，密码为123，请尽快修改密码！
    echo
else
    echo 用户取消，未作更改。
    echo
fi

echo -e "你要限制ssh登录的用户和IP地址吗？  \c"
read answer
if [ ! $answer ];then
    echo 用户取消，未作更改。
elif [ $answer == yes -o $answer == y ] ; then
    echo AllowUsers    $ssh_user@$ssh_ip>> /etc/ssh/sshd_config
    echo 只有用户$ssh_user能且只能由$ssh_ip通过ssh登录！
    echo
else
    echo 用户取消，未作更改。
    echo
fi

echo -e "你要禁止Ctrl+Alt+Delete重启电脑么？  \c"
read answer
if [ ! $answer ];then
    echo 用户取消，未作更改。
elif [ $answer == yes -o $answer == y ] ; then
    rm -f /usr/lib/systemd/system/ctrl-alt-del.target
    init q
    echo 现在Ctrl+Alt+Delete将不能重启计算机！
    echo
else
    echo 用户取消，未作更改。
    echo
fi

ssh_port=222
echo -e "你要更改ssh的端口么？  \c"
read answer
if [ ! $answer ];then
    echo 用户取消，未作更改。
elif [ $answer == yes -o $answer == y ] ; then
    sed -i "s/^#Port 22/Port 222/" /etc/ssh/sshd_config
    echo ssh登录端口被改为$ssh_port！
    echo
else
    echo 用户取消，未作更改。
    echo
fi

echo -e "你要禁止root登录ssh吗？  \c"
read answer
if [ ! $answer ];then
    echo 用户取消，未作更改。
elif [ $answer == yes -o $answer == y ] ; then
    sed -i "s/^#PermitRootLogin yes/PermitRootLogin no/" /etc/ssh/sshd_config
    echo root已经被禁止登录ssh！
    echo
else
    echo 用户取消，未作更改。
    echo
fi

