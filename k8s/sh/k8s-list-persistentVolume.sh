#!/bin/bash

echo ""
echo "PersistentVolume(PV)是K8S定义的持久数据卷抽象"
echo "程序员定义PVC(PersistentVolumeClaim)，运维配置PV"
echo ""
echo "展示K8S部署的PersistentVolume（[-A]所有namespace，[-n name]指定namespace）"
echo ""

# kubectl get pv $@
kubectl get PersistentVolumes $@
