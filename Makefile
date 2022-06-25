WORKDIR := /tmp/rpi-images

.SECONDEXPANSION:
.PRECIOUS: upstream/%-server-cloudimg-arm64-root.tar.xz $(WORKDIR)/%-minimal-cloudimg-arm64 $(WORKDIR)/%-server-cloudimg-arm64-root $(WORKDIR)/%-kernel-cloudimg-arm64

all: dist/focal/minimal.tar.xz dist/jammy/minimal.tar.xz dist/jammy/vmlinuz dist/jammy/initrd.img dist/k3s-arm64-1.24.tar.xz

$(WORKDIR)/%-minimal-cloudimg-arm64: $(WORKDIR)/$$*-server-cloudimg-arm64-root
	sudo rm -rf $@
	sudo cp -ax $< $@
	sudo proot -b /etc/resolv.conf:/etc/resolv.conf! -b ./ubuntu-minimal.sh:/ubuntu-minimal.sh -S $@ -q qemu-aarch64-static -w / /ubuntu-minimal.sh

$(WORKDIR)/%-kernel-cloudimg-arm64: $(WORKDIR)/$$*-server-cloudimg-arm64-root
	sudo rm -rf $@
	sudo cp -ax $< $@
	sudo proot -b /etc/resolv.conf:/etc/resolv.conf! -b ./ubuntu-kernel.sh:/ubuntu-kernel.sh -S $@ -q qemu-aarch64-static -w / /ubuntu-kernel.sh

dist/%/vmlinuz: $(WORKDIR)/$$*-kernel-cloudimg-arm64
	[ -d $* ] || mkdir -p $$(dirname $@)
	sudo cp -aL $</boot/vmlinuz $@
	sudo chown --reference=$$(dirname $@) $@
	chmod 0644 $@

dist/%/initrd.img: $(WORKDIR)/$$*-kernel-cloudimg-arm64
	[ -d $* ] || mkdir -p $$(dirname $@)
	sudo proot -b /etc/resolv.conf:/etc/resolv.conf! -S $< -q qemu-aarch64-static -w / update-initramfs -c -k $(shell readlink $</boot/vmlinuz|sed 's/^vmlinuz-//')
	sudo cp -aL $</boot/initrd.img $@
	sudo chown --reference=$$(dirname $@) $@
	chmod 0644 $@

dist/%/minimal.tar.xz: $(WORKDIR)/$$*-minimal-cloudimg-arm64
	[ -d $* ] || mkdir -p $$(dirname $@)
	sudo tar -cJf $@ -C $< .
	sudo chown --reference=$$(dirname $@) $@
	chmod 0644 $@

dist/k3s-arm64-%.tar.xz: upstream/k3s-arm64-$$*
	[ -d dist ] || mkdir -p dist
	tar --transform 's,^k3s-.*,./usr/local/bin/k3s,' -cpJf $@ -C $$(dirname $<) $$(basename $<)

upstream/k3s-arm64-1.24:
	[ -d upstream ] || mkdir -p upstream
	wget -q 'https://github.com/k3s-io/k3s/releases/download/v1.24.1%2Bk3s1/k3s-arm64' -O $@
	chmod 0755 $@

upstream/%-server-cloudimg-arm64-root.tar.xz:
	[ -d upstream ] || mkdir -p upstream
	wget -q https://cloud-images.ubuntu.com/$*/current/$$(basename $@) -O $@

$(WORKDIR)/%-server-cloudimg-arm64-root: upstream/$$*-server-cloudimg-arm64-root.tar.xz
	[ -d $@ ] || sudo mkdir -p $@
	sudo tar xf $< -C $@

clean:
	sudo rm -rf upstream/ dist/ $(WORKDIR)
