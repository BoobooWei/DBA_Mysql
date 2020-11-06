#!/bin/bash
## check_mysql_innodb_row_lock_ne_0.sh
# auth=booboowei
# V.18.08.27

app_bin=/alidata/mysql/bin/mysql
DB_HOST="localhost"
DB_USER="root"
DB_PASSWORD="uplooking"
cat > check_innodb_row_lock.sql << ENDF
select id
from
information_schema.processlist,
information_schema.innodb_trx
where trx_mysql_thread_id=id
and trx_id in
(
    select blocking_trx_id
    from (
        select blocking_trx_id, count(blocking_trx_id) as countnum
        from
            (
            select a.trx_id,a.trx_state,b.requesting_trx_id,b.blocking_trx_id
            from information_schema.innodb_lock_waits as  b
            left join information_schema.innodb_trx as a
            on a.trx_id=b.requesting_trx_id
            ) as t1
        group by blocking_trx_id
        order by  countnum desc limit 1
        ) c
) ;
ENDF

innodb_row_lock_num=`mysql -uroot -puplooking < check_innodb_row_lock.sql  2> /dev/null|wc -l`
# test
#echo ${innodb_row_lock_num}
#innodb_row_lock_num=1
if [[ ${innodb_row_lock_num} != 0 ]]
then
    echo 1
else
    echo 0
fi


