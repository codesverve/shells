#!/bin/bash

echo ""
echo "通过yaml文件部署API对象: kebectl create -f app.yaml"
echo ""
kubectl create -f $@

echo ""