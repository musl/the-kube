RELEASE := v1.13.3
CNI_VERSION := v0.6.0
CRICTL_VERSION := v1.11.1
CT_VER := v0.6.1
CHANNEL := stable

ASSETS := pxe/pxe.ign
ASSETS += pxe/install.ign
ASSETS += pxe/pxelinux.0
ASSETS += pxe/pxelinux.cfg/default
ASSETS += pxe/ldlinux.c32
ASSETS += pxe/k8s.tar.bz2
ASSETS += pxe/coreos_production_pxe.vmlinuz
ASSETS += pxe/coreos_production_pxe.image.cpio.gz
ASSETS += pxe/coreos_production_image.bin.bz2
ASSETS += pxe/oem.cpio.gz

.PHONY: all clean

all: $(ASSETS)

deps:
	brew install bzip2 xz

clean:
	rm -fr bin/ct pxe

bin/ct:
	curl -L https://github.com/coreos/container-linux-config-transpiler/releases/download/$(CT_VER)/ct-$(CT_VER)-x86_64-apple-darwin -o $@
	chmod 0755 ct

pxe/%.ign: %.yaml bin/ct 
	./bin/ct -pretty -strict --files-dir files -in-file $< -out-file $@
	
pxe/pxelinux.0: syslinux/pxelinux.0
	cp $^ $@

pxe/pxelinux.cfg/default: syslinux/pxelinux.cfg/default
	mkdir -p pxe/pxelinux.cfg
	cp $^ $@

pxe/ldlinux.c32: syslinux/ldlinux.c32
	cp $^ $@

pxe/k8s.tar.bz2:
	mkdir -p build/opt/cni/bin build/opt/bin build/etc/systemd/system/kubelet.service.d
	curl -L "https://github.com/containernetworking/plugins/releases/download/$(CNI_VERSION)/cni-plugins-amd64-$(CNI_VERSION).tgz" | tar -xzC build/opt/cni/bin
	curl -L "https://github.com/kubernetes-incubator/cri-tools/releases/download/$(CRICTL_VERSION)/crictl-$(CRICTL_VERSION)-linux-amd64.tar.gz" | tar -xzC build/opt/bin
	curl -L "https://storage.googleapis.com/kubernetes-release/release/$(RELEASE)/bin/linux/amd64/kubeadm" -o build/opt/bin/kubeadm
	curl -L "https://storage.googleapis.com/kubernetes-release/release/$(RELEASE)/bin/linux/amd64/kubelet" -o build/opt/bin/kubelet
	curl -L "https://storage.googleapis.com/kubernetes-release/release/$(RELEASE)/bin/linux/amd64/kubectl" -o build/opt/bin/kubectl
	curl -sSL "https://raw.githubusercontent.com/kubernetes/kubernetes/$(RELEASE)/build/debs/kubelet.service" | sed "s:/usr/bin:/opt/bin:g" > build/etc/systemd/system/kubelet.service
	curl -sSL "https://raw.githubusercontent.com/kubernetes/kubernetes/$(RELEASE)/build/debs/10-kubeadm.conf" | sed "s:/usr/bin:/opt/bin:g" > build/etc/systemd/system/kubelet.service.d/10-kubeadm.conf
	chmod +x build/opt/bin/* build/opt/cni/bin/*
	tar cjf pxe/k8s.tar.bz2 -C build .
	rm -fr build

# Note the `.` between `_pxe` and `image`. Sigh.
pxe/coreos_production_pxe.image.cpio.gz:
	curl -kL https://$(CHANNEL).release.core-os.net/amd64-usr/current/coreos_production_pxe_image.cpio.gz -o $@

pxe/coreos_production_pxe.vmlinuz:
	curl -kL https://$(CHANNEL).release.core-os.net/amd64-usr/current/coreos_production_pxe.vmlinuz -o $@

pxe/coreos_production_image.bin.bz2:
	curl -kL https://$(CHANNEL).release.core-os.net/amd64-usr/current/coreos_production_image.bin.bz2 -o $@

deploy: $(ASSETS)
ifndef remote
	@echo "Please define a remote varabile."
	@echo "For example: \n\tmake pxe remote=user@host:/some/pxe/"
	@echo
	@echo "Hint: make sure to include the trailing slash for rsync."
	@false
endif
	rsync -aPve ssh $^ $(remote)

