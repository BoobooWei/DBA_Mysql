# centos7
curl -o  rds_backup_extract.sh "http://oss.aliyuncs.com/aliyunecs/rds_backup_extract.sh?spm=a2c4g.11186623.2.6.AUVFzR&file=rds_backup_extract.sh"
wget "https://www.percona.com/downloads/XtraBackup/Percona-XtraBackup-2.4.4/binary/redhat/7/x86_64/percona-xtrabackup-24-2.4.4-1.el7.x86_64.rpm"
yum localinstall percona-xtrabackup-24-2.4.4-1.el7.x86_64.rpm