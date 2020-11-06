#!/bin/bash
# 备份数据库的表结构
# 备份脚本backup_mysql_meta.sh
# 用户名
user=xx
# mysql 密码
password=xx
# 备份所有对象的表结构
mysqldump -u$user -p$password -A --set-gtid-purged=OFF --opt --default-character-set=utf8 --single-transaction --hex-blob -d --skip-triggers  --max_allowed_packet=824288000 > mysql.all.meta.sql
# 备份除了系统库外的表结构
mysql -u$user -p$password -e 'show databases;' | grep -Ev 'Database|information_schema|performance_schema|mysql|test|sys' | xargs mysqldump -u$user -p$password --databases --set-gtid-purged=OFF --opt --default-character-set=utf8  --single-transaction --hex-blob --skip-triggers --max_allowed_packet=824288000 -d  > mysql.except.sys.meta.sql