# coding:utf8


'''
Created on:
@author: BoobooWei
Email: rgweiyaping@hotmail.com
Version: V.18.09.04.0
Description:
    ECS自建MySQL数据库通过阿里快照方式进行数据库自动备份
Help:
pip install --upgrade pip
hash -r
pip install aliyun-python-sdk-core
pip install aliyun-python-sdk-ecs
'''

import sys
import time
import json
import datetime
import logging
from collections import OrderedDict
from aliyunsdkcore.client import AcsClient
from aliyunsdkecs.request.v20140526 import DescribeDisksRequest, CreateSnapshotRequest
from subprocess import *

reload(sys)
sys.setdefaultencoding('utf8')

data = {
    'data': [],
    'code': 0,
    'msg': ''
}

backup_start_time = datetime.datetime.now()
year_time = backup_start_time.strftime('%y')
month_time = backup_start_time.strftime('%m')
day_time = backup_start_time.strftime('%d')



logging.basicConfig(level=logging.DEBUG,
                format='%(asctime)s %(filename)s[line:%(lineno)d] %(levelname)s %(message)s',
                datefmt='%a, %d %b %Y %H:%M:%S',
                filename='/alidata/python_sc/MySQLAutoSnapshotBackup.log',
                filemode='a+')

class Do_Cmd():
    def __init__(self, cmd):
        output = Popen(cmd, shell=True, stdout=PIPE, stderr=PIPE)
        self.out, self.err = output.communicate()
        returncode = output.poll()
        if returncode != 0:
            data['code'] = 1
            data['msg'] = self.err

    def case_a(self):
        return self.out.strip()

    def case_b(self):
        return self.out.strip().split('\n')

    def case_c(self):
        return self.out.strip().split()

    def case_d(self):
        line_list = []
        for line in self.out.strip().split('\n'):
            line_list.append(line.strip().split('\t'))
        return line_list

    def case_e(self):
        line_list = []
        a = []
        for line in self.out.strip().split('\n'):
            line_list.append(line.strip().split('\t'))
        key = line_list[0]
        for value in line_list[1:]:
            a.append(OrderedDict(zip(key, value)))
        return a


class Do_Server():
    def __init__(self, cmd):
        output = Popen(cmd, shell=True, stdout=PIPE, stderr=PIPE)
        returncode = output.wait()
        if returncode != 0:
            data['code'] = 1


class MySQLAPI():
    def __init__(self, bin):
        self.bin = bin

    def stop_mysql(self):
        logging.info('{}\t开始停止数据库'.format(datetime.datetime.now().strftime('%Y-%m-%dT%H:%MZ')))
        shell = '{} stop'.format(self.bin)
        return Do_Cmd(shell).case_a()

    def start_mysql(self):
        logging.info('{}\t开始启动数据库'.format(datetime.datetime.now().strftime('%Y-%m-%dT%H:%MZ')))
        shell = '{} start'.format(self.bin)
        return Do_Server(shell)

    def check_mysql_status(self):
        shell = '{} status'.format(self.bin)
        result = Do_Cmd(shell).case_a()
        if "not running" in result:
            return 1
        else:
            return 0


class AliYunEcsAPI:
    def __init__(self, access_key, access_secret, region):
        self.client = AcsClient(access_key, access_secret, region)

    def get_DescribeSnapshots(self, DiskId, SnapshotId):
        try:
            request = DescribeDisksRequest.DescribeDisksRequest()
            request.set_accept_format('json')
            request.set_action_name('DescribeSnapshots')
            request.set_DiskIds(DiskId)
            request.set_SnapshotId(SnapshotId)
            results = json.loads(self.client.do_action_with_exception(request))
            return results['Snapshots']['Snapshot']
        except Exception as e:
            logging.info(e)
            return {}

    def create_Snapshots(self, DiskId, SnapshotName):
        try:
            request = CreateSnapshotRequest.CreateSnapshotRequest()
            request.set_accept_format('json')
            request.set_action_name('CreateSnapshot')
            request.set_DiskId(DiskId)
            request.set_SnapshotName(SnapshotName)
            results = json.loads(self.client.do_action_with_exception(request))
            return results['SnapshotId']
        except Exception as e:
            logging.info(e)
            return {}

    def check_snapshot_status(self, status):
        """
        快照状态。取值范围：
        progressing：正在创建的快照
        accomplished：创建成功的快照
        failed：创建失败的快照
        all：所有快照状态
        """
        if status == 'accomplished':
            return 0
        else:
            return 1


def MySQLAutoSnapshotBackup():
    """
    # 停服务
    # 创建快照
    # 判断快照是否完成
    # 启动服务
    # 邮件发送
    :return:
    """
    logging.info('{}\t开始快照备份数据库'.format(datetime.datetime.now().strftime('%Y-%m-%dT%H:%MZ')))
    bin = '/alidata/mysql/support-files/mysql.server'
    a = 'Laa'
    k = 'lll'
    r = 'cn-shanghai'
    DiskId = 'd-uf6dnfbgdn5v2uah2gca'
    # 停服务
    mysql = MySQLAPI(bin)
    api = AliYunEcsAPI(a, k, r)
    mysql.stop_mysql()
    if mysql.check_mysql_status() == 1:
        logging.info('{}\t停止数据库服务 OK'.format(datetime.datetime.now().strftime('%Y-%m-%dT%H:%MZ')))
        # 创建快照
        SnapshotName = 'boobootest{}'.format(datetime.datetime.now().strftime('%Y-%m-%dT%H:%MZ'))
        SnapshotId = api.create_Snapshots(DiskId, SnapshotName)
        #SnapshotId = 's-uf63bcx7adgua90e1rym'
        logging.info('{0}\t开始创建快照{1}'.format(datetime.datetime.now().strftime('%Y-%m-%dT%H:%MZ'), SnapshotId))
        # 判断快照是否完成
        while True:
            result = api.get_DescribeSnapshots(DiskId, SnapshotId)
            status = result[0]['Status']
            if api.check_snapshot_status(status) == 0:
                # 快照已完成
                logging.info('{}\t快照创建成功  OK'.format(datetime.datetime.now().strftime('%Y-%m-%dT%H:%MZ')))
                # 启动数据库
                mysql.start_mysql()
                if mysql.check_mysql_status() == 0:
                    logging.info('{}\t启动数据库 OK'.format(datetime.datetime.now().strftime('%Y-%m-%dT%H:%MZ')))
                    # 发送邮件
                    logging.info('{}\tsend email'.format(datetime.datetime.now().strftime('%Y-%m-%dT%H:%MZ')))
                # 退出循环
                break
            else:
                time.sleep(10)
                logging.info('{}\t快照创建中...'.format(datetime.datetime.now().strftime('%Y-%m-%dT%H:%MZ')))
        logging.info('{}\t结束快照备份数据库'.format(datetime.datetime.now().strftime('%Y-%m-%dT%H:%MZ')))


if __name__ == '__main__':
    MySQLAutoSnapshotBackup()
