#!/bin/bash
  
echo ""
echo "通过yaml文件应用（更新）部署API对象: kebectl apply -f app.yaml"
echo ""
kubectl apply -f $@

echo ""