# (第八章实验)FTP、NFS、DHCP、DNS、Samba服务器的自动安装与自动配置（docker）

## 实验环境

Ubuntu 20.04

## FTP配置

选用vsftpd，轻量且安全，能提供匿名登陆的功能

## docker vsftpd 搭建

### 安装docker

*警告：切勿在没有配置 Docker APT 源的情况下直接使用 apt 命令安装 Docker.*

```
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io
```

在`docker_vsftpd`文件目录下执行：

```bash
docker build -t vsftpd:v1 .
```

### 运行容器

```
docker run -p 21:21 vsftpd:v1
```

### 查看容器ip地址

```bash
docker inspect --format '{{ .NetworkSettings.IPAddress }}' <container-ID>
```

### 在Host上连接配置的docker ftp

```bash
ftp -p <container-ip>
```

## 测试ftp登陆

用户名密码均为padres

```bash
cuc@clone-ub:~/workplace/somecode$ ftp -p 192.168.3.14
Connected to 192.168.3.14.
220 (vsFTPd 3.0.3)
Name (192.168.3.14:cuc): padres
331 Please specify the password.
Password:
230 Login successful.
Remote system type is UNIX.
Using binary mode to transfer files.
ftp> ls
227 Entering Passive Mode (192.168.3.14,188,148).
150 Here comes the directory listing.
drwxr-xr-x    2 ftp      ftp          4096 Jun 30 15:56 files
226 Directory send OK.
ftp> cd files
250 Directory successfully changed.
ftp> ls
227 Entering Passive Mode (192.168.3.14,178,18).
150 Here comes the directory listing.
-rw-r--r--    1 ftp      ftp            24 Jun 30 15:56 test.txt
226 Directory send OK.
ftp> get test.txt # 读
local: test.txt remote: test.txt
227 Entering Passive Mode (192.168.3.14,160,193).
150 Opening BINARY mode data connection for test.txt (24 bytes).
226 Transfer complete.
24 bytes received in 0.00 secs (100.1656 kB/s)
ftp> put 1.cpp # 写
local: 1.cpp remote: 1.cpp
227 Entering Passive Mode (192.168.3.14,157,147).
150 Ok to send data.
226 Transfer complete.
2129 bytes sent in 0.00 secs (3.6845 MB/s)
ftp> ls
227 Entering Passive Mode (192.168.3.14,160,135).
150 Here comes the directory listing.
-rw-------    1 ftp      ftp          2129 Jun 30 16:01 1.cpp  
-rw-r--r--    1 ftp      ftp            24 Jun 30 15:56 test.txt
226 Directory send OK.

```

### 测试用户能否访问其他文件夹:

```bash
cuc@clone-ub:~/workplace/somecode$ ftp -p 192.168.3.14
Connected to 192.168.3.14.
220 (vsFTPd 3.0.3)
Name (192.168.3.14:cuc): padres
331 Please specify the password.
Password:
230 Login successful.
Remote system type is UNIX.
Using binary mode to transfer files.
ftp> ls
227 Entering Passive Mode (192.168.3.14,172,181).
150 Here comes the directory listing.
drwxr-xr-x    2 ftp      ftp          4096 Jun 30 16:11 files
226 Directory send OK.
ftp> cd ..
250 Directory successfully changed.
ftp> ls 
227 Entering Passive Mode (192.168.3.14,188,171).
150 Here comes the directory listing.
drwxr-xr-x    2 ftp      ftp          4096 Jun 30 16:11 files # 不能回到上一级
226 Directory send OK.
```

### 匿名登录

```bash
cuc@clone-ub:~/workplace/somecode$ ftp -p 192.168.3.14
Connected to 192.168.3.14.
220 (vsFTPd 3.0.3)
Name (172.17.0.2:cuc): ftp
230 Login successful.
Remote system type is UNIX.
Using binary mode to transfer files.
ftp> ls
227 Entering Passive Mode (192.168.3.14,187,190).
150 Here comes the directory listing.
drwxr-xr-x    2 ftp      ftp          4096 Jun 30 16:25 pub
226 Directory send OK.
ftp> cd pub
250 Directory successfully changed.
ftp> ls
227 Entering Passive Mode (192.168.3.14,182,189).
150 Here comes the directory listing.
-rw-r--r--    1 ftp      ftp            27 Jun 30 16:25 test.txt # 只读
226 Directory send OK.
ftp> get test.txt # 可读
local: test.txt remote: test.txt
227 Entering Passive Mode (192.168.3.14,193,10).
150 Opening BINARY mode data connection for test.txt (27 bytes).
226 Transfer complete.
27 bytes received in 0.00 secs (75.7916 kB/s)
ftp> put 1.cpp # 不能写
local: 1.cpp remote: 1.cpp
227 Entering Passive Mode (192.168.3.14,165,130).
550 Permission denied.
```

