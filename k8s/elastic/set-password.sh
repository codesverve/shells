#!/bin/bash 

# 打印查看启动状态
# kubectl -n infra-es logs -f $(kubectl get pods -n infra-es | grep es | sed -n 1p | awk '{print $1}' )  | grep "state"


# kubectl -n infra-es exec -it es-0 bash 进入容器内部
# 执行 elasticsearch-setup-passwords interactive 设置密码
kubectl -n infra-es exec -it $(kubectl get pods -n infra-es | grep es | sed -n 1p | awk '{print $1}') -- elasticsearch-setup-passwords interactive


# kubectl 管理密码，其他应用可以直接引用该值
# kubectl -n infra-es create secret generic es-pw-kibana-system --from-literal username=kibana_system --from-literal password=k8sESpassw0rd