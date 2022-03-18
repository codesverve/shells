#!/bin/bash

echo ""
echo "PersistentVolumeClaim(PVC)表示持久存储卷申请配置，用于选则使用的PV及相关参数"
echo "程序员定义PersistentVolumeClaim(PV)，运维配置PersistentVolume(PV)"
echo ""
echo "展示K8S部署的PersistentVolume（[-A]所有namespace，[-n name]指定namespace）"
echo ""

# kubectl get pvc $@
kubectl get PersistentVolumeClaims $@
