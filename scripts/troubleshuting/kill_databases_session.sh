#!/bin/bash
# kill掉 指定数据库中所有的会话id，暴力，用于CPU持续飙高，临时解决问题
user=root
password="(Uploo00king)"
host=localhost
port=3306


mysql -u$user -p$password -h$host  -P$port -e "select concat('kill ',id,';') from information_schema.processlist where db in ("dbname","dbname2") > tmpfile

awk '{if (NR != 1) print $0 }' tmpfile | mysql -u$user -p$password -h$host  -P$port 