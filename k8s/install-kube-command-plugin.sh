#!/bin/bash

# 安装K8S命令填充插件

apt install -y bash-completion
apt install -y mlocate

cp /usr/bin/kubectl /usr/bin/kctl
cp /usr/bin/kubeadm /usr/bin/kadm


if [ ! -d /etc/bash_completion.d/source_files ]; then
    mkdir /etc/bash_completion.d/source_files
fi

kubectl completion bash > /etc/bash_completion.d/source_files/source_kubectl
kubeadm completion bash > /etc/bash_completion.d/source_files/source_kubeadm

cp /etc/bash_completion.d/source_files/source_kubectl /etc/bash_completion.d/source_files/source_kctl
cp /etc/bash_completion.d/source_files/source_kubeadm /etc/bash_completion.d/source_files/source_kadm

sed -i "s/kubectl/kctl/g" /etc/bash_completion.d/source_files/source_kctl
sed -i "s/kubeadm/kadm/g" /etc/bash_completion.d/source_files/source_kadm

chmod a+x /etc/bash_completion.d/source_files/source_kubectl
chmod a+x /etc/bash_completion.d/source_files/source_kubeadm

chmod a+x /etc/bash_completion.d/source_files/source_kctl
chmod a+x /etc/bash_completion.d/source_files/source_kadm

echo 'source /usr/share/bash-completion/bash_completion' >> ~/.bashrc

echo 'source /etc/bash_completion.d/source_files/source_kubectl' >> ~/.bashrc
echo 'source /etc/bash_completion.d/source_files/source_kubeadm' >> ~/.bashrc

echo 'source /etc/bash_completion.d/source_files/source_kctl' >> ~/.bashrc
echo 'source /etc/bash_completion.d/source_files/source_kadm' >> ~/.bashrc



