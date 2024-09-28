#!/usr/bin/env bash

# helm -n kube-system upgrade -i metallb ./metallb/metallb-0.13.12.tgz -f ./metallb/values.yaml

# helm -n longhorn-system upgrade -i longhorn ./storageclass/longhorn-1.6.0.tgz \
#     -f ./storageclass/longhorn/values.yaml \
#     --create-namespace \
#     --set ingress.host longhorn.weihaostudio.com

# helm -n kube-system upgrade -i apisix ./apisix -f ./apisix/values.yaml

# 安装 CertManager
helm -n certificate upgrade -i cert-manager ./k8s/cert-manager \
    --create-namespace \
    --set installCRDs=true

## Install alidns-webhook to cert-manager namespace.
# Github: https://github.com/wjiec/alidns-webhook
helm -n certificate upgrade -i alidns-webhook k8s/alidns-webhook/charts/alidns-webhook \
    --create-namespace \
    --set groupName=acme.weihaostudio.com \
    --set certManager.serviceAccountName=cert-manager-controller

## 注册 ALIDNS KeySecret 到 Secret

## 创建 Issuer
kubectl apply -f ./cert-manager/clusterissuer.yaml
kubectl apply -f ./cert-manager/certificate.yaml