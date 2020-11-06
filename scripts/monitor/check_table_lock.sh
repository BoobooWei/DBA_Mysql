#!/bin/bash
## check_mysql_table_lock_gt_30.sh
# auth=booboowei
# V.18.08.27
app_bin=/alidata/mysql/bin/mysql
DB_HOST="localhost"
DB_USER="root"
DB_PASSWORD="uplooking"
table_lock_num=`echo "select count(*) from information_schema.processlist where state = 'Waiting for table level lock';" | mysql -uroot -puplooking  2> /dev/null | sed -n '2p'`
# test
#echo ${table_lock_num}
#table_lock_num=31
if [[ ${table_lock_num} > 30 ]]
then
	echo 1
else
	echo 0
fi
