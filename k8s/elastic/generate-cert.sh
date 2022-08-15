#!/bin/bash 

# 拉取安装包，目的是获取工具

if [ ! -f ./elasticsearch-7.15.0-linux-x86_64.tar.gz ]; then
  wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.15.0-linux-x86_64.tar.gz
fi
if [ -d ./elasticsearch-7.15.0 ]; then
  rm -rf elasticsearch-7.15.0
fi

tar -xf elasticsearch-7.15.0-linux-x86_64.tar.gz

# 使用安装包中工具生成ca证书
./elasticsearch-7.15.0/bin/elasticsearch-certutil ca

# 使用ca证书签发服务端证书，上一条指令默认生成的ca证书名是 elastic-stack-ca.p12
./elasticsearch-7.15.0/bin/elasticsearch-certutil cert --ca elastic-stack-ca.p12

# 证书可能生成在 /root/elasticsearch-7.15.0/ 目录下，需要通过ls命令自行确认一下
