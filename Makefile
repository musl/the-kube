DISK:=/dev/sda
IMG := coreos_production_image.bin.bz2
URL := https://stable.release.core-os.net/amd64-usr/current/$(IMG)

.PHONY: all cfg clean confirm wipe write

all: clean_ignition ignition.json wipe write cfg

clean: clean_ignition
	rm -f $(IMG) ct

clean_ignition:
	rm -f ignition.json 

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
	./ct -pretty -strict -in-file config.yaml -out-file ignition.json
	
write: $(IMG) ignition.json
	./coreos-install -d $(DISK) -i ignition.json -f $(IMG)

cfg:
	mkdir -p mnt
	mount $(DISK)6 mnt
	cp grub.cfg mnt/grub.cfg
	umount mnt

