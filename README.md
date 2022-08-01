# Minimal Ubuntu rootfs cloud images for arm64

For some reason, [official minimal Ubuntu images](https://cloud-images.ubuntu.com/minimal/daily/focal/current/) only
exist for amd64, so I decided to build my own.

## Download
You can download the latest Ubuntu 22.04 rootfs package built from this repo [here](https://github.com/valtzu/rpi-images/releases/latest/download/jammy-minimal-cloudimg-arm64.tar.xz).

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

```
#!ipxe
dhcp

# Setup clock for TLS cert verification
ntp pool.ntp.org

# cloud-initramfs-rooturl does not support https:// urls. It will still redirect to https and work fine
set root-url http://github.com/valtzu/rpi-images/releases/latest/download

set cloud-init https://raw.githubusercontent.com/valtzu/pipxe/master/example/cloud-init/

initrd ${root-url}/initrd.img
chain ${root-url}/vmlinuz initrd=initrd.img xt_SYSRQ.password=unsafe root=${root-url}/jammy-minimal-cloudimg-arm64.tar.xz ip=dhcp overlayroot=tmpfs:recurse=0 network-config=disabled ds=nocloud-net;s=${cloud-init}
```

### Reboot via UDP

```shell
./reboot <ip> <password>
# f.e.
./reboot 192.168.2.2 unsafe
```
