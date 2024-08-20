# K3s 集群初始化

```bash
REPOSITORY_DIR=$HOME/K3sNotes
# 初始化目录
mkdir -p /etc/rancher/k3s
# 复制配置文件
cp -vf $REPOSITORY_DIR/notes/01_setup_k3s/*.yaml /etc/rancher/k3s/
cp -fvr $REPOSITORY_DIR/notes/01_setup_k3s/config.yaml.d /etc/rancher/k3s/

curl -sfL https://rancher-mirror.rancher.cn/k3s/k3s-install.sh | INSTALL_K3S_MIRROR=cn INSTALL_K3S_CHANNEL=v1.26 sh -
```