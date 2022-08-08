#!/bin/bash

# sudo yum install epel-release
# sudo yum install snapd
# sudo systemctl enable --now snapd.socket
# sudo ln -s /var/lib/snapd/snap /snap
#https://certbot.eff.org/lets-encrypt/centosrhel7-nginx
#sudo snap install core
#sudo snap refresh core
#sudo snap install --classic certbot
#sudo ln -s /snap/bin/certbot /usr/bin/certbot
yum -y install certbot


# standalone方式验证域名归属时，会在服务器启动一个80端口的服务器，由let's encrypt网站发送请求到改该端口来完成验证
# 所以要先关闭nginx防止端口占用
# 验证通过后，打印信息里会包含生成的证书文件的存储目录

PRINT_TIP="\"standalone\" will startup a server which bind port 80 to verify domain, nginx need to temporarily stop\nAfter verified, cert file path will print in console"

echo ""
echo -e "\033[32m""${PRINT_TIP}""\033[0m"

echo ""

# service nginx stop
/usr/local/nginx/nginx -s stop

echo ""
certbot certonly --standalone -n --agree-tos --email "11112222@qq.com" --preferred-challenges http -d www.xxx.com

echo ""
# service nginx start
/usr/local/nginx/nginx -c /usr/local/nginx/nginx.conf


