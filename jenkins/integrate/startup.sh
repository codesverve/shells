#!/bin/bash

BASE_DIR=`cd $(dirname $0)/./; pwd`
APP=app

# 读取参数
PAUSE_FLAG=
params=$(getopt -o P: --long pause,profile: -- "$@")
echo $0 $params
eval set -- "$params"
while true; do
    case "$1" in
        --pause)
            PAUSE_FLAG=yes
            shift 1
            ;;
        -P|--profile)
            export PROFILE=$2
            shift 2
            ;;
        --)
            shift
            break
            ;;
    esac
done

echo $BASE_DIR

JAVA_OPT=""
if [[ ${PORT} != '' ]]; then
    JAVA_OPT="$JAVA_OPT -Dserver.port=$PORT"
fi
JAVA_OPT="$JAVA_OPT -Dspring.profiles.active=${PROFILE}"
JAVA_OPT="$JAVA_OPT -Ddocker.image.name=$IMAGE_NAME"
JAVA_OPT="$JAVA_OPT -Dblog.log.home=${BASE_DIR}/log_home"
JAVA_OPT="$JAVA_OPT -Dlog4j2.formatMsgNoLookups=true"
if [[ ${EXT_JAVA_OPT} != '' ]]; then
    JAVA_OPT="$JAVA_OPT $EXT_JAVA_OPT"
fi
JAVA_OPT="$JAVA_OPT -jar ${BASE_DIR}/$APP.jar"


nohup java ${JAVA_OPT} >> /dev/null 2>&1 &

if [[ $PAUSE_FLAG != '' ]]; then
    # 不退出命令
    exec /bin/bash
fi