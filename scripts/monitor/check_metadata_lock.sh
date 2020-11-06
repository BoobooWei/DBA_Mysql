#!/bin/bash
## check_mysql_metadata_lock_gt_0.sh
# auth=booboowei
# V.18.08.27
app_bin=/alidata/mysql/bin/mysql
DB_HOST="localhost"
DB_USER="root"
DB_PASSWORD="uplooking"
metadata_lock_num=`echo "select count(*) from information_schema.processlist where state = 'Waiting for table metadata lock';" | mysql -uroot -puplooking  2> /dev/null | sed -n '2p'`
# test
#echo ${metadata_lock_num}
#metadata_lock_num=1
if [[ ${metadata_lock_num} > 0 ]]
then
	echo 1
else
	echo 0
fi
