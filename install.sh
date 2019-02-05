#!/bin/sh -ex

curl -O http://zero.kube.net:8081/coreos_production_image.bin.bz2
coreos-install -d /dev/mmcblk0 -i /usr/share/oem/install.ign -f coreos_production_image.bin.bz2

mount /dev/mmcblk0p9 /mnt
curl -o- http://zero.kube.net:8081/k8s.tar.bz2 | tar -xjC /mnt
hostname -s > /mnt/etc/hostname
umount /mnt

reboot
