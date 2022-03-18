#!/bin/bash

echo ""
echo "Service是K8S的一个概念：（多台宿主机下的）多个POD作为一个整体成为Service，并自动对内部POD作负载均衡"
echo "Service有独立于POD IP、容器IP外的IP，不同于POD，Service的IP可从Service外部访问"
echo ""
echo "展示K8S部署的Service（[-A]所有namespace，[-n name]指定namespace）"
echo ""

kubectl get services $@
