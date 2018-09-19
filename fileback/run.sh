#!/bin/bash

targetFile=/home/vince/eclipse-workspace/zx-plugin-zxtracker/
backdir=/home/vince/backup/code

datetime=`date +"%Y-%m-%d %H:%M:%S"`
date2before=`date -d "-2day" +"%Y-%m-%d %H:%M:%S"`

for file_back in $backdir/*
do
    filename=`basename "$file_back"`
    if [[ $date2before > $filename ]]; then
        echo "rm"
        eval rm -rf \'$file_back\'
    fi
done

mkdir ${backdir}/"${datetime}"

cd ${backdir}/"${datetime}"

mkdir zx-plugin-zxtracker

cp -rf ${targetFile} ./

echo 'backup done'
