#!/bin/bash

set -ex

apt-get update
apt-get install -y cron
apt-get purge -y \
  git \
  snapd \
  vim \
  vim-runtime \
  flash-kernel \
  ubuntu-server \
  ubuntu-standard
apt-get upgrade -y

find /var/log -type f -delete
rm -rf /var/cache/* /var/lib/apt/lists/*
rm /etc/hostname
