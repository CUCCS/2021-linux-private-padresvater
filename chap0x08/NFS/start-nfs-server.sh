#!/usr/bin/env bash
. ./nfs.config
apt-get update 
apt-get install -y nfs-kernel-server ||  echo "install nfs-kernel server failed"

adduser --quiet --disabled-password --shell /bin/bash --home /home/${user_name} --gecos "User" ${user_name} \
    && echo "${user_name}:${user_pass}" | chpasswd
    
# 第一个目录只读权限挂载
dir="/var/nfs/general"
mkdir -p ${dir}
chown nobody:nogroup ${dir}
echo "${dir}  *(rw,sync,no_subtree_check)" >> /etc/exports
# 第二个目录用户可修改权限挂载
echo "/home    *(rw,sync,no_subtree_check,no_subtree_check)" >> /etc/exports
exportfs -ra
service nfs-kernel-server start
