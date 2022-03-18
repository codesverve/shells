#!/bin/bash

echo ""
echo "展示K8S集群拥有的宿主机（服务器）节点"
echo ""
kubectl get nodes $@
