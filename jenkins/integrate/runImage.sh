#!/bin/bash

DEFAULT_PORT=8080
HOST_VOLUME_HOME=/var/blog

# ---------------- 上面是根据不同程序进行修改的变量 -------------------
# 读取参数
PROFILE=dev
TYPE=master
PORT=
EXT_OPT=
DOCKER_REPO_IP_PORT=
IMAGE_NAME=
TAG=
# option 表示不能跟参数，option: 表示必须跟参数，option:: 表示可选参数， ,作为多个参数名的分隔字符
# -o 是短选项，--long 是长选项
# 短选项传参：可用空格分隔开参数，或无空格直接紧跟参数，可选参数时必须无空格
# 长选项传参：可用空格或等号分隔开参数，可选参数时必须用等号
# 可选参数传参必须用等号，否则认为无参
params=$(getopt -o p:t:P:E:I:T:R: --long port:,type:,ext-opt:,profile:,image:,tag:,repo: -- "$@")
echo $0 $params
eval set -- "$params"
while true; do
    case "$1" in
        -p|--port)
            PORT=$2
            shift 2
            ;;
        -t|--type)
            TYPE=$2
            shift 2
            ;;
        -P|--profile)
            PROFILE=$2
            shift 2
            ;;
        -E|--ext-opt)
            EXT_OPT=$2
            shift 2
            ;;
        -I|--image)
            IMAGE_NAME=$2
            shift 2
            ;;
        -T|--tag)
            TAG=$2
            shift 2
            ;;
        -R|--repo)
            DOCKER_REPO_IP_PORT=$2
            shift 2
            ;;
        --)
            shift
            break
            ;;
    esac
done

echo "IMAGE_NAME $IMAGE_NAME"
# 查询当前所有镜像
existImageIds=`docker images|grep ${IMAGE_NAME}|awk '{print $3}'`
echo "EXISTS IMAGE_IDS `echo ${existImageIds} | xargs`"
for iid in ${existImageIds}; do
    existContainerIds=`docker ps -aq --filter ancestor=$iid`
    if [[ ${existContainerIds} == "" ]]; then
        # 镜像已经没有容器在用了，移除镜像
        docker rmi $iid
    else
        echo "IMAGE ${iid} USED BY CONTAINERS `echo ${existContainerIds} | xargs`"
    fi
done

# 名称带上环境
NAME_PREFIX=${IMAGE_NAME//\//-}"-"$PROFILE

echo "CONTAINER_NAME_PREFIX $NAME_PREFIX"

CONTAINERS=`docker ps|grep ${NAME_PREFIX}|awk '{print $NF}'|xargs`
if [[ ${CONTAINERS} != '' ]]; then
    echo "stop ${CONTAINERS}"
    docker stop ${CONTAINERS}
fi

CONTAINERS=`docker ps -a|grep ${NAME_PREFIX}|awk '{print $NF}'|xargs`
if [[ ${CONTAINERS} != '' ]]; then
    echo "rm ${CONTAINERS}"
    docker rm ${CONTAINERS}
fi

IMAGE_PULL_NAME=${DOCKER_REPO_IP_PORT}/${IMAGE_NAME}:${TAG}
# 拉取新镜像
docker pull ${IMAGE_PULL_NAME}

# 序列：主、从1、从2
if [[ $TYPE != 'master' ]]; then
    SEQ=cluster-$((`docker ps|grep $NAME_PREFIX|wc -l` + 1))
else
    SEQ=master
fi
# 名称带上序列
NAME=$NAME_PREFIX"-"$SEQ

# 文件数据
VOLUME_CONTAINER[${#VOLUME_CONTAINER[@]}]=/opt/runtime/protected_resource
VOLUME_HOST[${#VOLUME_HOST[@]}]=$HOST_VOLUME_HOME/$NAME_PREFIX/protected_resource

# LOG卷地址
VOLUME_CONTAINER[${#VOLUME_CONTAINER[@]}]=/opt/runtime/log_home
# LOG卷地址 映射 HOST
VOLUME_HOST[${#VOLUME_HOST[@]}]=$HOST_VOLUME_HOME/$NAME_PREFIX/$SEQ"-logs"

# 其他卷映射
# VOLUME_CONTAINER[${#VOLUME_CONTAINER[@]}]=
# VOLUME_HOST[${#VOLUME_HOST[@]}]=

if [ ! -d $HOST_VOLUME_HOME ]; then
    mkdir $HOST_VOLUME_HOME
fi

if [ ! -d $HOST_VOLUME_HOME/$NAME_PREFIX ]; then
    mkdir $HOST_VOLUME_HOME/$NAME_PREFIX
fi

if [ ! -d $HOST_VOLUME_HOME/$NAME_PREFIX/$SEQ"-logs" ]; then
    mkdir $HOST_VOLUME_HOME/$NAME_PREFIX/$SEQ"-logs"
fi

if [[ `docker ps|grep $NAME` == '' ]]; then
    if [[ `docker ps -a|grep $NAME` != '' ]]; then
        echo -e "\033[31m$NAME CONTAINER EXISTS, STARTUP CONTAINER\033[0m"
        docker start $NAME
        exit
    fi

    echo -e "\033[31mRUN IMAGE $IMAGE_NAME TO NAME $NAME\033[0m"


    DOCKER_OPT="-d"
    DOCKER_OPT="$DOCKER_OPT --env IMAGE_NAME=$IMAGE_NAME"
    if [[ $PROFILE != '' ]]; then
        DOCKER_OPT="$DOCKER_OPT --env PROFILE=$PROFILE"
    fi
    DOCKER_OPT="$DOCKER_OPT --name=$NAME"

    for (( i=0; i < ${#VOLUME_CONTAINER[@]}; i++)) do
        DOCKER_OPT="$DOCKER_OPT -v ${VOLUME_HOST[i]}:${VOLUME_CONTAINER[i]}"
    done

    if [[ $PORT != '' ]]; then
        # 使用指定的端口
        DOCKER_OPT="$DOCKER_OPT -p $PORT:$DEFAULT_PORT"
    else
        if [[ $TYPE == 'master' ]]; then
            # 使用默认的端口
            DOCKER_OPT="$DOCKER_OPT -p $DEFAULT_PORT:$DEFAULT_PORT"
        else
            # 随机端口
            DOCKER_OPT="$DOCKER_OPT -p $DEFAULT_PORT"
        fi
    fi
    echo "DOCKER_OPT -> $DOCKER_OPT"
    echo "EXT_JAVA_OPT -> $EXT_OPT"
    echo "IMAGE_PULL_NAME -> $IMAGE_PULL_NAME"

    if [[ $EXT_OPT != "" ]]; then
      docker run --env EXT_JAVA_OPT="$EXT_OPT" $DOCKER_OPT -it $IMAGE_PULL_NAME
    else
      docker run $DOCKER_OPT -it $IMAGE_PULL_NAME
    fi
    exit
fi

echo -e "\033[31m$NAME HAD STARTUP\033[0m"

