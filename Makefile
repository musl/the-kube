DISK:=/dev/sda
IMG := coreos_production_image.bin.bz2
URL := https://stable.release.core-os.net/amd64-usr/current/$(IMG)

.PHONY: all cfg confirm wipe write

all: $(IMG) wipe write cfg

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
	
write:
	./coreos-install -d $(DISK) -i ignition.json -f $(IMG)

cfg:
	mkdir -p mnt
	mount $(DISK)6 mnt
	cp grub.cfg mnt/grub.cfg
	umount mnt

