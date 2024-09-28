#!/usr/bin/env bash

IFNAME=eth0
INTERNAL_IP=`ip -f inet addr show $IFNAME | awk '/inet / {print $2}' | cut -d '/' -f1`
EXTERNAL_IP=`curl -sS ifconfig.me`
REPOSITORY_DIR=`git rev-parse --show-toplevel`
WORKDIR=`cd $(dirname $0);pwd`
K3S_CONFIG_DIR=/etc/rancher/k3s

cat << EOF > $WORKDIR/config.yaml
write-kubeconfig-mode: "0644"
node-name: ${INTERNAL_IP}
node-ip: ${INTERNAL_IP}
node-external-ip: ${EXTERNAL_IP}
node-label:
  - "topology.kubernetes.io/region=guangzhou"
  - "topology.kubernetes.io/zone=tencent-cloud"
EOF

# 初始化目录
[[ -d $K3S_CONFIG_DIR ]] && rm -fr $K3S_CONFIG_DIR; mkdir -p $K3S_CONFIG_DIR

# 复制配置文件
cp -fv $WORKDIR/*.yaml $K3S_CONFIG_DIR/
cp -fvr $WORKDIR/config.yaml.d $K3S_CONFIG_DIR/

# 安装 k3s v1.26
curl -sfL https://rancher-mirror.rancher.cn/k3s/k3s-install.sh | INSTALL_K3S_MIRROR=cn INSTALL_K3S_CHANNEL=v1.26 sh -

# 复制 kubeconfig
CLUSTER_KUBECONFIG="$HOME/.kube/${EXTERNAL_IP}.kubeconfig"
cat $K3S_CONFIG_DIR/k3s.yaml | sed "s/127.0.0.1/$EXTERNAL_IP/g" | sed "s/ default/ $EXTERNAL_IP/g" > $CLUSTER_KUBECONFIG

DEFAULT_CLUSTER_KUBECONFIG="$HOME/.kube/config"
if [[ -r "$DEFAULT_CLUSTER_KUBECONFIG" ]]; then 
    export KUBECONFIG="$DEFAULT_CLUSTER_KUBECONFIG:$CLUSTER_KUBECONFIG"
else
    export KUBECONFIG="$CLUSTER_KUBECONFIG"
fi

echo "KUBECONFIG: $KUBECONFIG"

# 合并 kubeconfig
MREGED_CLUSTER_CONFIG="$HOME/.kube/merged_$(date +%s).kubeconfig"
kubectl config view --flatten > $MREGED_CLUSTER_CONFIG 

# 备份合并前 kubeconfig
BACKUP_CLUSTER_CONFIG="$HOME/.kube/bak_$(date +%s).kubeconfig"
if [[ -r "$DEFAULT_CLUSTER_KUBECONFIG" ]]; then 
    mv $DEFAULT_CLUSTER_KUBECONFIG $BACKUP_CLUSTER_CONFIG 
fi

# 使用新的 KUBECONFIG
mv $MREGED_CLUSTER_CONFIG $DEFAULT_CLUSTER_KUBECONFIG

chmod 0600 $DEFAULT_CLUSTER_KUBECONFIG

unset KUBECONFIG
