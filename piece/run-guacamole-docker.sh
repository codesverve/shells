#!/bin/bash

# 拉取镜像
IMAGE_NAME=guacamole/guacd:1.3.0
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
docker run --name guacd-lib -p 19999:4822 -d $IMAGE_NAME


# 客户端 demo 程序
# 拉取客户端镜像
IMAGE_NAME=guacamole/guacamole:1.3.0
docker pull $IMAGE_NAME

CONTAINERS=`docker ps|grep "${IMAGE_NAME}"|awk '{print $NF}'|xargs`
if [[ ${CONTAINERS} != '' ]]; then
    docker stop ${CONTAINERS}
fi

CONTAINERS=`docker ps -a|grep "${IMAGE_NAME}"|awk '{print $NF}'|xargs`
if [[ ${CONTAINERS} != '' ]]; then
    docker rm ${CONTAINERS}
fi

# 客户端程序需要sql文件


# 启动客户端程序
docker run --name guacamole-client --link guacd-lib:guacd -e LOGBACK_LEVEL=debug -e MYSQL_HOSTNAME='xxxx.mysql.rds.aliyuncs.com' -e MYSQL_USER=guacamole -e MYSQL_PASSWORD=xxxx -e MYSQL_PORT=3306 -e MYSQL_DATABASE='guacamole_db' -v /var/log/guacamole:/usr/local/tomcat/logs -d -p 8080:8080 $IMAGE_NAME