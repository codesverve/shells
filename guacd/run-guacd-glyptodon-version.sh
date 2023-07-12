#!/bin/bash

echo "疑似收费版，有接受条款的选项，由于该版本是目前遇到的兼容性最强的版本，很适合拿来做验证测试"

# 拉取镜像，当前最高版本 latest = 2.8.1
IMAGE_NAME=glyptodon/guacd:latest
docker pull $IMAGE_NAME

CONTAINERS=`docker ps|grep "${IMAGE_NAME}"|awk '{print $NF}'|xargs`
if [[ ${CONTAINERS} != '' ]]; then
    docker stop ${CONTAINERS}
fi

CONTAINERS=`docker ps -a|grep "${IMAGE_NAME}"|awk '{print $NF}'|xargs`
if [[ ${CONTAINERS} != '' ]]; then
    docker rm ${CONTAINERS}
fi

# 启动guacd
docker run --name guacd-lib -p 21000:4822 -e ACCEPT_EULA=Y -d $IMAGE_NAME 