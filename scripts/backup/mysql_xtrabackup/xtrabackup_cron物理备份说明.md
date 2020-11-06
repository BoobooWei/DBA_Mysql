# MySQL基于innobackupex的物理全备和增量备份

> 2018-03-07 驻云DBA组

[TOC]

## 功能概述

* 实现MySQL数据库物理备份；
* 一周一全备，每天一增备；
* 自动清理过期备份（只保留最近的全备+增备）
* 备份任务每日定时执行

## 安装percona-xtrabackupex

官网下载对应版本的percona-xtrabackupex软件


```shell
cd /alidata/install
yum install -y lrzsz libev
tar -xf Percona-XtraBackup-2.4.9-ra467167cdd4-el7-x86_64-bundle.tar
rpm -ivh percona-xtrabackup-24-2.4.9-1.el7.x86_64.rpm
innobackupex -v
```

测试中使用的版本为：innobackupex version 2.4.9 Linux (x86_64) (revision id: a467167cdd4)

## 数据库授权

遵循最小权限原则，授予如下权限：

```shell
grant lock tables,reload,process,replication client,super on *.* to ro_user@'localhost' identified by '(Uploo00king)';

flush privileges;
```

## 备份脚本

将备份脚本传输到服务器的/alidata/install目录下并解压：

```shell
unzip xtrabackup_cron.zip -d /alidata/
```

测试明细

```shell
[root@mastera install]# ls
mysql5.6.tar  mysql-5.7.17-linux-glibc2.5-x86_64.tar.gz  software  xtrabackup_cron.zip
[root@mastera install]# unzip xtrabackup_cron.zip -d /alidata/
Archive:  xtrabackup_cron.zip
   creating: /alidata/xtrabackup_cron/
   creating: /alidata/xtrabackup_cron/bin/
  inflating: /alidata/xtrabackup_cron/bin/mysql_increment_hot_backup.sh  
   creating: /alidata/xtrabackup_cron/conf/
  inflating: /alidata/xtrabackup_cron/conf/.mysql_increment_hot_backup.conf.swp  
  inflating: /alidata/xtrabackup_cron/conf/mysql_increment_hot_backup.conf  
   creating: /alidata/xtrabackup_cron/log/
   creating: /alidata/xtrabackup_cron/var/
 extracting: /alidata/xtrabackup_cron/var/mysql_increment_hot_backup.err  
 extracting: /alidata/xtrabackup_cron/var/mysql_increment_hot_backup.index  
[root@mastera install]# ll /alidata/
total 0
drwxr-xr-x  3 root  root  114 Mar  6 18:38 install
drwxr-xr-x 11 mysql mysql 141 Feb 26 18:15 mysql
drwxr-xr-x  6 root  root   47 Jan  1  2016 xtrabackup_cron

[root@mastera install]# cd /alidata/xtrabackup_cron/
[root@mastera xtrabackup_cron]# ll
total 0
drwxr-xr-x 2 root root 42 Jan  1  2016 bin
drwxr-xr-x 2 root root 87 Jan  1  2016 conf
drwxr-xr-x 2 root root  6 Jan  1  2016 log
drwxr-xr-x 2 root root 82 Jan  1  2016 var
```

备份脚本结构：

* bin 备份的可执行脚本
* conf 备份的配置文件
* log 备份脚本的日志信息
* var 备份文件的索引信息

## 备份测试明细

修改配置文件如下：

```shell
[root@mastera bin]# vim ../conf/mysql_increment_hot_backup.conf
# mysql 用户名
user=ro_user

# mysql 密码
password=(Uploo00king)

# 备份路径
backup_dir=/alidata/backup

# percona-xtrabackup 备份软件路径 脚本中将使用该目录与/bin/innobakcupex做拼接
xtrabackup_dir=/usr

# 全备是在一周的第几天，1为每周一
full_backup_week_day=1

# 全量备信息名称 前缀
full_backup_prefix=full
```

关闭数据库的情况下执行备份脚本，查看备份脚本的错误日志情况：

