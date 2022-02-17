#!/bin/bash

# jar文件名称
JAR_NAME=ee1-h5-backend.jar
# 后端上传文件目录
UPLOAD_DIR=/opt/ee1/upload
# 后端运行目录
RUN_DIR=/opt/ee1/runtime/h5/java
# 后端备份目录
BACKUP_DIR=/opt/ee1/backup/java
# 后端备份文件名前缀
BACKUP_PREFIX=ee1-h5-backend-
# 后端备份文件名后缀
BACKUP_SUFFIX=.jar
# 日志文件目录
LOG_DIR=/var/log/ee1/h5
# JVM error
JVM_ERROR_FILE=jvm.error

JVM_DUMP_FILE=jvm.dump

# 后端上传jar文件地址
UPLOAD_FILE=$UPLOAD_DIR/$JAR_NAME
# 后端运行jar文件地址
RUN_FILE=$RUN_DIR/$JAR_NAME
# 日志文件地址
# LOG_FILE=$LOG_DIR/backend.log

# 发布环境
PROFILE=prod

# 启动命令增加"-Dspring.profiles.active=$PROFILE"参数的方式覆盖配置文件的值
JAVA_OPT="-Xms512m -XX:+UseG1GC -XX:+HeapDumpOnOutOfMemoryError -XX:ErrorFile=$LOG_DIR/$JVM_ERROR_FILE -XX:HeapDumpPath=$LOG_DIR/$JVM_DUMP_FILE -Dspring.profiles.active=$PROFILE -Dlogback.loghome=$LOG_DIR"
# JAVA_OPT=""

START_CMD="java $JAVA_OPT -jar $RUN_FILE"

# 用于检测启动完毕，端口正常启动的url
ALIVE_DETECT_URL="http://localhost:8083/ee1speakerservice/h5/api/getUserInfo"



# 全局变量
# 程序状态
app_status="stop"
pids=""

cmd=$1
param1=$2

check-dir() {
    if [ ! -d $BACKUP_DIR ]; then
        echo -e "\033[31mBACKUP DIR $BACKUP_DIR NOT EXIST\033[0m"
        exit 1;
    fi;
    
    if [ ! -d $UPLOAD_DIR ]; then
        echo -e "\033[31mUPLOAD DIR $UPLOAD_DIR NOT EXIST\033[0m"
        exit 1;
    fi;
    
    if [ ! -d $RUN_DIR ]; then
        echo -e "\033[31mRUN DIR $RUN_DIR NOT EXIST\033[0m"
        exit 1;
    fi; 
    
    if [ ! -d $LOG_DIR ]; then
        echo -e "\033[31mLOG DIR $LOG_DIR NOT EXIST\033[0m"
        exit 1;
    fi;
}

stop() {
    echo ""

    pids=`ps -ef|grep $JAR_NAME|grep java|awk '{print $2}'`
    if [[ $pids != "" ]]; then
        echo "KILL $pids"
        kill $pids
        for i in {1..5}    # 等待5 * 2秒
        do
            sleep 2
            if [[ $(curl -I -m 10 -o /dev/null -s -w %{http_code} $ALIVE_DETECT_URL) == '000' ]]; then
                break;
            fi
        done

        if [[ $(curl -I -m 10 -o /dev/null -s -w %{http_code} $ALIVE_DETECT_URL) != '000' ]]; then
            echo -e "\033[31mKILL $pids TIMEOUT,PLEASE RETRY LATER\033[0m"
            exit 1
        fi
        
        app_status="stop"
        echo -e "\033[32mAPPLICATION STOPPED\033[0m"
    fi;
}

waiting-start() {
    timeout=60
    lineSec=30
    count=0
    echo "WAITING STARTUP"
    echo ""
    while [[ 1 -eq 1 ]];
    do
        let floor=$(($count % $lineSec));
        if [[ $count -ge $timeout ]]; then
            echo ""
            echo -e "\033[31mSTART UP TIME OUT\033[0m"
            echo -e "\033[32mPLEASE CHECK MANUALLY: curl $ALIVE_DETECT_URL\033[0m"
            break;
        fi
        if [[ $(curl -I -m 10 -o /dev/null -s -w %{http_code} $ALIVE_DETECT_URL) != '000' ]]; then
            echo ""
            echo -e "\033[32mSTARTED\033[0m"
            echo -e "\033[32mLOG DIR -> $LOG_DIR \033[0m"
            break;
        fi
        if [[ $floor -eq 0 ]] && [[ $count -ne 0 ]]; then
            echo ""
        fi

        # print dots per second
        echo -e ".\c"
        sleep 1
        echo -e ".\c"
        sleep 1

        let count+=2
    done

}

start(){ 

    pids=`ps -ef|grep $JAR_NAME|grep java|awk '{print $2}'`
    if [[ $pids != "" ]] && [[ $1 != 'force' ]]; then
        echo "";
        echo -e "\033[31mAPPLICATION ALREADY STARTED\033[0m"
        # 询问是否停止已运行的
        read -r -p "Are you sure continue execute restart?[Y/n]" input;
        case $input in
            [yY][eE][sS]|[yY])
                ;;
            [nN][oO]|[nN])
                exit 0;
        esac
    fi;
    
    if [ ! -f $RUN_FILE ]; then
        echo -e "\033[31mJAR FILE NOT FOUND IN RUN FILE\033[0m"
        echo "RUN FILE -> $RUN_FILE"
        echo ""
        exit 0;
    fi;

    # 备份jar
    local backfile="$BACKUP_DIR/$BACKUP_PREFIX"`date "+%Y-%m-%d-%H-%M"`$BACKUP_SUFFIX
    cp $RUN_FILE $backfile
 
    if [[ $pids != "" ]]; then
        stop 
    fi;
    
    echo ""
    nohup $START_CMD > /dev/null 2>&1 &
    
    waiting-start
}

run() {

    case $cmd in
        [sS][tT][aA][rR][tT])
            # start
            start
            ;;
        [sS][tT][oO][pP])
            # stop
            stop
            ;;
        [rR][eE][sS][tT][aA][rR][tT])
            # restart
            start force
            ;;    
	[lL][oO][gG])
            # show log
	    lastLogFile=$LOG_DIR/`ls $LOG_DIR|grep -E 'ee1\.[0-9]{4}-[0-9]{2}-[0-9]{2}.log'|tail -1`
	    echo "TAIL LOG FILE --> $lastLogFile"
            if [ ! -f $lastLogFile ]; then
                echo -e "\033[31mTODAY LOG NOT FOUND,YOU CAN READ THE LOGS OF THE PAST DAYS\033[0m"
		echo "LOG DIR -> $LOG_DIR"
		echo "GET LOG PATH BY DATE -> ./ee1_h5.sh logpath 2020-06-01"
		exit 0
	    fi;
            tail -f $lastLogFile
            ;;
        [lL][oO][gG][pP][aA][tT][hH])
            # get log path
            if [[ $param1 == "" ]]; then
                logFile=$LOG_DIR/"ee1."`date "+%Y-%m-%d"`".log"
            else 
                logFile=$LOG_DIR/"ee1."$param1".log"
            fi
	    echo $logFile
            ;;
        #[pP][uU][lL][lL])
        #    # git pull
        #    ;;
        *)
            # 未找到命令
            echo -e "\033[31mCOMMAND \"$cmd\" NOT FOUND\033[0m"
            exit 1
    esac
}


check-dir
run


