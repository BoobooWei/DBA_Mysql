#!/bin/bash
# 同步生产库与测试库脚本版本 V.18.06.21.0
# 备份目标 ecshop库
DBUser=root
DBPwd=uplooking
DBName=ecshoptest
DBName_test=temp_ecshoptest
DBHost=localhost
BackupPath="/alidata/rdsbackup"
BackupFile="$DBName-"$(date +%y%m%d_%H)".sql"
BackupLog="$DBName-"$(date +%y%m%d_%H)".log"
# Backup Dest directory, change this if you have someother location
if !(test -d $BackupPath)
then
mkdir $BackupPath -p
fi
cd $BackupPath
a=`mysqldump -u$DBUser -p$DBPwd -h$DBHost $DBName --opt --set-gtid-purged=OFF --default-character-set=utf8  --single-transaction --hex-blob --skip-triggers --max_allowed_packet=824288000 > "$BackupPath"/"$BackupFile" 2> /dev/null; echo $?`
if [ $a != 0 ]
then
        echo "$(date +%y%m%d_%H:%M:%S) 备份失败" >> $BackupLog
else
        echo "$(date +%y%m%d_%H:%M:%S) 备份成功" >> $BackupLog
        #开始导入测试库
        ## 预先清除测试库中所有的表,删除开发库，再新建开发库
        mysql -u$DBUser -p$DBPwd -h$DBHost -e "drop database $DBName_test;create database $DBName_test"
        b=`mysql -u$DBUser -p$DBPwd -h$DBHost $DBName_test < "$BackupPath"/"$BackupFile" 2> /dev/null; echo $?`
        if [ $b != 0 ]
        then
                echo "$(date +%y%m%d_%H:%M:%S) 导入失败" >> $BackupLog
        else
                echo "$(date +%y%m%d_%H:%M:%S) 导入成功" >> $BackupLog
        fi
fi
 
#Delete sql type file & log file
find "$BackupPath" -name "$DBname*[log,sql]" -type f -mtime +3 -exec rm -rf {} \;