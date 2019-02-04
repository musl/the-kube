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
	rm -f *.ign pxe oem.cpio.gz ct k8s.tar.bz2

ct:
	curl -L https://github.com/coreos/container-linux-config-transpiler/releases/download/$(CT_VER)/ct-$(CT_VER)-x86_64-apple-darwin -o ct
	chmod 0755 ct

%.ign: ct %.yaml
	./ct -pretty -strict --files-dir files -in-file config.yaml -out-file $@
	
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

coreos_production_image.bin.bz2:
	curl -kLO https://$(CHANNEL).release.core-os.net/amd64-usr/current/$@

tftproot/oem.cpio.gz: config.ign install.ign oem-install.sh k8s.tar.bz2 coreos_production_image.bin.bz2
	mkdir -p usr/share/oem
	cp $^ usr/share/oem/
	find usr | cpio -o -H newc -O tftproot/oem.cpio
	rm -fr usr
	rm -f $@
	gzip tftproot/oem.cpio

# Note the `.` between `_pxe` and `image`. Sigh.
tftproot/coreos_production_pxe.image.cpio.gz:
	curl -kL https://$(CHANNEL).release.core-os.net/amd64-usr/current/coreos_production_pxe_image.cpio.gz -o $@

tftproot/coreos_production_pxe.vmlinuz:
	curl -kL https://$(CHANNEL).release.core-os.net/amd64-usr/current/coreos_production_pxe.vmlinuz -o $@

pxe: tftproot/coreos_production_pxe.vmlinuz tftproot/coreos_production_pxe.image.cpio.gz tftproot/oem.cpio.gz 
ifndef remote
	@echo "Please define a remote varabile."
	@echo "For example: \n\tmake pxe remote=user@host:/some/tftproot/"
	@echo
	@echo "Hint: make sure to include the trailing slash for rsync."
	@false
endif
	rsync -aPve ssh tftproot/* $(remote)

