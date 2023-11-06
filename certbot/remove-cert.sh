#!/bin/bash

echo ${1}
if [[ ${1} == "" ]]; then
  echo "error params ${1}"
  exit 1
fi
echo "remove renewal archive live"
rm -rf /etc/letsencrypt/renewal/${1}.conf
rm -rf /etc/letsencrypt/archive/${1}
rm -rf /etc/letsencrypt/live/${1}