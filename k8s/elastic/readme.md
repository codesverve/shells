# Elastic及Kibana搭建说明

## 前置说明

k8s配置文件中的内容是不完全的

1. 如果要集群方式搭建ES，需要证书，见*生成证书文件*，集群方式ES的k8s配置文件有引用secret中的证书文件
2. ES搭建完毕，需要*设置密码*，Kibana同样也需要使用密码登录ES，Kibana的K8s配置文件中有引用密码secret

## 问题处理

**系统阈值太低问题**

```
max virtual memory areas vm.max_map_count [65530] is too low, increase to at least [262144]
```

查看当前阈值

```
cat /proc/sys/vm/max_map_count
```

临时修改

```
sysctl -w vm.max_map_count=262144
```

永久修改

```
vim /etc/sysctl.conf 
添加一行后保存
vm.max_map_count=262144

执行命令生效
sysctl -p
```

## 生成证书文件

启用密码就得启用xpack，启用xpack就得生成证书用于节点间通信，因此需要事先生成一份p12格式自签名ca证书文件，可以利用elastic自带工具生成证书（可能也可以用openssl生成，没验证过是否格式一致）

生成方式

```
拉取安装包，目的是获取工具
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.15.0-linux-x86_64.tar.gz 
tar -xf elasticsearch-7.15.0-linux-x86_64.tar.gz
使用安装包中工具生成ca证书
./elasticsearch-7.15.0/bin/elasticsearch-certutil ca
使用ca证书签发服务端证书，上一条指令默认生成的ca证书名是 elastic-stack-ca.p12
./elasticsearch-7.15.0/bin/elasticsearch-certutil cert --ca elastic-stack-ca.p12
证书可能生成在 /root/elasticsearch-7.15.0/ 目录下，需要通过ls命令自行确认一下
```

使用证书

使用命令将密钥存放在secret中

```
kubectl -n infra-es create secret generic es-cert --from-file=elastic-stack-ca.p12=/root/elasticsearch-7.15.0/elastic-stack-ca.p12 --from-file=elastic-certificates.p12=/root/elasticsearch-7.15.0/elastic-certificates.p12
```

在`elasticsearch.yml`文件中添加如下几行配置

```
xpack.security.transport.ssl.enabled: true
xpack.security.transport.ssl.verification_mode: certificate 
xpack.security.transport.ssl.keystore.path: certs/elastic-certificates.p12 
xpack.security.transport.ssl.truststore.path: certs/elastic-certificates.p12
```

另外，官网也有说明，如果生成的是pem格式的证书，可以使用另一个配置方式，但需要将ca证书也作为其中一部分配置，前面那种方式不需要配置ca

```
xpack.security.transport.ssl.enabled: true
xpack.security.transport.ssl.verification_mode: certificate 
xpack.security.transport.ssl.key: /home/es/config/node01.key 
xpack.security.transport.ssl.certificate: /home/es/config/node01.crt 
xpack.security.transport.ssl.certificate_authorities: [ "/home/es/config/ca.crt" ]
```

额外说明，证书应该是有有效期的，需要注意一下，具体多久没确认过


## 设置密码

打印查看启动状态

```
kubectl -n infra-es logs -f $(kubectl get pods -n infra-es | grep es | sed -n 1p | awk '{print $1}' )  | grep "state"
```

kubectl 管理密码，其他应用可以直接引用该值

```
kubectl -n infra-es create secret generic es-pw-elastic --from-literal password=k8sESpassw0rd
```

设置ES密码

```
kubectl -n infra-es exec -it $(kubectl get pods -n infra-es | grep es | sed -n 1p | awk '{print $1}') -- elasticsearch-setup-passwords interactive
即进入容器内执行命令
elasticsearch-setup-passwords interactive
进入容器命令
kubectl -n infra-es exec -it es-0 bash
```

使用命令生成存储密码的secret，Kibana的k8s配置文件中将引用此secret，这里使用了密码k8sESpassw0rd

```
kubectl -n infra-es create secret generic es-pw-elastic --from-literal password=k8sESpassw0rd
```


## 检查启动状态

使用如下命令

```
kctl -n infra-es logs es-0 |grep health
```

能够看到如下输出，说明ES启动成功了

```
{"type": "server", "timestamp": "2022-08-15T03:34:49,362Z", "level": "INFO", "component": "o.e.c.r.a.AllocationService", "cluster.name": "es", "node.name": "es-0", "message": "Cluster health status changed from [RED] to [YELLOW] (reason: [shards started [[.kibana_security_session_1][0], [.security-7][0], [.monitoring-es-7-2022.08.14][0]]]).", "cluster.uuid": "3unTUvhzTiGgdPkANHjtTA", "node.id": "lp4DOfxCQeOCQxlwrh1Kpw"  }
{"type": "server", "timestamp": "2022-08-15T03:35:34,572Z", "level": "INFO", "component": "o.e.c.r.a.AllocationService", "cluster.name": "es", "node.name": "es-0", "message": "Cluster health status changed from [YELLOW] to [GREEN] (reason: [shards started [[.monitoring-es-7-2022.08.14][0]]]).", "cluster.uuid": "3unTUvhzTiGgdPkANHjtTA", "node.id": "lp4DOfxCQeOCQxlwrh1Kpw"  }
```
