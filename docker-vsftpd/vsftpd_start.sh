#!/usr/bin/env bash

user_name="padres"
user_pass="padres"

cp /etc/vsftpd.conf /etc/vsftpd.conf.orig

# Preparing Space for Files for anonymous
mkdir -p /var/ftp/pub
chown nobody:nogroup /var/ftp/pub
# 添加测试文件
echo "vsftpd annoymous test file" | tee /var/ftp/pub/test.txt
# 修改配置文件
sed -i 's/anonymous_enable=NO/anonymous_enable=YES/' /etc/vsftpd.conf
sed -i 's/listen_ipv6=YES/listen_ipv6=NO/' /etc/vsfptd.conf
sed -i "s#secure_chroot_dir=/var/run/vsftpd/empty#secure_chroot_dir=/var/ftp#" /etc/vsftpd.conf
tee -a /etc/vsftpd.conf << EOF
# Point users at the directory we created earlier.
anon_root=/var/ftp/
#
# Stop prompting for a password on the command line.
no_anon_password=YES
#
# Show the user and group as ftp:ftp, regardless of the owner.
hide_ids=YES
#
# Limit the range of ports that can be used for passive FTP
pasv_min_port=40000
pasv_max_port=50000

# 对于所添加的用户的设置
write_enable=YES
chroot_local_user=YES
user_sub_token=\$USER
local_root=/home/\$USER/ftp

tcp_wrappers=YES
EOF

# 添加ftp用户
adduser --quiet --disabled-password --shell /bin/bash --home /home/${user_name} --gecos "User" ${user_name}
echo "${user_name}:${user_pass}" | chpasswd

mkdir -p /home/${user_name}/ftp/files
chown nobody:nogroup /home/${user_name}/ftp
chown ${user_name}:${user_name} /home/${user_name}/ftp/files
echo "users' vsftpd test file" | tee /home/${user_name}/ftp/files/test.txt

# 禁止用户shell登陆
chsh -s /usr/sbin/nologin ${user_name}
printf "/usr/sbin/nologin\n" | tee  -a  /etc/shells

# 设置ip白名单
printf "vsftpd: ALL\n\n" | tee -a /etc/hosts.deny
# 第一个是本机，第二个是容器本身
printf "vsftpd: 172.17.0.1\n\n" | tee -a  /etc/hosts.allow

/usr/sbin/vsftpd /etc/vsftpd.conf
