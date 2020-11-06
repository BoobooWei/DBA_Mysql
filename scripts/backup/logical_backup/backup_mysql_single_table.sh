#!/bin/bash
# 备份单表 V.18.06.21.0
# backup_mysql_single_table.sh
DBUser=
DBPwd=
DBName=
DBHost=
T1=
T2=
BackupPath="/alidata/rdsbackup"
BackupFile="$DBName-"$(date +%y%m%d_%H)".sql"
BackupLog="$DBName-"$(date +%y%m%d_%H)".log"
# Backup Dest directory, change this if you have someother location
if !(test -d $BackupPath)
then
mkdir $BackupPath -p
fi
cd $BackupPath
a=`mysqldump -u$DBUser -p$DBPwd -h$DBHost $DBName --tables $T1 $T2 --opt --set-gtid-purged=OFF --default-character-set=utf8 --single-transaction --hex-blob --skip-triggers --max_allowed_packet=824288000 > "$BackupPath"/"$BackupFile" 2> /dev/null; echo $?`
if [ $a -ne 0 ]
then
 echo "$(date +%y%m%d_%H:%M:%S) 备份失败" >> $BackupLog
else
 echo "$(date +%y%m%d_%H:%M:%S) 备份成功" >> $BackupLog
fi
#Delete sql type file & log file
find "$BackupPath" -name "$DBname*[log,sql]" -type f -mtime +3 -exec rm -rf {} \;
