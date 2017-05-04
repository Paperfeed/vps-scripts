#!/usr/bin/env bash

# wget --no-check-certificate -O ss-kcptun.sh https://raw.githubusercontent.com/Paperfeed/vps-scripts/master/ss-kcptun.sh && chmod +x ss-kcptun.sh && ./ss-kcptun.sh

check_sys(){
    local checkType=$1
    local value=$2

    local release=''
    local systemPackage=''

    if [[ -f /etc/redhat-release ]]; then
        release="centos"
        systemPackage="yum"
    elif cat /etc/issue | grep -Eqi "debian"; then
        release="debian"
        systemPackage="apt"
    elif cat /etc/issue | grep -Eqi "ubuntu"; then
        release="ubuntu"
        systemPackage="apt"
    elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
        release="centos"
        systemPackage="yum"
    elif cat /proc/version | grep -Eqi "debian"; then
        release="debian"
        systemPackage="apt"
    elif cat /proc/version | grep -Eqi "ubuntu"; then
        release="ubuntu"
        systemPackage="apt"
    elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
        release="centos"
        systemPackage="yum"
    fi

    if [[ ${checkType} == "sysRelease" ]]; then
        if [ "$value" == "$release" ]; then
            return 0
        else
            return 1
        fi
    elif [[ ${checkType} == "packageManager" ]]; then
        if [ "$value" == "$systemPackage" ]; then
            return 0
        else
            return 1
        fi
    fi
}

if [ yum list installed expect >/dev/null 2>&1] || [ $(dpkg-query -W -f='${Status}' expect 2>/dev/null | grep -c "ok installed") -eq 0 ];  then
    echo "Expect already installed, skipping installation"
else
    echo "Installing Expect"
    if [ $systemPackage == "yum" ]; then
        yum install expect
    else 
       apt install expect
    fi
fi
echo "Please input a password for your SS-KCPTUN setup"
read -p "Password: " PWD

# Get ShadowSocks & KCPTUN Installation Script
if [ ! -e "./shadowsocks-go.sh" ]; then
    wget --no-check-certificate -O shadowsocks-go.sh https://raw.githubusercontent.com/teddysun/shadowsocks_install/master/shadowsocks-go.sh
    wget --no-check-certificate https://github.com/kuoruan/shell-scripts/raw/master/kcptun/kcptun.sh
    chmod +x shadowsocks-go.sh
    chmod +x ./kcptun.sh
fi 



# Expect
/usr/bin/expect <<EOD
spawn ./shadowsocks-go.sh 2>&1 | tee shadowsocks-go.log
expect "(Default password: teddysun.com):"
send "$PWD\n"
expect "(Default port: 8989):"
send "\n"
expect eof
echo "you're out"

# Expect 
#/usr/bin/expect <<EOD
spawn ./kcptun.sh 2>&1 | tee kcptun.log
expect "(默认: ${listen_port}): "
send "\n" 
expect "(默认: ${target_addr}): "
send "\n"
expect "(默认: ${target_port}): "
send "\n"
expect "当前没有软件使用此端口, 确定加速此端口? [y/n]: "
send "\n"
expect "(默认密码: ${key}): "
send "\n"
expect "(默认: ${crypt}) 请选择 [1~$i]: "
send "\n"
expect "(默认: ${mode}) 请选择 [1~$i]: "
send "\n"
expect "(默认: ${mtu}): "
send "\n"
expect "(数据包数量, 默认: ${sndwnd}): "
send "\n"
expect "(数据包数量, 默认: ${rcvwnd}): "
send "\n"
expect "(默认: ${datashard}): "
send "\n"
expect "(默认: ${parityshard}): "
send "\n"
expect "(默认: ${dscp}): "
send "\n"
expect "(默认: ${nocomp}) [y/n]: "
send "\n"
expect "(默认: 否) [y/n]: "
send "\n"
expect "(默认: ${pprof}) [y/n]: "
send "\n"
expect eof
echo "Peace Out"
