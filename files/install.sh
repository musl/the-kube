#!/bin/sh -ex

cd /tmp

curl -O http://zero.kube.net:8081/coreos_production_image.bin.bz2
coreos-install -d /dev/mmcblk0 -f /usr/share/oem/image.tar.gz -i /usr/share/oem/install.ign -f coreos_production_image.bin.bz2

mount /dev/mmcblk0p9 /mnt
hostname -s > /mnt/etc/hostname
umount /mnt

reboot
