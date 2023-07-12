#!/bin/bash

docker run --name mysql -v /data/mysql:/var/lib/mysql -e MYSQL_ROOT_PASSWORD='guacamole_pass' -d mysql:5.7