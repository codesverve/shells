#!/bin/bash

searchRs=`docker images|grep "10.10.1.1:11111/uetty/yearning"|grep "v3.0.1"`
if [[ $searchRs != "" ]]; then
  echo ""
  echo ""
  TIP="image 10.10.1.1:11111/uetty/yearning:v3.0.1 exist"
  echo -e "\033[31m$TIP\033[0m"
  exit 0
fi

docker build -t 10.10.1.1:11111/uetty/yearning:v3.0.1 .
