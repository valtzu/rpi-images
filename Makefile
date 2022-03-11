WORKDIR := /tmp/rpi-images

.SECONDEXPANSION:
.PRECIOUS: %-server-cloudimg-arm64-root.tar.xz $(WORKDIR)/%-minimal-cloudimg-arm64 $(WORKDIR)/%-server-cloudimg-arm64-root

$(WORKDIR)/%-minimal-cloudimg-arm64: $(WORKDIR)/$$*-server-cloudimg-arm64-root
	sudo rm -rf $@
	sudo cp -ax $< $@
	sudo cp ./ubuntu-minimal.sh $@
	sudo proot -b /etc/resolv.conf:/etc/resolv.conf! -S $@ -q qemu-aarch64-static -w / /ubuntu-minimal.sh
	sudo rm $@/ubuntu-minimal.sh

%.squashfs: $(WORKDIR)/$$*
	sudo mksquashfs $< $@ -comp xz

%-server-cloudimg-arm64-root.tar.xz:
	wget -q http://cloud-images.ubuntu.com/$*/current/$@

$(WORKDIR)/%-server-cloudimg-arm64-root: $$*-server-cloudimg-arm64-root.tar.xz
	[ -d $@ ] || sudo mkdir -p $@
	sudo tar xf $< -C $@

all: focal-minimal-cloudimg-arm64.squashfs

clean:
	sudo rm -rf *-cloudimg-* $(WORKDIR)/*-cloudimg-*
