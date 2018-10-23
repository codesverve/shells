#! /bin/bash

rs='mysqld is alive'
cmd=`/usr/bin/mysqladmin -uucc -h10.18.139.245 -p'002396' ping`
if [[ "$cmd" == "$rs" ]]
then
echo 'mysql is started'
else 
echo 'no run'
fi



