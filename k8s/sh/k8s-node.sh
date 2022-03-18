#!/bin/bash

echo ""
echo "对K8S集群的宿主机（服务器）节点进行操作"
echo "k8s-node [operate] [params]"
echo "    operate: get label"
echo "    -A 所有namespace，-n name 指定namespace"
echo ""
kubectl $1 nodes ${@:2}

echo ""