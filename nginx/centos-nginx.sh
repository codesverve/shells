#!/bin/bash


# git clone https://github.com/AirisX/nginx_cookie_flag_module.git
# wget http://nginx.org/download/nginx-1.21.6.tar.gz

rm -rf nginx-1.21.6
tar -xf nginx-1.21.6.tar.gz

yum -y install pcre-devel
yum -y install openssl openssl-devel

cd nginx-1.21.6 
# --user=nginx --group=nginx
./configure --sbin-path=/usr/local/nginx/nginx --conf-path=/usr/local/nginx/nginx.conf  --pid-path=/usr/local/nginx/nginx.pid --with-stream --with-http_ssl_module --with-mail=dynamic --with-http_gzip_static_module --with-file-aio --with-http_v2_module --with-http_realip_module --with-mail_ssl_module --with-stream_ssl_module --add-dynamic-module=/root/nginx_cookie_flag_module


make

# make install

# /usr/local/nginx/nginx -c /usr/local/nginx/nginx.conf
# /usr/local/nginx/nginx -s stop
# /usr/local/nginx/nginx -s reload
# /usr/local/nginx/nginx -s restart


