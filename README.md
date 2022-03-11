# Minimal Ubuntu rootfs cloud images for arm64

For some reason, [official minimal Ubuntu images](https://cloud-images.ubuntu.com/minimal/daily/focal/current/) only
exist for amd64, so I decided to build my own.

## Download
You can download the latest Ubuntu 20.04 SquashFS image built from this repo [here](https://github.com/valtzu/rpi-images/releases/latest/download/focal-minimal-cloudimg-arm64.squashfs).

## Build

### Dependencies
```
apt-get install -y make wget xz-utils proot qemu-user-static squashfs-tools tar
```

### Focal Fossa
_Only this image is currently built in the pipeline._
```
make focal-minimal-cloudimg-arm64.squashfs
```

### Jammy Jellyfish
_Note: this did not seem to work 100%, ubuntu-minimal.sh probably needs some adjustments._
```
make jammy-minimal-cloudimg-arm64.squashfs
```
