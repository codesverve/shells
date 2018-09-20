#!/bin/bash

function check-process-exist()
{
    psStr=$1
    if [[ `ps -aux|grep $psStr|awk 'END{print NR}'` -ge 2 ]]; then 
        echo 'exist';
    else
        echo 'not found';
    fi
}


check-process-exist java

