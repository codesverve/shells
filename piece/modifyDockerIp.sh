#!/bin/bash

MASK=


params=$(getopt -o "m:" --long mask: -- "$@")
echo $0 $params
eval set -- "$params"
while true; do
    case "$1" in
        -m | --mask)
            MASK=$2
            shift 2
            ;;
        --)
            shift
            break
            ;;
    esac
done

if [[ $MASK == "" ]]; then
    echo "未输入网段"
    exit 1
fi

if [[ `ps -ef|grep docker|awk 'END{print NR}'` -ge 2 ]]; then
    systemctl stop docker
fi

sleep 12

if [[ ! -f /etc/docker/daemon.json ]]; then
    touch /etc/docker/daemon.json
fi

echo -e "{\n\t\"bip\": \"$MASK\"\n}" > /etc/docker/daemon.json

systemctl start docker
