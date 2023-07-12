#!/bin/bash

docker run --rm guacamole/guacamole:1.3.0 /opt/guacamole/bin/initdb.sh --mysql > initdb.sql