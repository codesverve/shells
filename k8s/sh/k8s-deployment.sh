#!/bin/bash

echo ""
echo "Deployment类型业务应用：该类型可通过RC/RS保证在K8S集群中有预期数量的Pod运行，也可无RC/RS简单部署"
echo ""
echo "对K8S Deployment进行操作"
echo "k8s-deployment [operate] [params]"
echo "    operate: get delete"
echo "    -A 所有namespace，-n name 指定namespace"
echo ""

kubectl $1 deployments ${@:2}

echo ""