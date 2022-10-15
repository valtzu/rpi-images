# jammy-minimal-cloudimg-arm64-root Ubuntu rootfs cloud images for arm64

For some reason, [official jammy-minimal-cloudimg-arm64-root Ubuntu images](https://cloud-images.ubuntu.com/jammy-minimal-cloudimg-arm64-root/daily/focal/current/) only
exist for amd64, so I decided to build my own.

## Download
You can download the latest Ubuntu 22.04 rootfs package built from this repo [here](https://github.com/valtzu/rpi-images/releases/latest/download/jammy-jammy-minimal-cloudimg-arm64-root-cloudimg-arm64.tar.xz).

## Build

### On host
```
apt-get install -y make wget xz-utils qemu-user-static tar
make
```

### With Vagrant
```
vagrant up
vagrant ssh -c 'make -C /vagrant'
```

## Example usage

### iPXE boot

For every example, start with this:

```
#!ipxe
dhcp

# Setup clock for TLS cert verification
ntp pool.ntp.org

# cloud-initramfs-rooturl does not support https:// urls. It will still redirect to https and work fine
set root-url http://github.com/valtzu/rpi-images/releases/latest/download

set cloud-init https://raw.githubusercontent.com/valtzu/pipxe/master/example/cloud-init/
initrd ${root-url}/initrd.img
```

#### Ubuntu 22.04
```
# ^-- include the generic stuff first
chain ${root-url}/vmlinuz \
  initrd=initrd.img \
  root=${root-url}/jammy-minimal-cloudimg-arm64-root.tar.xz \
  ip=dhcp \
  overlayroot=tmpfs:recurse=0 \
  network-config=disabled \
  ds=nocloud-net;s=${cloud-init}
```

#### K3S control plane node
```
# ^-- include the generic stuff first
chain ${root-url}/vmlinuz \
  initrd=initrd.img \
  systemd.setenv=K3S_CONTROL_PLANE_HOSTNAME=k3s-control-plane \
  systemd.setenv=K3S_DATASTORE_ENDPOINT="mysql://k3s:secret@tcp(some-external-db:3306)/k3s" \
  systemd.setenv=K3S_TOKEN=some-shared-secret \
  root=${root-url}/jammy-minimal-cloudimg-arm64-root.tar.xz,${root-url}/kernel-modules.tar.xz,${root-url}/k3s-server.tar.xz \
  overlayroot=tmpfs:recurse=0 \
  ip=dhcp \
  cgroup_enable=cpuset cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1 \
  network-config=disabled \
  ds=nocloud-net;s=${cloud-init}
```

`k3s-control-plane` must resolve to an ip outside dhcp range. Kube-vip will use that to create a floating ip for the control plane.

`$K3S_DATASTORE_ENDPOINT` defines persistent kv-storage for control plane, I used external mysql here.

`$K3S_TOKEN` is a token for adding more nodes to the cluster.

#### K3S worker node
```
# ^-- include the generic stuff first
chain ${root-url}/vmlinuz \
  initrd=initrd.img \
  systemd.setenv=K3S_CONTROL_PLANE_HOSTNAME=k3s-control-plane \
  systemd.setenv=K3S_TOKEN=some-shared-secret \
  root=${root-url}/jammy-minimal-cloudimg-arm64-root.tar.xz,${root-url}/kernel-modules.tar.xz,${root-url}/k3s-agent.tar.xz \
  overlayroot=tmpfs:recurse=0 \
  ip=dhcp \
  cgroup_enable=cpuset cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1 \
  network-config=disabled \
  ds=nocloud-net;s=${cloud-init}
```

`$K3S_CONTROL_PLANE_HOSTNAME` should resolve to the control plane.

`$K3S_TOKEN` is the token you defined for the control plane.
