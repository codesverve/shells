import os
import time
import requests

URL = 'https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=2cxxxxxd-xxx8-4xxc-xxex-5xxxxxxxxxe'
JSON = '{"msgtype": "text", "text": { "content": "%s", "mentioned_list": ["@all"], "mentioned_mobile_list": [""] }}'
LOGFILE = '/var/uetty/monitor.txt'
MSG_STARTED = '生产环境已启动'
MSG_STOPPED = '生产环境已停止运行'
DETECT_URL = 'http://127.0.0.1:9101/health/ping'

def get_last_line(inputfile):
    filesize = os.path.getsize(inputfile)
    blocksize = 1024
    dat_file = open(inputfile, 'rb')
    last_line = ""
    if filesize > blocksize:
        maxseekpoint = (filesize // blocksize)
        dat_file.seek((maxseekpoint - 1) * blocksize)
    elif filesize:
        # maxseekpoint = blocksize % filesize
        dat_file.seek(0, 0)
    lines = dat_file.readlines()
    if lines:
        last_line = lines[-1].strip()
    # print "last line : ", last_line
    dat_file.close()
    return str(last_line, 'utf-8')

def get_file_last_line(path):
    path = os.path.abspath(path)
    if not os.path.exists(path):
        print("path %s not exists" % path)
        return None

    return get_last_line(path)

def append_to_file(path, lines):
    path = os.path.abspath(path)
    file = open(path, 'a', encoding="utf-8")
    file.write("\n")
    file.writelines(lines)
    file.close()

def detectRunning():
    res = requests.get(DETECT_URL)
    if res.status_code != 200:
        print("status code %s" % res.status_code)
        return False

    json = res.json()
    print("json -> %s" % json)

    return json['code'] == 20000

def send_wxmsg(msg):
    data = JSON % msg
    data = data.encode("utf-8")
    requests.post(URL, data=data, headers={
        'content-type': 'application/json; charset=utf-8'
    })

# crontab -e
# */1 * * * * python3 /build/app-monitor2.py ; sleep 30; python3 /build/app-monitor2.py

if __name__ == "__main__":
    is_running = detectRunning()
    print("is running %s" % is_running)

    last_line = get_file_last_line(LOGFILE)

    if last_line is not None:
        stat = last_line[20:]
    else:
        stat = 'Stopped'

    time_str = time.strftime('%Y-%m-%d %H:%M:%S')
    stat_str = time_str + (' Running' if is_running else ' Stopped')
    wxmsg = MSG_STARTED if is_running else MSG_STOPPED
    if stat == 'Running':
        if not is_running:
            send_wxmsg(wxmsg)
            append_to_file(LOGFILE, [stat_str])
    else:
        if is_running:
            send_wxmsg(wxmsg)
            append_to_file(LOGFILE, [stat_str])
