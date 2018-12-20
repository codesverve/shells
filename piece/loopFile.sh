#!/bin/bash

function loop-file() 
{   
    local path=$1
#    echo "path ==> "$path
    if [[ -d $path ]]; then
        cd $path
#        echo "current pwd ==> "`pwd`
        local files=`ls $path`
        local curpwd=`pwd`
        for filename in ${files[*]}
        do  
            loop-file "$curpwd/$filename"
        done;
else
        if [[ -f $path ]]; then
            if [[ `ls -l $path|grep "12月 20"|awk 'END{print NR}'` -gt 0 ]];then
                echo $path
            fi  
        fi  
    fi  
}

loop-file $1
