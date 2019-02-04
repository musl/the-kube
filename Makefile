RELEASE := v1.13.3
CNI_VERSION := v0.6.0
CRICTL_VERSION := v1.11.1
CT_VER := v0.6.1
CHANNEL := stable

.PHONY: all clean

all: pxe

deps:
	brew install bzip2 xz

clean:
	rm -f ignition.json pxe oem.cpio.gz ct k8s.tar.bz2

ct:
	curl -L https://github.com/coreos/container-linux-config-transpiler/releases/download/$(CT_VER)/ct-$(CT_VER)-x86_64-apple-darwin -o ct
	chmod 0755 ct

ignition.json: ct
	./ct -pretty -strict --files-dir files -in-file config.yaml -out-file ignition.json
	
k8s.tar.bz2:
	mkdir -p build/opt/cni/bin build/opt/bin build/etc/systemd/system/kubelet.service.d
	curl -L "https://github.com/containernetworking/plugins/releases/download/$(CNI_VERSION)/cni-plugins-amd64-$(CNI_VERSION).tgz" | tar -xzC build/opt/cni/bin
	curl -L "https://github.com/kubernetes-incubator/cri-tools/releases/download/$(CRICTL_VERSION)/crictl-$(CRICTL_VERSION)-linux-amd64.tar.gz" | tar -xzC build/opt/bin
	curl -L "https://storage.googleapis.com/kubernetes-release/release/$(RELEASE)/bin/linux/amd64/kubeadm" -o build/opt/bin/kubeadm
	curl -L "https://storage.googleapis.com/kubernetes-release/release/$(RELEASE)/bin/linux/amd64/kubelet" -o build/opt/bin/kubelet
	curl -L "https://storage.googleapis.com/kubernetes-release/release/$(RELEASE)/bin/linux/amd64/kubectl" -o build/opt/bin/kubectl
	curl -sSL "https://raw.githubusercontent.com/kubernetes/kubernetes/$(RELEASE)/build/debs/kubelet.service" | sed "s:/usr/bin:/opt/bin:g" > build/etc/systemd/system/kubelet.service
	curl -sSL "https://raw.githubusercontent.com/kubernetes/kubernetes/$(RELEASE)/build/debs/10-kubeadm.conf" | sed "s:/usr/bin:/opt/bin:g" > build/etc/systemd/system/kubelet.service.d/10-kubeadm.conf
	chmod +x build/opt/bin/* build/opt/cni/bin/*
	tar cjf k8s.tar.bz2 -C build .
	rm -fr build

oem.cpio.gz: ignition.json k8s.tar.bz2
	mkdir -p usr/share/oem
	cp ignition.json usr/share/oem/config.ign
	cp k8s.tar.bz2 usr/share/oem/
	find usr | cpio -o -H newc -O oem.cpio
	rm -fr usr
	gzip oem.cpio

coreos_production_pxe_image.cpio.gz:
	curl -kLO https://$(CHANNEL).release.core-os.net/amd64-usr/current/coreos_production_pxe_image.cpio.gz

coreos_production_pxe.vmlinuz:
	curl -kLO https://$(CHANNEL).release.core-os.net/amd64-usr/current/coreos_production_pxe.vmlinuz

pxe: coreos_production_pxe.vmlinuz coreos_production_pxe_image.cpio.gz oem.cpio.gz 

