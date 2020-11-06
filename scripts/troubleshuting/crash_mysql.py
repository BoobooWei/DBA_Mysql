# -*- coding : utf8 -*-
# py_createtable01.py
# auth： booboowei


class mysql_tools():
    def __init__(self, in_file):
        self.b_list = open(in_file).readlines()


    def create_table_test(self, sql_file):
        a_file = open(sql_file, 'w')
        for table in self.b_list:
            string = "create table {} (id int);".format(table)
            a_file.write(string)
        a_file.close()


    def desc_table_test(self, sql_file):
        a_file = open(sql_file, 'w')
        for table in self.b_list:
            string = "desc {};".format(table)
            a_file.write(string)
        a_file.close()


    def create_table_col(self, sql_file):
        a_file = open(sql_file, 'w')
        str_list = []
        for table_col_str in self.b_list:
            table_col_list = table_col_str.split()
            table = table_col_list[0]
            col = int(table_col_list[1])
            string = "create table {} (".format(table)
            str_list.append(string)
            for i in range(1, col + 1):
                if i != col:
                    string = 'id{} int,'.format(i)
                else:
                    string = 'id{} int);'.format(i)
                str_list.append(string)
        for line in str_list:
            a_file.write(line)
        a_file.close()


    def drop_table_test(self,  sql_file):
        a_file = open(sql_file, 'w')
        for table in self.b_list:
            string = "drop table {};".format(table)
            a_file.write(string)
        a_file.close()


    def discard_table_test(self, sql_file):
        a_file = open(sql_file, 'w')
        for table in self.b_list:
            string = "alter table {} discard tablespace;".format(table)
            a_file.write(string)
        a_file.close()


    def import_table_test(self, sql_file):
        a_file = open(sql_file, 'w')
        for table in self.b_list:
            string = "alter table {} import tablespace;".format(table)
            a_file.write(string)
        a_file.close()


if __name__ == '__main__':
    mysql_tools('/alidata/cy_table.txt').create_table_test('/alidata/cy_sql1.sql')
    mysql_tools('/alidata/cy_table.txt').desc_table_test('/alidata/cy_sql2.sql')
    # 根据以上表名和列数生成新的测试表
    mysql_tools('/alidata/cy_table_col.txt').create_table_col('/alidata/cy_sql3.sql')
    mysql_tools('/alidata/cy_table.txt').drop_table_test('/alidata/cy_sql4.sql')
    mysql_tools('/alidata/cy_table.txt').discard_table_test('/alidata/cy_sql5.sql')
    mysql_tools('/alidata/cy_table.txt').import_table_test('/alidata/cy_sql6.sql')