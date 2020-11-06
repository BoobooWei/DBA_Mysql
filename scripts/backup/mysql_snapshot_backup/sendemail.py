# coding:utf8
import datetime
import smtplib
from email.mime.text import MIMEText

import sys
reload(sys)
sys.setdefaultencoding('utf8')


_user = "xxx@qq.com"
_pwd  = "xxx"
_to   = "rxxx@126.com"

msg = MIMEText("Test")
msg["Subject"] = "快照备份"
msg["From"]    = _user
msg["To"]      = _to

try:
    s = smtplib.SMTP_SSL("smtp.qq.com", 465)
    s.login(_user, _pwd)
    s.sendmail(_user, _to, msg.as_string())
    s.quit()
    print("Success!")
except smtplib.SMTPException as e:
    print ("Falied,%s" %e)


#if __name__ == '__main__':
#    sub = '数据库快照备份{0}'.format(datetime.datetime.now().strftime("%Y-%m-%d"))
#    content = 'test'
#    api = send_mail(sub, content)
#    api.sendMessage()