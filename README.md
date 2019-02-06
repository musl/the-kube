# CoreOS Container Linux on a PCEngines APU

I want a Kubernetes cluster on low-power, low cost hardware that's
reasonably performant. The PCEngines APU2 fits the bill. I had some
laying around. Will it k8s? Let's find out.

## Prerequisites
- 4+ APU1/2 boards from PCEngines (or, really any computer with a serial
	console)
- FreeBSD installation image on a USB stick
- network cables and any other hardware that pleases you
- an internet connection

## Node Allocation
- 1 Freebsd gateway/proxy/firewall Node
- 3+ CoreOS Container Linux Nodes

## How to Use
1. setup freebsd on an APU
2. install dnsmasq, nginx, and haproxy on the freebsd box
3. configure dnsmasq, nginx, haproxy, pf, and the system with the
	 configuration files in the `freebsd` directory
4. update the mac addresses in `dnsmasq.conf` to reflect your hardware
5. create a user `core` for convenience and for a place to run `kubeadm`
	 from.
6. Replace the SSH keys in `install.yaml` with yours.
7. run `make deploy remote=root@freebsdhost:/usr/local/etc/pxe/`
8. enable iPXE on the coreos APUs
9. pxe boot the coreos APUs
10. wait about 10 minutes
11. Check that you can SSH into all of the nodes, use ssh agent
		forwarding and the `core` user.
12. On node `one` run:
		sudo kubeadm init --pod-network-cidr 10.1.0.0/16 --apiserver-cert-extra-sans one.kube.net
13. Run the printed join commands on nodes two, three, and the rest.
14. Copy the kube config out to `~core/.kube/config` on the freebsd
		host. Also: `chmod 0600 .kube/config`
15. Deploy flannel:
		`kubectl apply -f kube-flannel.yaml` (or use the URL)
16. In a minute or two, once the flannel daemonset is up on all of the
		nodes, `kubectl get nodes` should show 3+ nodes in the `Ready` state.
17. Deploy stuff. Have fun. Break things. Fix things. Change things.
