�ƽ����
#!/usr/bin/env python
# -*- coding:utf-8 -*-

import MySQLdb
import os
import signal
def connectionMysql(host,user,password,newRootPassword):
    """mysql��root���벻ͣ�����ƽⷽʽ"""

    # ��½��Ȩ���û�����mysql����һ���⣨python��
    db = MySQLdb.connect(host, user, password)
    cursor = db.cursor()
    cursor.execute("create database python")
    db.commit()
    db.close()

    # linuxϵͳ�ڵĲ���������mysql�µ��û�����python����
    os.system("\cp -avx /data/mysql/data/mysql/user.* /data/mysql/data/python/")

    # ��½python�û�
    db = MySQLdb.connect(host, user, password)
    cursor = db.cursor()
    # ����python���µ�user��
    cursor.execute('update python.user set authentication_string=password("%s") where user="root"'%(newRootPassword))
    db.commit()
    # ˢ����Ȩ����ֹ����δ�ύ
    cursor.execute("flush privileges")
    db.commit()
    db.close()

    # �������ĺ��user��mysql����
    os.system("\cp -avx /data/mysql/data/python/user.* /data/mysql/data/mysql/")
    # ����mysqld�ĸ�����
    tmp = os.popen("pgrep -n mysqld")
    result = int(tmp.read())
    print(result)
    # ��mysqld����SIGHUP�źţ�ǿ��ˢ��
    os.kill(result, signal.SIGHUP)  #PID����Ϊint����
    # ok �μ����뼴��
    print("root password is %s , Please remember the password!!! " % (newRootPassword))
    #os.popen("kill -SIGHUP %s" %(result))
