#!/bin/bash

echo ""
echo "Deployment类型业务应用：该类型可通过RC/RS保证在K8S集群中有预期数量的Pod运行，也可无RC/RS简单部署"
echo ""
echo "展示K8S运行的Deployment（[-A]所有namespace，[-n name]指定namespace）"
echo ""

kubectl get deployments $@