```shell
[root@mastera ~]# cd /alidata/xtrabackup_cron/log/
[root@mastera log]# ll
total 4
-rw-r--r-- 1 root root 742 Mar  7 12:06 full_2018-03-07_12-06-16_3.log
[root@mastera log]# cat full_2018-03-07_12-06-16_3.log 
180307 12:06:16 innobackupex: Starting the backup operation

IMPORTANT: Please check that the backup run completes successfully.
           At the end of a successful backup run innobackupex
           prints "completed OK!".

180307 12:06:17  version_check Connecting to MySQL server with DSN 'dbi:mysql:;mysql_read_default_group=xtrabackup;port=3306;mysql_socket=/tmp/mysql.sock' as 'ro_user'  (using password: YES).
Failed to connect to MySQL server as DBD::mysql module is not installed at - line 1327.
180307 12:06:17 Connecting to MySQL server host: localhost, user: ro_user, password: set, port: 3306, socket: /tmp/mysql.sock
Failed to connect to MySQL server: Can't connect to local MySQL server through socket '/tmp/mysql.sock' (2).
```

手动修改系统时间测试脚本执行情况 

```shell
[root@mastera ~]# date -s "2018-03-07 12:03:00" && bash /alidata/xtrabackup_cron/bin/mysql_increment_hot_backup.sh 
[root@mastera ~]# date -s "2018-03-08 12:03:00" && bash /alidata/xtrabackup_cron/bin/mysql_increment_hot_backup.sh 
[root@mastera ~]# date -s "2018-03-09 12:03:00" && bash /alidata/xtrabackup_cron/bin/mysql_increment_hot_backup.sh 
[root@mastera ~]# date -s "2018-03-10 12:03:00" && bash /alidata/xtrabackup_cron/bin/mysql_increment_hot_backup.sh
[root@mastera ~]# date -s "2018-03-11 12:03:00" && bash /alidata/xtrabackup_cron/bin/mysql_increment_hot_backup.sh
[root@mastera ~]# date -s "2018-03-12 12:03:00" && bash /alidata/xtrabackup_cron/bin/mysql_increment_hot_backup.sh
[root@mastera ~]# date -s "2018-03-13 12:03:00" && bash /alidata/xtrabackup_cron/bin/mysql_increment_hot_backup.sh


[root@mastera backup]# ll
total 20
drwxr-xr-x 6 root root 4096 Mar  7 12:08 full_2018-03-07_12-07-53_3
drwxr-xr-x 5 root root   83 Mar 12 12:03 full_2018-03-12_12-03-00_1
drwxr-xr-x 6 root root 4096 Mar  8 12:03 incr_2018-03-08_12-03-02_4
drwxr-xr-x 6 root root 4096 Mar  9 12:03 incr_2018-03-09_12-03-05_5
drwxr-xr-x 6 root root 4096 Mar 10 12:03 incr_2018-03-10_12-03-00_6
drwxr-xr-x 6 root root 4096 Mar 11 12:03 incr_2018-03-11_12-03-00_7
[root@mastera backup]# ll
total 8
drwxr-xr-x 6 root root 4096 Mar 12 12:03 full_2018-03-12_12-03-00_1
drwxr-xr-x 6 root root 4096 Mar 13 12:03 incr_2018-03-13_12-03-00_2
[root@mastera var]# cat mysql_increment_hot_backup.index
{week_day:1,          dir:full_2018-03-12_12-03-00_1,          type:full,          date:2018-03-12}
{week_day:2,          dir:incr_2018-03-13_12-03-00_2,          type:incr,          date:2018-03-13}
[root@mastera var]# cat mysql_increment_hot_backup.index_2018-03-11
{week_day:3,          dir:full_2018-03-07_12-07-53_3,          type:full,          date:2018-03-07}
{week_day:4,          dir:incr_2018-03-08_12-03-02_4,          type:incr,          date:2018-03-08}
{week_day:5,          dir:incr_2018-03-09_12-03-05_5,          type:incr,          date:2018-03-09}
{week_day:6,          dir:incr_2018-03-10_12-03-00_6,          type:incr,          date:2018-03-10}
{week_day:7,          dir:incr_2018-03-11_12-03-00_7,          type:incr,          date:2018-03-11}
```

测试时间从周三开始执行第一次备份，生成全备份`full_2018-03-07_12-07-53_3`，后续到周日，都是增量备份。

测试第二周的周一，生成全备份`full_2018-03-12_12-03-00_1`;

测试第二周的周二，生成增量备份`incr_2018-03-13_12-03-00_2`，并删除了前一周所有的备份。