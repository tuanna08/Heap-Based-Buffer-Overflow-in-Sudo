#!/bin/bash
#######################################################
# Update sudo to 1.9.5-3
# For: Ubuntu 16.04, Ubuntu 18.04, Ubuntu 20.04,CentOS 6, CentOS 7 , CentOS 8, Debian 9, Debian 10
# Usage: bash update-sudo.sh
# curl -Los-  | bash
#######################################################
[[ $EUID -ne 0 ]] && echo -e "${RED}Error:${PLAIN} This script must be run as root!" && exit 1


u16_url="https://github.com/sudo-project/sudo/releases/download/SUDO_1_9_5p2/sudo_1.9.5-3_ubu1604_amd64.deb"
u18_url="https://github.com/sudo-project/sudo/releases/download/SUDO_1_9_5p2/sudo_1.9.5-3_ubu1804_amd64.deb"
u20_url="https://github.com/sudo-project/sudo/releases/download/SUDO_1_9_5p2/sudo_1.9.5-3_ubu2004_amd64.deb"
c6_url="--no-check-certificate https://github.com/sudo-project/sudo/releases/download/SUDO_1_9_5p2/sudo-1.9.5-3.el6.x86_64.rpm"
c7_url="https://github.com/sudo-project/sudo/releases/download/SUDO_1_9_5p2/sudo-1.9.5-3.el7.x86_64.rpm"
c8_url="https://github.com/sudo-project/sudo/releases/download/SUDO_1_9_5p2/sudo-1.9.5-3.el8.x86_64.rpm"
deb9_url="https://github.com/sudo-project/sudo/releases/download/SUDO_1_9_5p2/sudo_1.9.5-3_deb9_amd64.deb"
deb10_url="https://github.com/sudo-project/sudo/releases/download/SUDO_1_9_5p2/sudo_1.9.5-3_deb10_amd64.deb"


get_os_name () {
        [ -f /etc/redhat-release ] && awk '{print ($1,$3~/^[0-9]/?$3:$4)}' /etc/redhat-release && return
        [ -f /etc/os-release ] && awk -F'[= "]' '/PRETTY_NAME/{print $3,$4,$5}' /etc/os-release && return
        [ -f /etc/lsb-release ] && awk -F'[="]+' '/DESCRIPTION/{print $2}' /etc/lsb-release && return
}

os_name=`get_os_name`
if [ -f /etc/os-release ] 
then
     os_version=`awk -F= '/^VERSION_CODENAME/{print $2}' /etc/os-release`
fi

# install wget
if  [ ! -e '/usr/bin/wget' ]
then
        echo -e "Please wait..."
        yum clean all > /dev/null 2>&1 && yum install -y epel-release > /dev/null 2>&1 && yum install -y wget > /dev/null 2>&1 || (  apt-get update > /dev/null 2>&1 && apt-get install -y wget > /dev/null 2>&1 )
fi
#
update_debian() {
    echo "----Sudo version truoc khi update----"
    dpkg -l | grep sudo
    echo "---> Updating..."
    wget -q -O "sudo_1.9.5.deb" $url
    dpkg -i sudo_1.9.5.deb
    echo "======================================"
    echo "----Sudo version sau khi update----"
    dpkg -l | grep sudo
    rm -rf sudo_1.9.5.deb
}

update_centos() {
    echo "----Sudo version truoc khi update----"
    rpm -qa | grep sudo
    echo "---> Updating..."
    yum install -y wget
    wget -q -O sudo_1.9.5.rpm $url
    rpm -Uvh sudo_1.9.5.rpm
    echo "======================================"
    echo "----Sudo version sau khi update----"
    rpm -qa | grep sudo
    rm -rf sudo_1.9.5.rpm
}

if [[ $os_name == *"Ubuntu"* ]]; then
    echo "======================================"
    echo $os_name $os_version
    if [[ "$os_version" = "bionic" ]]; then
        url=$u18_url
        update_debian
    elif [[ $os_version = "xenial" ]]; then
        url=$u16_url
        update_debian
    elif [[ $os_version = "focal" ]]; then
        url=$u20_url
        update_debian
    else
        echo "$os_verion khong duoc support"
    fi
elif [[ $os_name == *"CentOS"* ]]; then
    echo "======================================"
    echo $os_name
    if [[ $os_name == *"CentOS 6"* ]]; then
        url=$c6_url
        update_centos
    elif [[ $os_name == *"CentOS 7"* ]]; then
        url=$c7_url
        update_centos
    elif [[ $os_name == *"CentOS 8"* ]]; then
        url=$c8_url
        update_centos
    else
        echo "$os_name $os_version khong duoc support"
    fi
elif [[ $os_name == *"Debian"* ]]; then
    echo "======================================"
    echo $os_name $os_version
    dpkg -l | grep sudo
    echo "======================================"
    if [[ $os_version = "stretch" ]]; then
        url=$deb9_url
        update_debian
    elif [[ $os_version = "buster" ]]; then
        url=$deb10_url
        update_debian
    else
        echo "$os_verion khong duoc support"
    fi
else
   echo "$os_name $os_verion  khong duoc support"
fi
