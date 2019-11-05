## 1.下载源文件

> https://github.com/kubernetes-incubator/metrics-server/tree/v0.3.5

> 下载 0.3.5版本 0.3.6 版本在安装后有容器创建配置错误,暂时没有解决
```sh
git clone https://github.com/kubernetes-incubator/metrics-server.git
cd metrics-server/deploy/1.8+/
ll
```

## 2.修改其中的metrics-server-deployment.yaml文件（用红色标亮处）
```yaml
...
containers:
- name: metrics-server
  image: registry.cn-hangzhou.aliyuncs.com/google_containers/metrics-server-amd64:v0.3.5 # 变更镜像拉取的位置
  imagePullPolicy: IfNotPresent  # 修改拉取路径
  command:    # 添加这个节点
      - /metrics-server
      - --kubelet-preferred-address-types=InternalIP
      - --kubelet-insecure-tls
  volumeMounts:
  - name: tmp-dir
    mountPath: /tmp
```

## 3.应用设置
```sh
kubectl apply -f .

# 查看集群安装情况
kubectl get po -n kube-system

# 查看集群负载
kubectl top pod
kubectl top node
```