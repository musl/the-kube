#!/bin/sh
mkdir -p /tmp/oemfs
mount /dev/sdc6 /tmp/oemfs
cp /vagrant/ignition.json /tmp/oemfs/config.ign
umount /tmp/oemfs
rm -rf /tmp/oemfs
