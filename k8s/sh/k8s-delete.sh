#!/bin/bash
  
echo ""
echo "通过yaml文件删除部署API对象: kebectl delete -f app.yaml"
echo ""
kubectl delete -f $@

echo ""