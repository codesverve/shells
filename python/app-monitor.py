import psutil
import os
import docker
import time
import requests

URL = 'https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=2c2xxxx-xxxxxxxxx-xxxx'
JSON = '{"msgtype": "text", "text": { "content": "%s", "mentioned_list": ["@all"], "mentioned_mobile_list": [""] }}'
LOGFILE = '/var/uetty/monitor.txt'
CONTAINER_NAME = 'uetty-monit-prod-master'
JAVA_PS_DETECT = ['java', '-Ddocker.image.name=uetty/monit', '-Dspring.profiles.active=prod']
MSG_STARTED = '生产环境已启动'
MSG_STOPPED = '生产环境已停止运行'

def has_container(name):
    client = docker.from_env()
    containers = client.containers.list()
    name = "/" + name
    for c in containers:
        if c.attrs.get('Name') == name:
            return True
    return False

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

def all_find(args, find_args):
    for f_arg in find_args:
        find = False
        for arg in args:
            if arg.find(f_arg) != -1:
                find = True
                break
        if not find:
            return False
    return True

def java_process_running(find_args):
    pids = psutil.pids()
    for pid in pids:
        p = psutil.Process(pid)
        # print(p.cmdline())
        cl = p.cmdline()
        if all_find(cl, find_args):
            return True
    return False
        # print(p.memory_info())

def append_to_file(path, lines):
    path = os.path.abspath(path)
    file = open(path, 'a', encoding="utf-8")
    file.write("\n")
    file.writelines(lines)
    file.close()

def send_wxmsg(msg):
    data = JSON % msg
    data = data.encode("utf-8")
    requests.post(URL, data=data, headers={
        'content-type': 'application/json; charset=utf-8'
    })

if __name__ == "__main__":
    container_running = has_container(CONTAINER_NAME)
    find_process = java_process_running(find_args=JAVA_PS_DETECT)

    last_line = get_file_last_line(LOGFILE)

    if last_line is not None:
        stat = last_line[20:]
    else:
        stat = 'Stopped'

    time_str = time.strftime('%Y-%m-%d %H:%M:%S')
    is_running = container_running and find_process
    stat_str = time_str + (' Running' if is_running else ' Stopped')
    wxmsg = MSG_STARTED if is_running else MSG_STOPPED
    if stat == 'Running':
        print('eq running')
        if not is_running:
            send_wxmsg(wxmsg)
            append_to_file(LOGFILE, [stat_str])
    else:
        print('neq running')
        if is_running:
            send_wxmsg(wxmsg)
            append_to_file(LOGFILE, [stat_str])
