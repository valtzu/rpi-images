#!/bin/bash

set -ex

export DEBIAN_FRONTEND=noninteractive
export INITRD=No
apt-get update

# Make sure required tools are there (may be installed already)
apt-get install -y --no-install-recommends initramfs-tools cloud-initramfs-rooturl cloud-initramfs-copymods busybox-initramfs linux-raspi xtables-addons-dkms

sed 's/"$CASPER_GENERATE_UUID"/"always-enable-openssl"/' -i /usr/share/initramfs-tools/hooks/zz-busybox-initramfs

# We have no disk here so..
truncate --size=0 /etc/fstab

# Reduce initramfs size by uninstalling unneeded stuff
apt-get purge -y cloud-initramfs-dyn-netconf cryptsetup-initramfs
