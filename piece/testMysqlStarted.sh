#! /bin/bash

rs='mysqld is alive'
cmd=`/usr/bin/mysqladmin -uucc -h10.18.xxx.xxx -p'xxxxxx' ping`
if [[ "$cmd" == "$rs" ]]
then
echo 'mysql is started'
else 
echo 'no run'
fi



