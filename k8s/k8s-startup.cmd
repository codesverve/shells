

# 启动
kubeadm init --apiserver-advertise-address=0.0.0.0 \
--image-repository=registry.aliyuncs.com/google_containers \
--ignore-preflight-errors=all \
--pod-network-cidr=10.10.0.0/16 \
--service-cidr=10.20.0.0/16

echo ""
echo ""

echo "运行提示中命令："
echo 'mkdir -p $HOME/.kube'
echo 'cp -i /etc/kubernetes/admin.conf $HOME/.kube/config'
echo 'chown $(id -u):$(id -g) $HOME/.kube/config'
echo 'export KUBECONFIG=/etc/kubernetes/admin.conf'

if [ ! -d $HOME/.kube ]; then
  mkdir -p $HOME/.kube
fi

cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
export KUBECONFIG=/etc/kubernetes/admin.conf

# 允许在主结点调度
# kubectl taint node nodeName node-role.kubernetes.io/master-

if [ ! -f ./network-calico.yaml ]; then
  wget https://docs.projectcalico.org/manifests/calico.yaml -O network-calico.yaml
else 
  sleep 8
fi

sleep 1

# 网络插件c
kubectl apply -f network-calico.yaml

