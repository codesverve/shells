#!/bin/bash

# 拉取镜像，非官方版本，支持高版本openssh（8.7以上）linux服务器
IMAGE_NAME=kierenhamps/guacd:1.4.0

# docker pull $IMAGE_NAME

CONTAINERS=`docker ps|grep "${IMAGE_NAME}"|awk '{print $NF}'|xargs`
if [[ ${CONTAINERS} != '' ]]; then
    docker stop ${CONTAINERS}
fi

CONTAINERS=`docker ps -a|grep "${IMAGE_NAME}"|awk '{print $NF}'|xargs`
if [[ ${CONTAINERS} != '' ]]; then
    docker rm ${CONTAINERS}
fi

# 启动guacd
docker run --name guacd-lib -p 21000:4822 -e disable-glyph-caching=true -d $IMAGE_NAME