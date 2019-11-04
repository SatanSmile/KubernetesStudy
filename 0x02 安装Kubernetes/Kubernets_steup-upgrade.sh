#!/bin/bash
# 拉取镜像
echo "更新 kubelet kubeadm kubectl..."
sudo apt-get update

kube_version_apt=1.15.4-00
sudo apt-get upgrade kubelet=$kube_version_apt kubeadm=$kube_version_apt kubectl=$kube_version_apt
sudo apt-get autoremove

echo "拉取镜像..."
kube_version=v1.15.4
images_upgrade=(
  kube-apiserver:$kube_version
  kube-controller-manager:$kube_version
  kube-scheduler:$kube_version
  kube-proxy:$kube_version
  pause:3.1
  etcd:3.3.10
  coredns:1.3.2
)

for imageName in ${images_upgrade[@]} ; do
  docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/$imageName
  docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/$imageName k8s.gcr.io/$imageName
  docker rmi registry.cn-hangzhou.aliyuncs.com/google_containers/$imageName
done

echo "升级系统..."
# sudo kubeadm upgrade apply --ignore-preflight-errors=ControlPlaneNodesReady $kube_version
sudo kubeadm upgrade apply $kube_version

echo "清理旧镜像镜像..."
sleep 10
kube_old_version=v1.15.3
images=(
  kube-apiserver:$kube_old_version
  kube-controller-manager:$kube_old_version
  kube-scheduler:$kube_old_version
  kube-proxy:$kube_old_version
)

for imageName in ${images[@]} ; do
  docker rmi k8s.gcr.io/$imageName
done
echo "升级完成"