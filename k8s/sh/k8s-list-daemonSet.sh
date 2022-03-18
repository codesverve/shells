#!/bin/bash

echo ""
echo "DaemonSet类型业务应用：该类型保证在K8S集群中圈定范围的每个Node（服务器/宿主机）都有一个Pod在运行"
echo ""
echo "展示K8S部署的DaemonSet（[-A]所有namespace，[-n name]指定namespace）"
echo ""

kubectl get deployments $@
