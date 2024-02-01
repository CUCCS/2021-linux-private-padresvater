

# 第六章：shell脚本编程练习进阶（实验）

FTP、NFS、DHCP、DNS、Samba服务器的自动安装与自动配置

# 软件环境

------

- virtualbox  6.1.18 r142142 (Qt5.6.2)
  
- Ubuntu 20.04
  
- 工作主机：cuc@clone-of-yzh  
  
- 目标主机：cuc@ub-clone-yzh
  
- 两台主机能够互相免密登录
  
- FTP  由于 vsftpd (supports both anonymous and non-anonymous FTP access)，这里选用该服务。

  配置一个提供匿名访问的FTP服务器，匿名访问者可以访问1个目录且仅拥有该目录及其所有子目录的只读访问权限；

  配置一个支持用户名和密码方式访问的账号，该账号继承匿名访问者所有权限，且拥有对另1个独立目录及其子目录完整读写（包括创建目录、修改文件、删除文件等）权限；

  ​		该账号仅可用于FTP服务访问，不能用于系统shell登录；

   FTP用户不能越权访问指定目录之外的任意其他目录和文件；

   匿名访问权限仅限白名单IP来源用户访问，禁止白名单IP以外的访问；

- NFS

  

- DHCP
  - 2台虚拟机使用Internal网络模式连接，其中一台虚拟机上配置DHCP服务，另一台服务器作为DHCP客户端，从该DHCP服务器获取网络地址配置
  
- Samba
  - 对照第6章课件中smbclient一节的3点任务要求完成Samba服务器配置和客户端配置连接测试

------

- DNS
  - 基于上述Internal网络模式连接的虚拟机实验环境，在DHCP服务器上配置DNS服务，使得另一台作为DNS客户端的主机可以通过该DNS服务器进行DNS查询
  - 在DNS服务器上添加 `zone "cuc.edu.cn"` 的以下解析记录

```shell
ns.cuc.edu.cn NS
ns A <自行填写DNS服务器的IP地址>
wp.sec.cuc.edu.cn A <自行填写第5章实验中配置的WEB服务器的IP地址>
dvwa.sec.cuc.edu.cn CNAME wp.sec.cuc.edu.cn
```

# shell脚本编程基本要求

------

- 目标测试与验证系统为本学期课程指定操作系统版本
- 自动安装与自动配置过程的启动脚本要求在本地执行
  - ***提示***：配置远程目标主机的SSH免密root登录，安装脚本、配置文件可以从工作主机（执行启动脚本所在的主机）上通过scp或rsync方式拷贝或同步到远程目标主机，然后再借助SSH的***远程命令执行***功能实现远程控制安装和配置
- 假设目标系统没有配置过root用户免密登录，所以我们要求在自动安装脚本中包含自动配置远程root用户免密登录的代码

------

- 脚本在执行过程中，如果需要在目标主机上创建目录、创建临时文件、执行网络下载等操作需要判断执行是否成功，并进行必要的异常处理（例如：apt-get update失败，则退出脚本执行，并将友好错误信息打印在控制台上。临时目录不存在，则自动创建该临时目录）
- 所有服务的配置文件、临时目录需设置正确的目录和文件归属和权限位，禁止使用***777***这种偷懒的权限位设置
- 减少不必要的安装过程中的人机交互输入，尽可能全部通过脚本的方式完成选项设置和交互式问题输入等

------

- 目标环境相关参数应使用独立的配置文件或配置脚本（在主调脚本中引用配置脚本）
  - 目标服务器IP
  - 目标服务器SSH服务的端口
  - 目标服务器上使用的用户名
  - 目标服务器上用于临时存储安装脚本、配置文件的临时目录路径

# 其他要求

------

- 撰写实验报告，证明你具体完成了哪些任务要求
- 所有脚本代码、配置文件均应包含在你的作业PR之中
- 脚本应在纯净未配置任何目标服务的系统和已完全配置好所有目标服务的系统2种典型测试用例条件下均能测试通过
  - 对于在目标系统上已完成配置的服务，允许用本地的配置文件去覆盖远程已有的配置文件，但在执行***覆盖***操作之前应对远程已有的配置文件进行***妥善***备份

# 配置和检验过程

## vsftpd

- ```sudo apt update ```

- ```sudo apt install vsftpd```

- ``` systemctl status vsftpd``` 查看服务状态

  ![vsftpd-status](.\img\vsftpd-status.png)

- 配置文件放在 /etc/vsftpd.conf

- 备份配置文件

  ```sudo cp /etc/vsftpd.conf /etc/vsftpd.conf_default```

- 匿名用户登录

  ```anonymous_enable = YES```

  (Controls whether anonymous logins are permitted or not. If enabled, both the usernames **ftp** and **anonymous** are recognised as anonymous logins.) 即使用用户名ftp即可表示匿名登陆。

- 本地用户登录

  ```local_enable=YES```

- 读写操作

  ```write_enable=YES```

- FTP用户不能越权访问指定目录之外的任意其他目录和文件

  ```chroot_list_enable=NO```

- 设置白名单

  ```shell
  userlist_enable=YES
  userlist_file=/etc/vsftpd.user_list
  userlist_deny=NO
  ```

  /etc/vsftpd.user_list即白名单。

- 得到最终的配置文件 

  [vsftpd.conf](.\config\vsftpd.conf)

- 脚本文件

  [vsftpd.sh](.\shell\vsftpd.sh)

- 在目标主机上运行shell脚本进行测试

  ![ftp-demo](.\img\ftp-demo.png)

- 工作主机连接目标主机

  ![ftp-connect](.\img\ftp-connect.png)

- 









# 参考资料

- [vsftpd官方配置文档](http://vsftpd.beasts.org/vsftpd_conf.html)
- [使用vsftpd 搭建ftp 服务器](https://segmentfault.com/a/1190000016376962)
- [vsftpd 配置:chroot_local_user与chroot_list_enable详解](vsftpd 配置:chroot_local_user与chroot_list_enable详解)
- 

