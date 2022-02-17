#!/bin/bash


yum update
# 移除旧版docker库
yum remove docker  docker-common docker-selinux docker-engine
# 安装依赖
yum install -y yum-utils device-mapper-persistent-data lvm2
# 配置源
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
# 可通过该命令查看可安装docker 版本 yum list docker-ce --showduplicates | sort -r
# 安装指定版本docker
# yum install docker-ce-3:20.10.7
# 不指定版本安装最新版docker
yum install docker-ce
