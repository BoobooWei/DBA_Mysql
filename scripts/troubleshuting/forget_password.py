破解代码
#!/usr/bin/env python
# -*- coding:utf-8 -*-

import MySQLdb
import os
import signal
def connectionMysql(host,user,password,newRootPassword):
    """mysql的root密码不停服务破解方式"""

    # 登陆低权限用户连接mysql创建一个库（python）
    db = MySQLdb.connect(host, user, password)
    cursor = db.cursor()
    cursor.execute("create database python")
    db.commit()
    db.close()

    # linux系统内的操作，拷贝mysql下的用户表，到python库下
    os.system("\cp -avx /data/mysql/data/mysql/user.* /data/mysql/data/python/")

    # 登陆python用户
    db = MySQLdb.connect(host, user, password)
    cursor = db.cursor()
    # 更新python库下的user表
    cursor.execute('update python.user set authentication_string=password("%s") where user="root"'%(newRootPassword))
    db.commit()
    # 刷新授权，防止事务未提交
    cursor.execute("flush privileges")
    db.commit()
    db.close()

    # 拷贝更改后的user表到mysql库下
    os.system("\cp -avx /data/mysql/data/python/user.* /data/mysql/data/mysql/")
    # 查找mysqld的父进程
    tmp = os.popen("pgrep -n mysqld")
    result = int(tmp.read())
    print(result)
    # 向mysqld发送SIGHUP信号，强制刷新
    os.kill(result, signal.SIGHUP)  #PID必须为int类型
    # ok 牢记密码即可
    print("root password is %s , Please remember the password!!! " % (newRootPassword))
    #os.popen("kill -SIGHUP %s" %(result))
