#!/bin/bash

set -ex

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y cron
apt-get purge -y \
  git \
  snapd \
  vim \
  vim-runtime \
  ubuntu-server \
  ubuntu-standard
apt-get upgrade -y

apt-get autoremove -y
find /var/log -type f -delete
rm -rf /var/cache/*
