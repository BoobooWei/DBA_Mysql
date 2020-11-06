#!/bin/bash
# 备份除系统库外的所有库 V.18.06.21.0
# backup_mysql_except_sys.sh
DBUser=
DBPwd=
DBName=
DBHost=
BackupPath="/alidata/rdsbackup"
BackupFile="mysql.except.sys."$(date +%y%m%d_%H)".sql"
BackupLog="mysql.except.sys."$(date +%y%m%d_%H)".log"
# Backup Dest directory, change this if you have someother location
if !(test -d $BackupPath)
then
mkdir $BackupPath -p
fi
cd $BackupPath
a=`mysql -u$user -p$password -e 'show databases;' | grep -Ev 'Database|information_schema|performance_schema|mysql|test|sys' | xargs mysqldump -u$user -p$password --databases --set-gtid-purged=OFF --opt --default-character-set=utf8  --single-transaction --hex-blob --skip-triggers --max_allowed_packet=824288000 -d  > "$BackupPath"/"$BackupFile" 2> /dev/null; echo $?`
if [ $a -ne 0 ]
then
 echo "$(date +%y%m%d_%H:%M:%S) 备份失败" >> $BackupLog
else
 echo "$(date +%y%m%d_%H:%M:%S) 备份成功" >> $BackupLog
fi
#Delete sql type file & log file
find "$BackupPath" -name "mysql.except.sys.*[log,sql]" -type f -mtime +3 -exec rm -rf {} \;