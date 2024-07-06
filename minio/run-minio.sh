#!/bin/bash

wget https://dl.min.io/server/minio/release/linux-amd64/minio

chmod +x minio 

MINIO_ROOT_USER=用户名 MINIO_ROOT_PASSWORD=密码 nohup ./minio server /data/minio --address ":9000" --console-address ":9001" > nohup.log 2>&1 &
