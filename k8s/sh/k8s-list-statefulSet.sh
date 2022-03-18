#!/bin/bash

echo ""
echo "StatefulSet类型业务应用：该类型保证Pod在K8S集群中固定的Node（服务器/宿主机）运行"
echo ""
echo "展示K8S部署的StatefulSet（[-A]所有namespace，[-n name]指定namespace）"
echo ""

kubectl get statefulSets $@
