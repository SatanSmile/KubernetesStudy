#!/bin/bash
# 拉取镜像
echo "拉取镜像..."
kube_version=v1.16.2
images=(
  kube-apiserver:$kube_version
  kube-controller-manager:$kube_version
  kube-scheduler:$kube_version
  kube-proxy:$kube_version
  pause:3.1
  etcd:3.3.15-0
  coredns:1.6.2
)

for imageName in ${images[@]} ; do
  docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/$imageName
  docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/$imageName k8s.gcr.io/$imageName
  docker rmi registry.cn-hangzhou.aliyuncs.com/google_containers/$imageName
done

# 初始化集群 （选择flannel ）
# 如果不用上面的函数替换可以添加参数 --image-repository=registry.cn-shenzhen.aliyuncs.com/shuhui

echo "初始化集群..."
HOST_IP=$(ip a | grep inet | grep -v inet6 | grep -v 127 | grep -v 172. | sed 's/^[ \t]*//g' | cut -d ' ' -f2 | cut -d '/' -f1 )
sudo kubeadm init --kubernetes-version=$kube_version --apiserver-advertise-address=$HOST_IP --pod-network-cidr=10.244.0.0/16

#------------------------------------------------------------------------------
#Your Kubernetes control-plane has initialized successfully!

#To start using your cluster, you need to run the following as a regular user:

#  mkdir -p $HOME/.kube
#  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
#  sudo chown $(id -u):$(id -g) $HOME/.kube/config

#You should now deploy a pod network to the cluster.
#Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
#  https://kubernetes.io/docs/concepts/cluster-administration/addons/

#Then you can join any number of worker nodes by running the following on each as root:

#kubeadm join 192.168.10.165:6443 --token a121ec.wn6ys3kigu7a8nyh \
#    --discovery-token-ca-cert-hash sha256:1e302577bf538505f3066c83ed19d3c8f58499184ab9a78c3583ce64497068fc 
#------------------------------------------------------------------------------


echo "配置Kubectl..."
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
export KUBECONFIG=$HOME/.kube/config
echo "export KUBECONFIG=$HOME/.kube/config" | tee -a ~/.bashrc

# 安装网络插件
echo "安装网络插件flannel..."
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

# 无法获取镜像时使用
# wget https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
# sed -i "s/quay.io\/coreos\/flannel/quay-mirror.qiniu.com\/coreos\/flannel/g" kube-flannel.yml
# kubectl apply -f ./kube-flannel.yml

# 查看运行状态
kubectl get all --all-namespaces

# 去除Master污点
kubectl taint nodes --all node-role.kubernetes.io/master-

echo "K8s基础安装完成"