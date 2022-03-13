#!/bin/bash

set -ex

export DEBIAN_FRONTEND=noninteractive
apt-get update

# Prevent auto-building initramfs
rm -f /etc/kernel/postinst.d/initramfs-tools /etc/kernel/postinst.d/zz-flash-kernel /etc/initramfs/post-update.d/flash-kernel

# Make sure required tools are there (may be installed already)
apt-get install -y --no-install-recommends initramfs-tools cloud-initramfs-rooturl

# We have no disk here so..
truncate --size=0 /etc/fstab

# Reduce initramfs size by uninstalling unneeded stuff
apt-get purge -y cloud-initramfs-dyn-netconf cryptsetup-initramfs

# Install kernel (excluding recommended tools like flash-kernel)
apt-get install -y --no-install-recommends linux-generic-hwe-20.04-edge
