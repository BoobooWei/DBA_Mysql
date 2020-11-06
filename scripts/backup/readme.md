#还原数据库
#用mysql-front导入前一天的 *.sql 文件即可恢复数据
关于权限问题
导出为sql，则需要待备份对象的只读权限select

导出为表格，则需要

A.添加”file,select“两个权限 ；

B.修改secure_file_priv权限为允许导出到任意目录


# root用户（主从）授权file，导出表格
> grant file,select on *.* to backup_xls@'%' identified by 'bQ4QMKaxH7vkzUFQQd0u';
> flush privileges;
 
 
$ vim /etc/my.cnf
 
# 2018-07-13 CloudCareDBA
secure_file_priv=''