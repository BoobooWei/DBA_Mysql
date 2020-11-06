#!/bin/bash
# mysql的root密码不停服务破解方式

user=booboo
password="(Uploo00king)"
host=localhost
port=3306
datadir="/alidata/mysql/data"
database="cloudcare"
dbdir=${datadir}/${database}
echo ${dbdir}
rootpwd='(Uploo00king)'



# linux系统内的操作，拷贝mysql下的用户表，到cloudcare库下
\cp -avx ${datadir}/mysql/user.* ${dbdir}

# 登陆低权限用户连接mysql,修改root密码
echo "update ${database}.user set authentication_string=password('${rootpwd}') where user='root';" | mysql -u$user -p$password -h$host  -P$port $database

# 拷贝更改后的user表到mysql库下
\cp -avx ${dbdir}/user.*  ${datadir}/mysql/

# 查找mysqld的父进程
mysqld_pid=`pgrep -n mysqld`

# 向mysqld发送SIGHUP信号，强制刷新
kill -SIGHUP ${mysqld_pid}

# ok 牢记密码即可
echo "root password is $rootpwd , Please remember the password!!! "

