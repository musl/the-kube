# CoreOS Container Linux on a PCEngines APU

I want a Kubernetes cluster on low-power, low cost hardware that's
reasonably performant. The PCEngines APU2 fits the bill. I had some
laying around. Will it k8s? Let's find out.

Note, the `ignition.json` has values hard-coded for a 256GB SD card. You
may either remove the bits that create the 10th partition and the
`data.mount` service or re-calculate the sector start and size for that
partition to match your card.
 
## Setup

3. Have VirtualBox, vagrant, USB SD Card Reader
1. Enable USB support and assign the usb device for your SD card reader to the VM.
4. `vagrant up`
7. `vagrant ssh`
8. `sudo su -`
9. `cd /vagrant`
10. `make`
11. log out of the vagrant box
12. `vagrant halt`
13. Install the SD card and power on the APU.
 
## Troubleshooting

The ignition file sets a boot parameter console=ttyS0,115200n8 which
*should* fire up a getty on the serial port so you can log in and check
in on things. Youll want to add a `passwordHash` to the `core` user in
`ignition.json` to be able to log in. You can at least watch the boot
that way.

