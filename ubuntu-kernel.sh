#!/bin/bash

set -ex

apt-get update

rm -f /etc/kernel/postinst.d/zz-flash-kernel

# Make sure required tools are there (may be installed already)
apt-get install -y --no-install-recommends \
  initramfs-tools \
  cloud-initramfs-rooturl \
  cloud-initramfs-copymods \
  busybox-initramfs \
  linux-raspi \
  linux-modules-extra-raspi

# Reduce initramfs size by uninstalling unneeded stuff
apt-get purge -y cloud-initramfs-dyn-netconf cryptsetup-initramfs flash-kernel

apt-get autoremove -y
apt-get upgrade -y

sed 's/"$CASPER_GENERATE_UUID"/"always-enable-openssl"/' -i /usr/share/initramfs-tools/hooks/zz-busybox-initramfs
