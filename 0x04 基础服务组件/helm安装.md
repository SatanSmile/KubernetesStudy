参考地址: http://www.yuxiaoba.xyz/kubernetes-helmguo-nei-an-zhuang-zhi-nan/

## 下载安装包
```shell
wget https://get.helm.sh/helm-v2.14.4-linux-amd64.tar.gz
tar -zxvf helm-v2.14.4-linux-amd64.tar.gz
mv linux-amd64/helm /usr/local/bin/helm
```

## 创建tiller的serviceaccount和clusterrolebinding
```
kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
```

## 安装helm服务端tiller
```
helm init --service-account tiller --upgrade -i registry.cn-hangzhou.aliyuncs.com/google_containers/tiller:v2.14.0 --stable-repo-url https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts
```

## 为应用程序设置serviceAccount
```
kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
```

## 检查是否安装成功
```
kubectl -n kube-system get pods|grep tiller

helm version
```

## 添加常见的repo
```
helm repo add gitlab https://charts.gitlab.io/
helm repo add aliyun https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts
```
## 常用命令

### 查询charts
> helm search $NAME
### 查看release的列表
> helm ls [--tiller-namespace $TILLER_NAMESPACE]
### 查询package信息
> helm inspect $NAME
### 查询package支持的选项
> helm inspect values $NAME
### 部署chart
> helm install $NAME [--tiller-namespace $TILLER_NAMESPACE] [--namespace $CHART_DEKPLOY_NAMESPACE]
### 删除release
> helm delete $RELEASE_NAME [--purge] [--tiller-namespace $TILLER_NAMESPACE]
### 更新
> helm upgrade --set $PARAM_NAME=$PARAM_VALUE $RELEASE_NAME $NAME [--tiller-namespace $TILLER_NAMESPACE]
### 回滚
> helm rollback $RELEASE_NAME $REVERSION [--tiller-namespace $TILLER_NAMESPACE]

## 删除tiller
```
kubectl get -n kube-system secrets,sa,clusterrolebinding -o name|grep tiller|xargs kubectl -n kube-system delete
kubectl get all -n kube-system -l app=helm -o name|xargs kubectl delete -n kube-system
```