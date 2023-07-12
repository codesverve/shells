#!/bin/bash

# 拉取镜像
IMAGE_NAME=guacamole/guacd:1.3.0
#docker pull $IMAGE_NAME

#CONTAINERS=`docker ps|grep "${IMAGE_NAME}"|awk '{print $NF}'|xargs`
#if [[ ${CONTAINERS} != '' ]]; then
#    docker stop ${CONTAINERS}
#fi

#CONTAINERS=`docker ps -a|grep "${IMAGE_NAME}"|awk '{print $NF}'|xargs`
#if [[ ${CONTAINERS} != '' ]]; then
#    docker rm ${CONTAINERS}
#fi

# 启动guacd
#docker run --name guacd-lib -p 21000:4822 -d $IMAGE_NAME /usr/local/guacamole/sbin/guacd -b 0.0.0.0 -L trace -f


# 客户端 demo 程序
# 拉取客户端镜像，当前最高版本1.5.2，高版本web好像有点问题
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
# docker run --name guacamole-client --link guacd-lib:guacd -e LOGBACK_LEVEL=debug -e MYSQL_HOSTNAME='rm-j6cgxxxxxxxm8wko.mysql.rds.aliyuncs.com' -e MYSQL_USER=guacamole -e MYSQL_PASSWORD=guacd_pass -e MYSQL_PORT=3306 -e MYSQL_DATABASE='guacamole_aws_db' -v /var/log/guacamole:/usr/local/tomcat/logs -d -p 9090:8080 $IMAGE_NAME


docker run --name guacamole-client --link guacd-lib:guacd --link mysql:mysql -e LOGBACK_LEVEL=debug -e MYSQL_USER=root -e MYSQL_PASSWORD='guacamole_pass' -e MYSQL_DATABASE='guacamole_aws_db' -v /var/log/guacamole:/usr/local/tomcat/logs -d -p 9090:8080 $IMAGE_NAME