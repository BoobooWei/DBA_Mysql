#!/bin/sh
# 导出单表为表格
# Database info
DB_USER="xxx"
DB_PASS="xx"
DB_HOST="xxx"
DB_NAME="xxx"
# 数据库表
TABLE1="xxx"
TABLE2="xxx"
DB_TABLE=$TABLE1 $TABLE2
 
# Others vars
BIN_DIR="/alidata/mysql/bin"            #the mysql bin path
BCK_DIR="/alidata/backup_account"    #the backup file directory
DATE="`date +%Y-%m-%d`"
DB_PATH=$BCK_DIR/$DATE
# 打印存储路径
echo $DB_PATH
# 判断路径是否存在
if [ ! -d $DB_PATH ];then
echo $DB_PATH
mkdir $DB_PATH
chown mysql. $DB_PATH
else
echo $DB_PATH
rm -rf $DB_PATH
mkdir $DB_PATH
chown mysql. $DB_PATH
fi
 
# TODO
# 备份数据
$BIN_DIR/mysqldump --opt --single-transaction --set-gtid-purged=OFF -u$DB_USER -p$DB_PASS -h$DB_HOST $DB_NAME $DB_TABLE > $DB_PATH/db_data_${TABLE1}_${TABLE2}.sql
 
# 导出excel
mysql -u$DB_USER -p$DB_PASS -h$DB_HOST $DB_NAME  -e "select * from $TABLE1 into outfile '$DB_PATH/$TABLE1.xls'";
 
mysql -u$DB_USER -p$DB_PASS -h$DB_HOST $DB_NAME  -e "select * from $TABLE2 into outfile '$DB_PATH/$TABLE2.xls'";
 
# 远程传输到备份服务器
scp -r $DB_PATH mysqlbackup@192.168.20.3:/alidata/backup_account/

# 删除
BackupPath=/alidata/backup_account
find "$BackupPath" -type f -mtime +7 -exec rm -rf  {} \;
