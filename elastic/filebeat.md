## Filebeat

1. 编写filebeat[配置文件](./filebeat-app-test.yml)

2. 编写filebeat[系统服务文件](./filebeat-app-test.service)，设置为自动启动（Restart=always），文件移动到`/lib/systemd/system/`目录

3. 加载并启动服务

   ```
   systemctl daemon-reload
   systemctl enable filebeat-app-test
   systemctl start filebeat-app-test
   ```

4. 查看状态

   ```
   systemctl status filebeat-app-test
   ps -ef|grep filebeat-app-test
   ```

5. ES上配置索引匹配范围

   ```
   1. Stack Management -> Index Management 查看是否有filebeat配置的索引的数据成功上传上来
   2. Stack Management -> Index Patterns -> Create Index Pattern，配置索引范围（name: app-api-test-*，timestamp：@timestamp）
   ```

6. ES上配置生命周期及Ingest Pipeline规则

7. ES上Discovery中查看索引匹配范围是否成功显示出来