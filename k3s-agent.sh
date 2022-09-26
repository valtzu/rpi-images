#!/bin/bash
set -ex

wget -q -O - https://get.k3s.io | sh -s - \
  agent \
    --server=https://k3s-control-plane:6443

mkdir -p /var/lib/rancher/k3s/agent/containerd
