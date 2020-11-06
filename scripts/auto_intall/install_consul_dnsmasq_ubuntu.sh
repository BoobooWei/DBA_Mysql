#!/bin/bash
# ubuntu
# consul consul_0.8.5
# dnsmasq 
if [ $# -ne 0 ]
then
	# 创建软件目录
	mkdir -p /alidata/consul &> /dev/null 
	cd /alidata/consul &> /dev/null
	mkdir conf data &> /dev/null
	mkdir -p /alidata/install &> /dev/null
	cd /alidata/install

	# 下载软件并编译安装
	if [ `uname -m` == "x86_64" ];then
		wget https://releases.hashicorp.com/consul/0.8.5/consul_0.8.5_linux_amd64.zip?_ga=2.137222896.1530840127.1499765262-598930965.1499233390 -O consul_0.8.5_linux_amd64.zip
		unzip consul_0.8.5_linux_amd64.zip
	else
		wget https://releases.hashicorp.com/consul/0.8.5/consul_0.8.5_linux_386.zip?_ga=2.91175898.1530840127.1499765262-598930965.1499233390 -O consul_0.8.5_linux_386.zip
		unzip consul_0.8.5_linux_386.zip
	fi

	mv consul /bin
	# 配置文件自己手动创建
	
	# 检查安装结果
	which consul
	ls -l /alidata/consul
	
	# 绑定dns 53号端口
	mv /etc/resolv.conf  /etc/resolv.conf.bac
	ln -s /run/resolvconf/resolv.conf /etc/resolv.conf
	apt-get install dnsmasq -y
	cat >> /etc/dnsmasq.d/10-consul << ENDF
# Enable forward lookup of the 'consul' domain:
server=/consul/127.0.0.1#8600
ENDF
	service dnsmasq stop
else
	echo "Usage： bash consul-0.8.5.sh masterip masterport masterpassword slaveip slaveport"

fi

	# 启动服务
#	nohup /bin/consul agent -dev  -config-dir=/alidata/consul/conf &> /alidata/consul/consul.log &
#	dig @localhost -p 8600 redis.service.consul.
#	service dnsmasq start
# 	dig @localhost -p 53 redis.service.consul.