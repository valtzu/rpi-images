# Minimal Ubuntu rootfs cloud images for arm64

For some reason, [official minimal Ubuntu images](https://cloud-images.ubuntu.com/minimal/daily/focal/current/) only
exist for amd64, so I decided to build my own.

## Download
You can download the latest Ubuntu 20.04 SquashFS image built from this repo [here](https://github.com/valtzu/rpi-images/releases/latest/download/focal-minimal-cloudimg-arm64.squashfs).

## Build

```
apt-get install -y make wget xz-utils qemu-user-static squashfs-tools tar
make
```

## Example usage

### iPXE

```
#!ipxe
dhcp
ntp pool.ntp.org
set root-url http://github.com/valtzu/rpi-images/releases/latest/download/
set cloud-init https://raw.githubusercontent.com/valtzu/pipxe/master/example/cloud-init/
initrd ${root-url}/initrd.img
chain ${root-url}/vmlinuz initrd=initrd.img root=${root-url}/jammy-minimal-cloudimg-arm64.tar.xz ip=dhcp overlayroot=tmpfs:recurse=0 network-config=disabled ds=nocloud-net;s=${cloud-init}
boot
```
