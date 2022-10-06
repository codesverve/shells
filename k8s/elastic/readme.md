# Elastic、Kibana及日志上传搭建说明

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
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.17.6-linux-x86_64.tar.gz 
tar -xf elasticsearch-7.17.6-linux-x86_64.tar.gz
使用安装包中工具生成ca证书
./elasticsearch-7.17.6/bin/elasticsearch-certutil ca
使用ca证书签发服务端证书，上一条指令默认生成的ca证书名是 elastic-stack-ca.p12
./elasticsearch-7.17.6/bin/elasticsearch-certutil cert --ca elastic-stack-ca.p12
证书可能生成在 /root/elasticsearch-7.17.6/ 目录下，需要通过ls命令自行确认一下
```

使用证书

使用命令将密钥存放在secret中

```
kubectl -n infra-es create secret generic es-cert --from-file=elastic-stack-ca.p12=/root/elasticsearch-7.17.6/elastic-stack-ca.p12 --from-file=elastic-certificates.p12=/root/elasticsearch-7.17.6/elastic-certificates.p12
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
kubectl -n infra-es logs -f $(kubectl get pods -n infra-es | grep es | sed -n 1p | awk '{print $1}' )  | grep "status"
```

使用kubectl存储/管理密码，其他应用可以直接引用该值

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



## 中文分词器插件安装

下载插件

```
下载网页地址
https://github.com/medcl/elasticsearch-analysis-ik/releases
```

解压到plugins文件夹

```
mkdir plugins
mkdir plugins/analysis-ik-7.17.6
cp elasticsearch-analysis-ik-7.17.6.zip plugins/analysis-ik-7.17.6/
cd plugins/analysis-ik-7.17.6
unzip elasticsearch-analysis-ik-7.17.6.zip
rm elasticsearch-analysis-ik-7.17.6.zip
```

最后将该文件夹挂载到plugins目录下



## 安装NFS

一些文件可以放到NFS以便共享挂载到多个节点，k8s使用nfs需要有可用的nfs服务器

**Ubuntu**

> apt install nfs-kernel-server
> mkdir /var/nfs/
> vim /etc/exports
> 添加如下配置
> ```
> /var/nfs/ *(async,insecure,no_root_squash,no_subtree_check,rw)
> ```
> *： 允许所有网段访问，或者使用具体IP来限制
> rw： 具有读写全选
> async：同步写入
> no_root_squash：root用户具有对根目录的完全管理访问权限
> no_subtree_check：不检查父目录的权限
>
> /etc/init.d/nfs-kernel-server restart  # 重启nfs
>
> showmount -e    # 查看是否成功
> mount -t nfs 127.0.0.1:/var/nfs/ /test/   # 本机测试是否成功
> ls /test  # 文件夹内文件与/var/nfs下一致，则说明配置成功
> amount /test  # 取消挂载



## 日志上传

日志上传可以选择使用`Logstash`或者使用`Filebeat`或者两者兼用，`Filebeat`是精简版`Logstash`，缺少自定义filter模块，但使用golang实现相比`Logstash`更加轻量，消耗性能小。常见三种方案：

1. 使用`Logstash`从多个服务器上收集日志，提交到`Elasticsearch`，再由`Kibana`作为数据展示
2. 使用`Filebeat`从多个服务器上收集日志，提交到`Elasticsearch`，再由`Kibana`作为数据展示
3. 使用`Filebeat`从多个服务器上收集日志，提交到`Logstash`，经过`Logstash`完成过滤及数据处理或格式转换后，提交到`Elasticsearch`，再由`Kibana`作为数据展示

比较推荐方案2、3，由于`Logstash`性能开销大，安装到日志收集端较为浪费，`Filebeat`更为合适，选择方案2还是方案3根据是否需要数据处理的具体需求来决定。

**Filebeat安装**

>  #下载
>  wget https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.17.6-linux-x86_64.tar.gz
>
>  #解压
>
>  tar -xf filebeat-7.17.6-linux-x86_64.tar.gz
>  mkdir /usr/local/filebeat-7.17.6
>  cd filebeat-7.17.6-linux-x86_64/
>  mv * /usr/local/filebeat-7.17.6/

**编辑配置文件**

> cd /usr/local/filebeat-7.17.6
> cp filebeat.yml filebeat-prod-log.yml
> vim filebeat-prod-log.yml

修改以下特定配置值

```
- type: log
  id: prod-log
  enabled: true
  path:
    - /var/log/xxxx/*.log

# 修改提交的index，不修改的情况下，默认提交到的index为filebeat-xxxx-xxx
setup:
  ilm:
    enabled: false
  template:
    name: "prod-log"
    pattern: "prod-log-*"

output.elasticsearch:
  hosts: ["192.168.1.2:9200"]
  username: "elastic"
  password: "passxxxx"
  index: "prod-log-%{+yyyy.MM.dd}"

```

接下来，使用守护进程的方式启动filebeat（原因是直接`/usr/local/filebeat -c /usr/local/filebeat-prod-log.yml`的方式启动，只会运行一遍，日志文件一定时间没有新内容就会认为运行完毕自动关闭进程）

> mkdir /usr/local/filebeat/data-prod
>
> mkdir /usr/local/filebeat/logs-prod
>
> vim /usr/lib/systemd/system/filebeat-prod.service

输入以下内容

```
[Unit]
Description=Filebeat is a lightweight shipper for metrics.
Documentation=https://www.elastic.co/products/beats/filebeat
Wants=network-online.target
After=network-online.target

[Service]
Environment="LOG_OPTS=-e"
Environment="CONFIG_OPTS=-c /usr/local/filebeat-7.17.6/filebeat-prod.yml"
Environment="PATH_OPTS=-path.home /usr/local/filebeat-7.17.6 -path.config /usr/local/filebeat-7.17.6 -path.data /usr/local/filebeat-7.17.6/data-prod -path.logs /usr/local/filebeat-7.17.6/logs-prod"
ExecStart=/usr/local/filebeat-7.17.6/filebeat $LOG_OPTS $CONFIG_OPTS $PATH_OPTS
Restart=always

[Install]
WantedBy=multi-user.target
```

然后执行命令

>chmod +x /usr/lib/systemd/system/filebeat-prod.service
>systemctl daemon-reload
>systemctl enable filebeat-prod
>systemctl start filebeat-prod
