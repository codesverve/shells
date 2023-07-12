import os
import time
import requests
import re
from pathlib import Path

URL = 'https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=2cxxxxx-xxxx-xxxx-xxxx-5cxxxxxxxx9e'
JSON = '{"msgtype": "text", "text": { "mentioned_list": ["@all"], "mentioned_mobile_list": [""], "content": "%s" }}'
# 执行出现异常时进行记录的文件
LOGFILE = '/Users/vince/pycharmProjects/script/logs/quality-monitor-log.log'
# 状态文件
STATE_FILE = '/Users/vince/pycharmProjects/script/logs/monitor-state'
# 被监控的实时更新文件
MONITOR_FILE = 'app.log'
# 被监控的文件所在存放日期滚动更新文件的目录
MONITOR_DIR = '/Users/vince/IdeaProjects/app/src/main/resources'
MSG_NULL_POINTER = '生产环境检测到空指针异常，LOG信息：\n\n%s\n'
EXCEPT_FILTER_PACKAGE = 'com.uetty.'

LOG_START_PATTERN = re.compile('^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{3} \[.*', re.DOTALL)
STACK_PATTERN = re.compile('^[\s]*at .*', re.DOTALL)




def append_to_file(path, lines, addTime):
    path = os.path.abspath(path)
    file = open(path, 'a', encoding="utf-8")
    file.write("\n")
    if addTime:
        time_str = time.strftime('%Y-%m-%d %H:%M:%S')
        if type(lines) is list:
            for i in range(len(lines)):
                if type(lines[i]) is bytes:
                    lines[i] = ('[%s] ' % time_str) + str(lines[i], encoding="UTF-8")
                else:
                    lines[i] = ('[%s] ' % time_str) + str(lines[i])
        else:
            if type(lines) is bytes:
                lines = ('[%s] ' % time_str) + str(lines, encoding="UTF-8")
            else:
                lines = ('[%s] ' % time_str) + str(lines)

    file.writelines(lines)
    file.close()


def write_to_file(path, lines):
    path = os.path.abspath(path)
    file = open(path, 'w', encoding="utf-8")
    file.writelines(lines)
    file.close()


def get_last_read():
    if not os.path.isfile(STATE_FILE):
        return [0, 0]
    dat_file = open(STATE_FILE, 'rb')
    # dat_file.seek(4)
    lines = dat_file.readlines(1024)
    if len(lines) < 2:
        return [0, 0]
    try:
        inode = int(lines[0])
        line = int(lines[1])
        return [inode, line]
    except:
        return [0, 0]


def read_lines_from(path, offset):
    if not os.path.isfile(path):
        return []
    dat_file = open(path, 'rb')
    dat_file.seek(offset)
    return dat_file.readlines(10240)


def find_file_by_inode(dir, inode):
    if inode <= 0:
        return None
    if not os.path.isdir(dir):
        append_to_file(LOGFILE, "dir %s has is not dir" % dir, True)
        return None
    dir_entries = os.scandir(dir)
    file_count = 0
    for entry in dir_entries:
        path = os.path.join(dir, entry.name)
        if os.path.isfile(path):
            file_count += 1
            if inode == entry.inode():
                return {
                    "path": os.path.join(dir, entry.name),
                    "name": entry.name,
                    "inode": entry.inode()
                }
    if file_count == 0:
        append_to_file(LOGFILE, "dir %s has 0 file" % dir, True)
    return None


def get_file_inode(path):
    if not os.path.isfile(path):
        append_to_file(LOGFILE, "file %s not found" % path, True)
        return 0
    ppath = Path(path).parent
    dir_entries = os.scandir(ppath)
    for entry in dir_entries:
        path1 = os.path.join(ppath, entry.name)
        if os.path.isfile(path1):
            if path == path1:
                return entry.inode()

    append_to_file(LOGFILE, "file %s not found" % path, True)
    return 0


def build_stack_msg(lines):
    new_lines = []
    count = 0
    for line in lines:
        match = STACK_PATTERN.fullmatch(line)
        if match is None:
            # 不是 at 堆栈
            new_lines.append(line)
            count = 0
            continue
        # 是 at 堆栈
        if line.find(EXCEPT_FILTER_PACKAGE) >= 0:
            new_lines.append(line)
        else:
            # 是 at 堆栈至少保证有3行
            if count < 3:
                new_lines.append(line)
        count += 1

    return ''.join(new_lines)

def send_wxmsg(msg):
    data = JSON % msg
    data = data.encode("utf-8")
    requests.post(URL, data=data, headers={
        'content-type': 'application/json; charset=utf-8'
    })


def check_log_file(log_file_path, read_count, inode):
    last_log_bucket = []
    isNullPointer = False
    while True:
        lines = read_lines_from(log_file_path, read_count)
        if not lines:
            break
        for line in lines:
            read_count += len(line)
            s = str(line, encoding="UTF-8")
            match = LOG_START_PATTERN.fullmatch(s)
            if match is not None:
                # 进入新的一条日志
                if isNullPointer:
                    logStr = build_stack_msg(last_log_bucket)
                    send_wxmsg(MSG_NULL_POINTER % logStr)
                # 更新为新的日志桶
                last_log_bucket = []
                isNullPointer = False

            last_log_bucket.append(s)
            if s.find('java.lang.NullPointerException:') >= 0:
                isNullPointer = True

    if isNullPointer:
        # 前一个文件读取完毕
        logStr = build_stack_msg(last_log_bucket)
        send_wxmsg(MSG_NULL_POINTER % logStr)

    write_to_file(STATE_FILE, [str(inode), '\n', str(read_count)])


if __name__ == "__main__":

    roll_file_path = os.path.join(MONITOR_DIR, MONITOR_FILE)
    last_read = get_last_read()
    last_file = find_file_by_inode(MONITOR_DIR, last_read[0])

    last_log_bucket = []

    if last_file is not None:
        check_log_file(last_file['path'], last_read[1], last_read[0])

        if roll_file_path == last_file['path']:
            # 前一次读取的文件与当前文件是同一个
            append_to_file(LOGFILE, "roll file %s had read [1]" % roll_file_path, True)
            exit()

    # 由于文件滚动，前一次文件与当前文件不是同一个
    inode = get_file_inode(roll_file_path)
    check_log_file(roll_file_path, 0, inode)
    append_to_file(LOGFILE, "roll file %s had read [2]" % roll_file_path, True)
    
