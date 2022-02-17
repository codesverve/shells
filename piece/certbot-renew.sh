#!/bin/bash


echo -e "################################################################"
echo -e "#     certbot renew execute [$(date)]     #"
echo -e "################################################################\n"

# service nginx stop
/bin/systemctl stop nginx.service

sleep 2
# 证书续期
certbot renew --force-renew

sleep 1

# service nginx start
/bin/systemctl start nginx.service

echo -e "\n\n\n"

# 需要在定时任务中增加触发脚本配置(crontab -e)
# 每月的11日3点55分执行一次
##########################################################################################
#  25 4 11 */2 * /build/cert/certbot-renew.sh >> /var/log/certbot/cron-exec.log 2>&1 &   #
##########################################################################################

