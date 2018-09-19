jarpath=app.jar
logpath=/var/app.log
testurl=localhost:8080

startCmd="java -jar $jarpath"

timeout=30
lineSec=15

if [ ! -f "$logpath" ];then
echo "" >> $logpath
fi

echo "starting app"
nohup $startCmd >> $logpath 2>&1 &

count=0
while [[ 1 -eq 1 ]];
do
    let floor=$(($count % $lineSec));
    if [[ $count -ge $timeout ]]; then
        echo ""
        echo "failed, time out"
        break;
    fi
    if [[ $(curl -I -m 10 -o /dev/null -s -w %{http_code} $testurl) == '200' ]]; then
        echo ""
        echo "started"
        break;
    fi
    if [[ $floor -eq 0 ]] && [[ $count -ne 0 ]]; then
        echo ""
    fi

    # print dots per second    
    echo -e ".\c"
    sleep 0.5
    echo -e ".\c"
    sleep 0.5

    let count+=1
done

