#!/bin/bash
# check_mongodb_replica_set_nodes_status
# 1 ok 
result=`echo "rs.status()" | mongo 127.0.0.1:40000/admin | sed -n '/m3.joowing.com:40000/,+1p'| sed 's/,//g'|grep health | awk -F : '{print $2}'`
echo $result
