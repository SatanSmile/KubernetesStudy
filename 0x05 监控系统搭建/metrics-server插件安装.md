## 1.下载源文件

```sh
git clone https://github.com/kubernetes-incubator/metrics-server.git
cd metrics-server/deploy/1.8+/
ll
```

## 2.修改其中的metrics-server-deployment.yaml文件（用红色标亮处）
```yaml
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: metrics-server
  namespace: kube-system
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: metrics-server
  namespace: kube-system
  labels:
    k8s-app: metrics-server
spec:
  selector:
    matchLabels:
      k8s-app: metrics-server
  template:
    metadata:
      name: metrics-server
      labels:
        k8s-app: metrics-server
    spec:
      serviceAccountName: metrics-server
      volumes:
      # mount in tmp so we can safely use from-scratch images and/or read-only containers
      - name: tmp-dir
        emptyDir: {}
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