## NFS 配置

### 配置

在服务器端将配置文件[nfs.config](./NFS/nfs.config),与脚本文件[start-nfs-server.sh](./NFS/start-nfs-server.sh)放在统一目录下的 ,在服务器上运行脚本安装NFS服务

```bash
sudo bash start-nfs-client.sh
```

在客户端将配置文件[nfs.config](./NFS/nfs.config),与脚本文件[start-nfs-client.sh](./NFS/start-nfs-client.sh)放在同一目录下，在客户机上运行：

```bash
sudo bash start-nfs-client.sh
```

### 测试

客户端输入

```bash
df -h
```

终端输出

```bash
cuc@clone-of-yzh:~$ df -h
Filesystem                         Size  Used Avail Use% Mounted on
udev                               447M     0  447M   0% /dev
tmpfs                               99M  1.1M   98M   2% /run
/dev/mapper/ubuntu--vg-ubuntu--lv   72G  4.9G   63G   8% /
tmpfs                              491M     0  491M   0% /dev/shm
tmpfs                              5.0M     0  5.0M   0% /run/lock
tmpfs                              491M     0  491M   0% /sys/fs/cgroup
/dev/sda2                          976M  201M  709M  23% /boot
/dev/loop1                          56M   56M     0 100% /snap/core18/2066
/dev/loop2                          70M   70M     0 100% /snap/lxd/19188
/dev/loop3                          68M   68M     0 100% /snap/lxd/20326
/dev/loop0                          56M   56M     0 100% /snap/core18/2074
/dev/loop5                          33M   33M     0 100% /snap/snapd/12159
/dev/loop6                          33M   33M     0 100% /snap/snapd/12398
tmpfs                               99M     0   99M   0% /run/user/1000
192.168.56.101:/var/nfs/general     72G  5.3G   63G   8% /nfs/general
192.168.56.101:/home                72G  5.3G   63G   8% /nfs/home      # 挂载的远程目录
```

- 客户端上共享目录中文件、子目录属主、权限信息：

```
cuc@clone-of-yzh:/nfs/general/files$ ls -la 
total 8
drwxr-xr-x 2 root   root    4096 Jun 30 19:07 .
drwxr-xr-x 3 nobody nogroup 4096 Jun 30 19:07 ..
cuc@clone-of-yzh:/nfs/general/files$ touch t # 共享目录写尝试
touch: cannot touch 't': Permission denied
```

这和服务器上的权限信息一样

## Samba配置

### 服务器

- 修改配置文件`diy_samba.config`，将配置文件与脚本放在同一目录下，在服务器上：

```bash
sudo bash ./samba_server_install.sh
```

### 客户端

- 安装好客户端以后

```bash
cuc@clone-of-yzh:~$ smbclient -L 192.168.56.101 -U demoUser
Enter WORKGROUP\demoUser's password:

	Sharename       Type      Comment
	---------       ----      -------
	print$          Disk      Printer Drivers
	demoUser        Disk
	IPC$            IPC       IPC Service (demo-auto server (Samba, Ubuntu))
SMB1 disabled -- no workgroup available
```

- 连接服务器与客户端

```bash
cuc@clone-of-yzh:~$ smbclient //192.168.56.101/demoUser -U demoUser
Enter WORKGROUP\demoUser's password:
Try "help" to get a list of possible commands.
smb: \> ls
  .                                   D        0  Tue Jun 30 19:37:45 2021
  ..                                  D        0  Tue Jun 30 19:37:45 2021

		74630028 blocks of size 1024. 65185668 blocks available:~$ smbclient //192.168.56.101/demoUser -U demoUser
Enter WORKGROUP\demoUser's password:
Try "help" to get a list of possible commands.
smb: \> ls
  .                                   D        0  Tue Jun 30 19:37:45 2021
  ..                                  D        0  Tue Jun 30 19:37:45 2021

		74630028 blocks of size 1024. 65185668 blocks available
```

## DHCP,DNS服务器配置

### 服务器自动化脚本安装DHCP服务

- DHCP服务安装配置文件为[00-installer-config.yaml](./dhcp/00-installer-config.yaml),[dhcp.config](./dhcp/dhcp.config)。

```bash
sudo bash dhcp.sh
```

## 参考资料

- [docker  从入门到实践](https://yeasy.gitbook.io/docker_practice/)
- ZHANG1933 实验报告
- [docker ubuntu 官方文档](https://docs.docker.com/compose/)
- https://github.com/fikipollo/vsftpd-docker
- [Ubuntu 20.04: DHCP server and client configuration](https://cyberfarmnepal.wordpress.com/2020/06/18/ubuntu-20-04-dhcp-server-and-client-configuration/)
- [Linux Disable Shell / FTP Access For a User Account](https://www.cyberciti.biz/faq/how-to-disable-shell-ftp-access-to-newuser/)

