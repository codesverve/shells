#!/bin/bash

# 拉取镜像，当前最高版本1.5.2，1.5以上版本的guacd要求docker环境还是操作系统环境比较新的版本好像
# 当前低版本的 1.3.0、1.4.0基于的openssh是低版本的，由于高版本openssh服务器，不支持某些加密算法，部分linux服务器没法正常连接，得改用另一个私人编译版本的guacd
#IMAGE_NAME=guacamole/guacd:1.3.0
IMAGE_NAME=linuxserver/guacd

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
docker run --name guacd-lib -p 21000:4822 -e disable-glyph-caching=true -v /var/virtual-disk/.ssh:/home/guacd/.ssh -d $IMAGE_NAME /usr/local/guacamole/sbin/guacd -b 0.0.0.0 -L trace -f