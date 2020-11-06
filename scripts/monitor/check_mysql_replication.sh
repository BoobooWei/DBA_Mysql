#!/bin/bash
## check_mysql_replication.sh
# auth=booboowei
# V.18.08.10
app_bin=/data/mysql/bin/mysql
DB_HOST="localhost"
#DB_USER="monitorUser"
#DB_PASSWORD="xxxxxxxxx"
SLAVE_INFO=(`echo "show slave status\G;" | /data/mysql/bin/mysql 2> /dev/null | grep 'Slave_IO_Running:\|Slave_SQL_Running:\|Seconds_Behind_Master:' | awk '{print $2}'`)
echo ${SLAVE_INFO[*]}
if [ "${SLAVE_INFO[0]}" == "Yes" ] && [ "${SLAVE_INFO[1]}" == "Yes" ] && [ "${SLAVE_INFO[2]}" -gt 43200 ] 
then
	echo 1
else
	echo 0
fi
root@joowing-server-06:/data/install# bash -x check_mysql_replication.sh 
+ app_bin=/data/mysql/bin/mysql
+ DB_HOST=localhost
+ SLAVE_INFO=(`echo "show slave status\G;" | /data/mysql/bin/mysql 2> /dev/null | grep 'Slave_IO_Running:\|Slave_SQL_Running:\|Seconds_Behind_Master:' | awk '{print $2}'`)
++ echo 'show slave status\G;'
++ /data/mysql/bin/mysql
++ grep 'Slave_IO_Running:\|Slave_SQL_Running:\|Seconds_Behind_Master:'
++ awk '{print $2}'
+ echo Yes Yes 0
Yes Yes 0
+ '[' Yes == Yes ']'
+ '[' Yes == Yes ']'
+ '[' 0 -gt 43200 ']'
+ echo 0
0