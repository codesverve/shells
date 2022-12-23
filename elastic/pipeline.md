## filebeat上传日志pipeline定义

日志样本

```
2022-12-22 17:28:02.515 [93847140a8c743968e7f1571b2537bc0,http-nio-9211-exec-9] DEBUG com.uetty.test.log.aop.AutoLogAspect [line:49] - [请求开始] alice_user - 根据类型查询字典 ["COMP_TYPE"]
2022-12-22 17:28:02.689 [93847140a8c743968e7f1571b2537bc0,http-nio-9211-exec-9] DEBUG com.uetty.test.service.impl.DictService [line:59] - search dict type COMP_TYPE
2022-12-22 17:28:02.868 [93847140a8c743968e7f1571b2537bc0,http-nio-9211-exec-9] DEBUG com.uetty.test.log.aop.AutoLogAspect [line:59] - [请求结束] timeMillis: 354 ms
```

更新timestamp为日志内的时间为索引排序时间，而不是默认的filebeat上传时间，并提取请求ID（reqId）、日志级别（logLevel）、代码位置（sourceClass:sourceLine）、执行时长（milliseconds）等字段

```
[
  {
    "grok": {
      "field": "message",
      "patterns": [
        "%{TIMESTAMP_ISO8601:timestamp} %{SPACE}\\[%{DATA:reqId},%{DATA}\\] %{SPACE}%{LOGLEVEL:logLevel} %{SPACE}%{NOTSPACE:sourceClass} %{SPACE}\\[line\\:%{NUMBER:sourceLine}\\] %{SPACE}- %{SPACE}%{ANYTEXT}"
      ],
      "pattern_definitions": {
        "ANYTEXT": "(.|\\n)*"
      },
      "ignore_missing": true,
      "ignore_failure": true,
      "description": "common-param-pick"
    }
  },
  {
    "grok": {
      "field": "message",
      "patterns": [
        "%{TIMESTAMP_ISO8601} %{SPACE}\\[%{DATA},%{DATA}\\] %{SPACE}%{LOGLEVEL} %{SPACE}%{NOTSPACE} %{SPACE}\\[line\\:%{NUMBER}\\] %{SPACE}- %{SPACE}\\[请求结束\\]%{SPACE}timeMillis\\:%{SPACE}%{NUMBER:milliseconds:int}%{SPACE}ms"
      ],
      "ignore_missing": true,
      "ignore_failure": true,
      "description": "milliseconds-pick"
    }
  },
  {
    "rename": {
      "field": "@timestamp",
      "target_field": "collect_time"
    }
  },
  {
    "date": {
      "field": "timestamp",
      "formats": [
        "yyyy-MM-dd HH:mm:ss.SSS"
      ],
      "target_field": "@timestamp",
      "timezone": "Asia/Shanghai"
    }
  },
  {
    "remove": {
      "field": [
        "log.flags",
        "_score",
        "_type",
        "agent.type",
        "agent.hostname",
        "host.os.version",
        "host.os.type",
        "host.os.platform",
        "host.os.name",
        "host.os.kernel",
        "host.os.family",
        "host.mac",
        "host.id",
        "host.containerized",
        "agent.version",
        "agent.id",
        "agent.ephemeral_id",
        "ecs.version",
        "host.architecture",
        "host.name",
        "agent.name",
        "input.type",
        "container.id",
        "log.offset"
      ],
      "ignore_missing": true,
      "ignore_failure": true
    }
  }
]
```

