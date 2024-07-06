#!/usr/bin/python
'''
Created on Jun 1, 2014
 
@author: vince
'''
 
import subprocess
import re
 
# Get process info
psall = subprocess.Popen(['ps', '-caxm', '-orss,comm'], stdout=subprocess.PIPE).communicate()
ps0 = psall[0]
if isinstance(ps0, bytes):
    ps = ps0.decode('utf-8')
else:
    ps = ps0

vm0 = subprocess.Popen(['vm_stat'], stdout=subprocess.PIPE).communicate()[0]
if isinstance(vm0, bytes):
    vm = vm0.decode('utf-8')
else:
    vm = vm0
 
# Iterate processes
processLines = ps.split('\n')
sep = re.compile('[\s]+')
rssTotal = 0 # kB
for row in range(1,len(processLines)):
    rowText = processLines[row].strip()
    rowElements = sep.split(rowText)
    try:
        rss = float(rowElements[0]) * 1024
    except:
        rss = 0 # ignore...
    rssTotal += rss
 
# Process vm_stat
vmLines = vm.split('\n')
sep = re.compile(':[\s]+')
vmStats = {}
for row in range(1,len(vmLines)-2):
    rowText = vmLines[row].strip()
    rowElements = sep.split(rowText)
    vmStats[(rowElements[0])] = int(rowElements[1].strip('\.')) * 4096
 
print('内核锁定内存:\t\t%d MB' % ( vmStats["Pages wired down"]/1024/1024 ))
print('最近活跃内存:\t\t%d MB' % ( vmStats["Pages active"]/1024/1024 ))
print('低活可释内存:\t\t%d MB' % ( vmStats["Pages inactive"]/1024/1024 ))
print('已载待用内存:\t\t%d MB' % ( vmStats["Pages speculative"]/1024/1024 ))
print('完全空闲内存:\t\t%d MB' % ( vmStats["Pages free"]/1024/1024 ))
print('缓存可释内存:\t\t%d MB' % ( vmStats["Pages purgeable"]/1024/1024 ))
print()
print('历史释放内存:\t\t%d MB' % ( vmStats["Pages purged"]/1024/1024 ))
print('重新活跃内存:\t\t%d MB' % ( vmStats["Pages reactivated"]/1024/1024 ))
print('受限压缩内存:\t\t%d MB' % ( vmStats["Pages throttled"]/1024/1024 ))
print('写时复制内存:\t\t%d MB' % ( vmStats["Pages copy-on-write"]/1024/1024 ))
print('全0填充内存:\t\t%d MB' % ( vmStats["Pages zero filled"]/1024/1024 ))
print()
print('进程统计内存:\t\t%.3f MB' % ( rssTotal/1024/1024 ))
