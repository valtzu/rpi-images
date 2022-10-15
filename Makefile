WORKDIR := /tmp/rpi-images
CHROOT_LAYER := $(WORKDIR)/chroot-layer
INSTALL_K3S_VERSION := v1.24.3+k3s1

SHELL = /bin/bash

.SECONDEXPANSION:
.PRECIOUS: upstream/%-server-cloudimg-arm64-root.tar.xz $(WORKDIR)/%-minimal-cloudimg-arm64 $(WORKDIR)/%-server-cloudimg-arm64-root $(WORKDIR)/%-kernel-cloudimg-arm64 $(WORKDIR)/%-k3s-server $(WORKDIR)/%-k3s-agent

all: dist/jammy/minimal.tar.xz dist/jammy/vmlinuz dist/jammy/kernel-modules.tar.xz dist/jammy/initrd.img dist/jammy/config dist/jammy/iscsi.tar.xz dist/jammy/k3s-server.tar.xz dist/jammy/k3s-agent.tar.xz k3s/usr/local/bin/k3s

k3s/usr/local/bin/k3s:
	wget https://github.com/k3s-io/k3s/releases/download/$(INSTALL_K3S_VERSION)/k3s-arm64 -O $@
	chmod a+x $@

$(CHROOT_LAYER):
	[ -d $$(dirname $@) ] || mkdir -p $$(dirname $@)
	sudo rm -rf $@
	sudo cp -af chroot-layer $$(dirname $@)
	sudo mkdir -p $@/usr/bin
	sudo cp -af /usr/bin/qemu-aarch64-static $@/usr/bin/
	sudo chown -R 0:0 $@

$(WORKDIR)/%-minimal-cloudimg-arm64: $(WORKDIR)/$$*-server-cloudimg-arm64-root $(CHROOT_LAYER)
	sudo rm -rf $@
	sudo ./run-in-chroot-overlay $(CHROOT_LAYER):$< $@-layer $@-merged bash -l < ./ubuntu-minimal.sh
	sudo mount -t overlay overlay -olowerdir=$@-layer:$< $@-merged
	sudo cp -ax $@-merged $@-merged.full
	sudo umount $@-merged
	sudo rm -rf $@-layer
	sudo mv $@-merged.full $@

$(WORKDIR)/%-kernel-cloudimg-arm64: $(WORKDIR)/$$*-server-cloudimg-arm64-root $(CHROOT_LAYER)
	sudo rm -rf $@
	sudo ./run-in-chroot-overlay $(CHROOT_LAYER):$< $@ $@-merged bash -l < ./ubuntu-kernel.sh

$(WORKDIR)/%-k3s-server: $(WORKDIR)/$$*-minimal-cloudimg-arm64 $(CHROOT_LAYER) k3s/usr/local/bin/k3s
	sudo rm -rf $@
	sudo cp -a ./k3s $@
	sudo mkdir -p $@/var/lib/rancher/k3s/server
	sudo cp -a ./k3s-server/* $@/
	sudo chown 0:0 -R $@

$(WORKDIR)/%-k3s-agent: $(WORKDIR)/$$*-minimal-cloudimg-arm64 $(CHROOT_LAYER) k3s/usr/local/bin/k3s
	sudo rm -rf $@
	sudo cp -a ./k3s $@
	sudo cp -a ./k3s-agent/* $@/
	sudo chown 0:0 -R $@

dist/%/vmlinuz: $(WORKDIR)/$$*-kernel-cloudimg-arm64
	[ -d $$(dirname $@) ] || mkdir -p $$(dirname $@)
	sudo cp -aL $</boot/vmlinuz $@
	sudo chown --reference=$$(dirname $@) $@
	chmod 0644 $@

dist/%/config: $(WORKDIR)/$$*-kernel-cloudimg-arm64
	[ -d $$(dirname $@) ] || mkdir -p $$(dirname $@)
	cp -a $(wildcard $</boot/config-*) $@
	sudo chown --reference=$$(dirname $@) $@

dist/%/kernel-modules.tar.xz: $(WORKDIR)/$$*-kernel-cloudimg-arm64
	[ -d $$(dirname $@) ] || mkdir -p $$(dirname $@)
	tar -C $< -cpJf $@ ./usr/lib/modules
	sudo chown --reference=$$(dirname $@) $@
	chmod 0644 $@

dist/%/initrd.img: $(WORKDIR)/$$*-kernel-cloudimg-arm64 $(CHROOT_LAYER)
	[ -d $$(dirname $@) ] || mkdir -p $$(dirname $@)
	sudo ./run-in-chroot-overlay $(CHROOT_LAYER):$<:$(WORKDIR)/$*-server-cloudimg-arm64-root $<-initrd $<-initrd-merged mkinitramfs -v -o /boot/initrd.img $(shell readlink $</boot/vmlinuz|sed 's/^vmlinuz-//')
	sudo cp -aL $<-initrd/boot/initrd.img $@
	sudo chown --reference=$$(dirname $@) $@
	chmod 0644 $@

dist/%/minimal.tar.xz: $(WORKDIR)/$$*-minimal-cloudimg-arm64
	[ -d $$(dirname $@) ] || mkdir -p $$(dirname $@)
	sudo tar -cJf $@ -C $< .
	sudo chown --reference=$$(dirname $@) $@
	chmod 0644 $@

dist/%/k3s-server.tar.xz: $(WORKDIR)/$$*-k3s-server
	[ -d $$(dirname $@) ] || mkdir -p $$(dirname $@)
	sudo tar -cJf $@ -C $< .
	sudo chown --reference=$$(dirname $@) $@
	chmod 0644 $@

dist/%/k3s-agent.tar.xz: $(WORKDIR)/$$*-k3s-agent
	[ -d $$(dirname $@) ] || mkdir -p $$(dirname $@)
	sudo tar -cJf $@ -C $< .
	sudo chown --reference=$$(dirname $@) $@
	chmod 0644 $@

dist/%/iscsi.tar.xz: iscsi-layer
	[ -d $$(dirname $@) ] || mkdir -p $$(dirname $@)
	sudo tar -cJf $@ -C $< .
	sudo chown --reference=$$(dirname $@) $@
	chmod 0644 $@

upstream/%-server-cloudimg-arm64-root.tar.xz:
	[ -d upstream ] || mkdir -p upstream
	wget -q https://cloud-images.ubuntu.com/$*/current/$$(basename $@) -O $@

$(WORKDIR)/%-server-cloudimg-arm64-root: upstream/$$*-server-cloudimg-arm64-root.tar.xz
	[ -d $@ ] || sudo mkdir -p $@
	sudo tar xf $< -C $@

clean:
	sudo rm -rf dist/ $(WORKDIR)
