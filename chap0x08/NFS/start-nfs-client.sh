#!/usr/bin/env bash
. ./nfs.config
apt-get update
apt install -y nfs-common || echo "apt install failed"

adduser --quiet --disabled-password --shell /bin/bash --home /home/${user_name} --gecos "User" ${user_name}
echo "${user_name}:${user_pass}" | chpasswd
mkdir -p /nfs/general
mkdir -p /nfs/home

mount ${server_ip}:/var/nfs/general /nfs/general
mount ${server_ip}:/home /nfs/home
