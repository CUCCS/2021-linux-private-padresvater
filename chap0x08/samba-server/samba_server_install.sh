#!/usr/bin/env bash
config_path="./diy_samba.config"

if ! [[  -e  $config_path ]]; then
   echo "Can' find  $config_path file" 
   exit
fi

. ./diy_samba.config
echo "config file loads successfully"

# 安装samba服务器
apt-get update && apt-get install -y samba

status="$(dpkg-query -W --showformat='${db:Status-Status}' "samba" 2>&1)"
if ! "$status" == "installed";then
    echo "Install failed"
    exit
fi


# 创建Samba共享专用的用户
useradd -M -s /sbin/nologin $user_name
groupadd $user_group
usermod -a -G $user_group $user_name
(echo $user_pass;echo $user_pass) |  passwd $user_name
(echo $user_pass;echo $user_pass) |  smbpasswd -a $user_name


# 创建共享目录
mkdir -p $share_path
chown -R $user_name:$user_name $share_path

# 在/etc/samba/smb.conf 文件尾部追加以下“共享目录”配置
if  grep -q $user_name /etc/samba/smb.conf;then
    echo "用户名在配置文件中已经存在"
else 
   tee -a /etc/samba/smb.conf  << EOF
[$user_name]
        path = $share_path
        read only = no
        guest ok = no
        force create mode = 0660
        force directory mode = 2770
        force user = $user_name
        force group = $user_group
# Forced Parameters 可以强制所有连接共享目录的用户创建的文件、目录使用特定的权限位设定、属主用户和属主组（有安全风险）
EOF
fi

systemctl restart smbd.service
