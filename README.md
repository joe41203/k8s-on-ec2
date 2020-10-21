2 つのサーバに SSH 後

master

```
$ sudo kubeadm init --pod-network-cidr=10.244.0.0/16
```

worker

```
$ sudo kubeadm join 10.0.101.96:6443 --token xxxx.xxxxxxxxxxxx --discovery-token-ca-cert-hash sha256:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

master で cluster になっているか確認

```
$ kubectl get nodes
```

flannel(CNI) を deploy

```
$ kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/2140ac876ef134e0ed5af15c65e414cf26827915/Documentation/kube-flannel.yml
```

Cluster が ready になる

```
[ec2-user@ip-10-0-101-96 ~]$ kubectl get node
NAME                                             STATUS   ROLES    AGE    VERSION
ip-10-0-101-96.ap-northeast-1.compute.internal   Ready    master   111s   v1.19.3
ip-10-0-103-81.ap-northeast-1.compute.internal   Ready    <none>   64s    v1.19.3
[ec2-user@ip-10-0-101-96 ~]$
```
