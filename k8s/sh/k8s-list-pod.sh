#!/bin/bash

echo ""
echo "POD是K8S的一个概念：多个应用部署于同一台宿主机下的多个Docker容器，这些容器作为一个整体成为POD"
echo "POD有独立于容器IP外的IP，POD的IP只在POD内部被访问"
echo "POD是K8S应用部署的最小单元，有多种部署业务类型：Deployment、Job、DaemonSet、StatefulSet"
echo ""
echo "展示K8S部署的pod（[-A]所有namespace，[-n name]指定namespace）"
echo ""

kubectl get pods $@
