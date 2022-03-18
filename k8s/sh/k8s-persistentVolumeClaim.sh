#!/bin/bash

echo ""
echo "PersistentVolumeClaim(PVC)表示持久存储卷申请配置，用于选则使用的PV及相关参数"
echo "程序员定义PersistentVolumeClaim(PV)，运维配置PersistentVolume(PV)"
echo ""
echo "对K8S PersistentVolumeClaims进行操作"
echo "k8s-persistentVolumeClaim [operate] [params]"
echo "    operate: get delete"
echo "    -A 所有namespace，-n name 指定namespace"
echo ""

# kubectl get pvc $@
kubectl $1 PersistentVolumeClaims ${@:2}

echo ""