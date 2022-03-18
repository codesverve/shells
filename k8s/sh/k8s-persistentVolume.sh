#!/bin/bash

echo ""
echo "PersistentVolume(PV)是K8S定义的持久数据卷抽象"
echo "程序员定义PVC(PersistentVolumeClaim)，运维配置PV"
echo ""
echo "对K8S PersistentVolume进行操作"
echo "k8s-persistentVolume [operate] [params]"
echo "    operate: get delete"
echo "    -A 所有namespace，-n name 指定namespace"
echo ""

# kubectl get pv $@
kubectl $1 PersistentVolumes ${@:2}

echo ""