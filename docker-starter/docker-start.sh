#!/bin/bash

function create_or_start_container()
{
    name=${1}
    img=${2}
    ccmd=`docker ps -a | grep "${name}$" | awk '{print NR}'`
    if [[ ${ccmd} -gt 0 ]];then
    echo "starting ${name}"
    docker restart ${name}
    else
    echo "create ${name}"
    docker run -d --name ${name} ${img}
    fi
}

tagname=mytest
imgname=hello
create_or_start_container $tagname $imgname

