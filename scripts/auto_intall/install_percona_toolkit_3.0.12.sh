#!/bin/bash

yum install -y  perl perl-devel perl-Time-HiRes  perl-DBI perl-DBD-MySQL perl-Digest-MD5
yum install -y cmake gcc gcc-c++ libaio libaio-devel automake autoconf bzr bison libtool ncurses5-devel
mkdir /alidata/
cd /alidata/
curl -o percona-toolkit-3.0.12_x86_64.tar.gz "https://www.percona.com/downloads/percona-toolkit/3.0.12/binary/tarball/percona-toolkit-3.0.12_x86_64.tar.gz"
tar -xf percona-toolkit-3.0.12_x86_64.tar.gz
echo "export PATH=\$PATH:/alidata/percona-toolkit-3.0.11/bin" >> /etc/profile
source /etc/profile
bash