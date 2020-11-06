#!/bin/bash
# auth:BoobooWei
# mail:rgweiyaping@hotmail.com
# info:搭建RDS到自建MySQL主从
# pxc备份数据恢复路径
pxc_data=/alidata/mysql/xtrabackup_data
gtid=
# 本地自建数据库数据目录
datadir='/alidata/mysql/data/mysql'
# rds数据库连接方式
rds_user='root'
rds_pwd='Uploo00king'
rds_url='ssss'
rds_port=3306
# 备份RDS的元数据（与本地有差别的表）
mysqldump -u$rds_user -p$rds_pwd -h$rds_url -P $rds_port mysql columns_priv db event func ndb_binlog_index proc procs_priv proxies_priv tables_priv user  --set-gtid-purged=OFF --opt --default-character-set=utf8  --single-transaction --hex-blob --skip-triggers --max_allowed_packet=824288000 -d  > mysql.sys.meta.sql
# 备份rds差异表的数据
mysqldump -u$rds_user -p$rds_pwd -h$rds_url -P $rds_port mysql columns_priv db event func ndb_binlog_index proc procs_priv proxies_priv tables_priv user  --set-gtid-purged=OFF --opt --default-character-set=utf8  --single-transaction --hex-blob --skip-triggers --max_allowed_packet=824288000 -t > mysql.sys.data.sql 
# 删除本地恢复的差别表
cat > local_drop.sql << ENDF
drop table columns_priv ;
drop table db;
drop table event;
drop table func;
drop table ndb_binlog_index;
drop table proc;
drop table procs_priv;
drop table proxies_priv;
drop table tables_priv;
drop table user;
ENDF
mysql < local_drop.sql 

# 删除本地数据文件
cd $datadir
rm -rf columns_priv\.*
rm -rf db\.*
rm -rf event\.*
rm -rf func\.*
rm -rf ndb_binlog_index\.*
rm -rf proc\.*
rm -rf procs_priv\.*
rm -rf proxies_priv\.*
rm -rf tables_priv\.* 
rm -rf user\.* 
 
# 查看数据文件
ll columns_priv\.*
ll db\.*
ll event\.*
ll func\.*
ll ndb_binlog_index\.*
ll proc\.*
ll procs_priv\.*
ll proxies_priv\.*
ll tables_priv\.* 
ll user\.* 
 
# 导入元数据（即表结构）
sed -i 's/ENGINE=InnoDB/ENGINE=myisam/' mysql.sys.meta.sql
mysql mysql < mysql.sys.meta.sql
 
# 导入数据
mysql mysql < mysql.sys.data.sql

cat > local_grant.sql << ENDF
# 添加权限
grant all on *.* to 'booboo'@'%' identified by 'Uploo00king';
# 修改aliyun_root权限
update mysql.user set authentication_string=password('Uploo00king') where user='aliyun_root';
ENDF

mysql < local_grant.sql
# 重新启动服务
/alidata/mysql/support-files/mysql.server restart


# 配置主从
stop slave;
reset slave all;
reset master;
SET GLOBAL gtid_purged='$gtid';
change master to master_host='$url',master_user='$user',master_password='$pwd',master_auto_position=1;
start slave;
show slave status\G;