DISK:=/dev/sdc
OEM_PARTITION:=$(DISK)6
IMG := coreos_production_image.bin.bz2
URL := https://stable.release.core-os.net/amd64-usr/current/$(IMG)

.PHONY: all oem clean confirm wipe write

all: clean_ignition ignition.json wipe write oem

clean_ignition:
	rm -f ignition.json 

clean: clean_ignition
	rm -f $(IMG) ct k8s.tar.bz2

confirm:
	@echo "Here are your block devices:"
	@lsblk
	@echo
	@echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	@echo "I'm about to erase everything on $(DISK)."
	@echo "If that's not what you want, hit CTRL-C in the next 10 seconds!"
	@echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	@sleep 10
	@echo "Doin it!"

wipe: confirm
	wipefs -af $(DISK)

$(IMG):
	curl -kLO "$(URL)"

ct:
	./fetch-ct.sh

ignition.json: ct
	./ct -pretty -strict --files-dir files -in-file config.yaml -out-file ignition.json
	
write: $(IMG) ignition.json
	./coreos-install -d $(DISK) -i ignition.json -f $(IMG)

k8s.tar.bz2:
	./fetch-k8s.sh

oem: k8s.tar.bz2
	mkdir -p mnt
	mount $(OEM_PARTITION) mnt
	cp grub.cfg k8s.tar.bz2 mnt
	umount mnt

