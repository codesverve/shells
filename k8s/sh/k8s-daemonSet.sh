#!/bin/bash

echo ""
echo "DaemonSet类型业务应用：该类型保证在K8S集群中圈定范围的每个Node（服务器/宿主机）都有一个Pod在运行"
echo ""
echo "对K8S DaemonSet进行操作"
echo "k8s-daemonSet [operate] [params]"
echo "    operate: get delete"
echo "    -A 所有namespace，-n name 指定namespace"
echo ""

kubectl $1 daemonSets ${@:2}

echo ""