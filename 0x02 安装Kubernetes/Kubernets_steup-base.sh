#!/bin/bash
# 设置系统参数

## 设置主机名
hostnamectl set-hostname=k8s.master

## 关闭SWAP
echo "关闭SWAP..."
sudo sed -i "s/\/swap/#\/swap/g" /etc/fstab
sudo swapoff -a #暂时关闭

## 设置IPv4转发
echo "设置IPv4转发..."
sudo tee /etc/sysctl.d/k8s.conf <<'EOF'
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

sudo modprobe br_netfilter
sudo sysctl -p /etc/sysctl.d/k8s.conf

# 设置APT更新源(阿里源)
echo "设置APT更新源-阿里..."
sudo tee /etc/apt/sources.list <<'EOF'
#阿里云源
deb http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse
EOF

# 设置Kubernets更新源(阿里源)
echo "设置Kubernets更新源-阿里..."
sudo apt-get update && sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
sudo curl -s https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | sudo apt-key add -
sudo tee /etc/apt/sources.list.d/kubernetes.list <<'EOF'
deb https://mirrors.aliyun.com/kubernetes/apt kubernetes-xenial main
EOF

echo "更新系统..."
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get autoremove

echo "安装 kubelet kubeadm kubectl..."
kube_version=1.16.2-00
sudo apt-get install -y kubelet=$kube_version kubeadm=$kube_version kubectl=$kube_version
sudo apt-mark hold kubelet kubeadm kubectl

# 安装Docker
sudo apt-get install -y docker.io

# 设置Docker配置
sudo tee /etc/docker/daemon.json <<'EOF'
{
  "registry-mirrors": ["https://ev6jtc4x.mirror.aliyuncs.com"],
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ],
  "graph":"/home/bob/docker"
}
EOF
sudo gpasswd -a bob docker
# 启动docker
sudo systemctl enable docker.service
sudo systemctl daemon-reload
sudo systemctl restart docker
sudo reboot