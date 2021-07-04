#!/usr/bin/env bash
config_path="./dhcp.config"

if ! [[  -e  $config_path ]]; then
   echo "Can' find  $config_path config file" 
   exit
fi
. ./dhcp.config

# 配置静态ip
if ! [[ -e ./00-installer-config.yaml ]];then
    echo "静态ip配置文件缺失"
    exit
fi
cp /etc/netplan/00-installer-config.yaml /etc/netplan/00-installer-config.yaml.bak
cp ./00-installer-config.yaml /etc/netplan/00-installer-config.yaml
netplan apply

apt-get update && apt-get install -y isc-dhcp-server
status="$(dpkg-query -W --showformat='${db:Status-Status}' "isc-dhcp-server" 2>&1)"
if [ ! $?=0 ] || [ ! "$status" = installed ];then
    echo "Install failed"
    exit
fi

sed -i "s/INTERFACESv4=\"\"/INTERFACESv4=$interfaces/" /etc/default/isc-dhcp-server

sed -i "s/default-lease-time 600/default-lease-time $default_lease_time/" /etc/dhcp/dhcpd.conf
sed -i "s/max-lease-time 7200/max-lease-time $max_lease_time/" /etc/dhcp/dhcpd.conf
sed -i "s/#authoritative/authoritative/" /etc/dhcp/dhcpd.conf

if  grep -q "subnet $subnet netmask $mask {" /etc/dhcp/dhcpd.conf;then
    echo "subnet config exist"
    exit
fi
tee -a /etc/dhcp/dhcpd.conf << EOF
subnet $subnet netmask $mask {
    range $ip_min $ip_max;
    option subnet-mask $mask;
    option broadcast-address $broadcast_address;
}
EOF
service isc-dhcp-server restart
echo "DHCP config finish!"
