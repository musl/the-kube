#!/bin/sh

set -x
set -e

/usr/bin/coreos-install -d /dev/mmcblk0 -f /usr/share/oem/image.tar.gz -i /usr/share/oem/install.ign -f /usr/share/oem/coreos_production_image.bin.bz2
/usr/bin/mount /dev/mmcblk0p9 /mnt
/usr/bin/tar xjvf /usr/share/oem/k8s.tar.bz2 -C /mnt/
/usr/bin/umount /mnt

/usr/bin/rm -f /tmp/coreos-install.sh
/usr/sbin/reboot
