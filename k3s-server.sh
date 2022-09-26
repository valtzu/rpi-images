#!/bin/bash
set -ex

wget -q -O - https://get.k3s.io | sh -s - \
  server \
    --tls-san=k3s-control-plane \
    --node-taint=CriticalAddonsOnly=true:NoExecute \
    --disable=local-storage,servicelb,traefik \
    --disable-cloud-controller \
    --write-kubeconfig-mode=644

mkdir -p /var/lib/rancher/k3s/agent/containerd
