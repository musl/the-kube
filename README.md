# CoreOS Container Linux on a PCEngines APU

I want a Kubernetes cluster on low-power, low cost hardware that's
reasonably performant. The PCEngines APU2 fits the bill. I had some
laying around. Will it k8s? Let's find out.
 
## Setup

1. Have VirtualBox, vagrant, USB SD Card Reader
2. `vagrant up`
3. `vagrant halt`
4. Enable USB support assign the usb device for your SD card reader to the VM.
5. `vagrant up`
6. `vagrant ssh`
7. `lsblk` - find your SD card `<device>`
8. `sudo ./coreos-install -d <device> -i /vagrant/ignition.json -C stable`
10. Install the SD card and power on the APU.
 
## Troubleshooting

The ignition file sets a boot parameter console=ttyS0,115200n8 which
*should* fire up a getty on the serial port so you can log in and check
in on things. Youll want to add a `passwordHash` to the `core` user in
`ignition.json` to be able to log in. You can at least watch the boot
that way.

