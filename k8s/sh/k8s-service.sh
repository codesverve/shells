#!/bin/bash

echo ""
echo "Service是K8S的一个概念：（多台宿主机下的）多个POD作为一个整体成为Service，并自动对内部POD作负载均衡"
echo "Service有独立于POD IP、容器IP外的IP，不同于POD，Service的IP可从Service外部访问"
echo ""
echo "对K8S Service进行操作"
echo "k8s-service [operate] [params]"
echo "    operate: get delete"
echo "    -A 所有namespace，-n name 指定namespace"
echo ""

kubectl $1 services ${@:2}

echo ""