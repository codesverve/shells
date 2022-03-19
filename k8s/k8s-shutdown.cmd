

mv -f /etc/kubernetes/manifests ./

systemctl stop kubelet
CONTAIN_IDS=`docker ps|grep k8s_|awk '{print $1}'|xargs`

docker stop $CONTAIN_IDS

CONTAIN_IDS=`docker ps -a|grep k8s_|awk '{print $1}'|xargs`

IMAGE_IDS=`docker ps -a|grep k8s_|awk '{print $2}'|xargs`

docker rm $CONTAIN_IDS

#docker rmi $IMAGE_IDS

echo "检查没有删干净的docker容器与镜像"
