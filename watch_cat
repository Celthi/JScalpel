__author__ = 'celhipc'

import requests
import re
import smtplib
# Import the email modules we'll need
from email.mime.text import MIMEText


def ready(page, pattern):

    if re.search(pattern, page):
        return True
    return False

def getWebpae(url):
    r = requests.get(url, verify=False)
    return r.text
def sendEmail(server, emailTo, url):
    '''send email '''
    content = 'The web site you are watch is changed, please visit:' + url
    msg = MIMEText(content)

    msg['Subject'] = "The web site is changed"
    myEmail = ''
    msg['From'] = myEmail
    msg['To'] = emailTo
    pswd =""

    s = smtplib.SMTP(server, 25)
    s.login(myEmail, pswd)
    s.send_message(msg)
    s.quit()

def main():
    url = "https://tp.m-team.cc/preregistered.php"
    pattern = "sorry"
    server = 'smtp.seu.edu.cn'
    emailto = ''
    if not ready(getWebpae(url), pattern):
        sendEmail(server, emailto, url)




if __name__ == '__main__':
    main()
