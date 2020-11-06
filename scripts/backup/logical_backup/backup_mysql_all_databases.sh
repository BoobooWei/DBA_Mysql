备份全库
#!/bin/bash
# backup_mysql_all_databases.sh
# 备份全库 V.18.06.21.0
# 备份目标 所有的库表
DBUser=
DBPwd=
DBName=
DBHost=
BackupPath="/alidata/rdsbackup"
BackupFile="mysql.all."$(date +%y%m%d_%H)".sql"
BackupLog="mysql.all."$(date +%y%m%d_%H)".log"
# Backup Dest directory, change this if you have someother location
if !(test -d $BackupPath)
then
mkdir $BackupPath -p
fi
cd $BackupPath
a=`mysqldump -u$DBUser -p$DBPwd -h$DBHost -A --opt --set-gtid-purged=OFF --default-character-set=utf8 --single-transaction --hex-blob --skip-triggers --max_allowed_packet=824288000 > "$BackupPath"/"$BackupFile" 2> /dev/null; echo $?`
if [ $a -ne 0 ]
then
 echo "$(date +%y%m%d_%H:%M:%S) 备份失败" >> $BackupLog
else
 echo "$(date +%y%m%d_%H:%M:%S) 备份成功" >> $BackupLog
fi
#Delete sql type file & log file
find "$BackupPath" -name "mysql.all*[log,sql]" -type f -mtime +3 -exec rm -rf {} \;