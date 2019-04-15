# Prereqs

## OS install & LVM setup

Install from Fedora 30 (Beta/nightly at time of writing) Workstation ISO.

The kickstart file for partitioning is attached `anaconda-ks.cfg`. It assumes EFI mode (which the Intel NUC8i7BEH defaults to, and I recommend.)

It is also recommended to disable EFI secure boot in case we ever need to recover the system via an non-signed media. This is the only firmware/BIOS setting changed on the Intel NUC8i7BEH.

**You have unallocated space on the Volume Group. Grow whichever filesystem may need it later.**


## Make the machine manageable by Ansible

Enable & start sshd

`systemctl enable --now sshd`

Give %wheel the abiility to run any command without password.

`visudo`

Set a unique hostname based on the last 2 characters of the machine's serial number.

`hostnamectl set-hostname pulp-demo-$(sudo cat /sys/devices/virtual/dmi/id/product_serial | awk '{ print tolower(substr($0,length($0)-1,2))}').localdomain`

Determine your IP address

`ip addr show`

**(assuming 192.168.1.91 for the rest of these instructions.)**

Adapt this command for your SSH pubkey and for the IP address of the system.

`ssh-copy-id -i ~/.ssh/id_ed25519.pub pulp@192.168.1.91`

# Setup

Apply the Ansible playbook:

`ansible-playbook pulp-demo-setup.yml -i 192.168.1.91, -e reboot=true`

In the future for any updates, just run:

`ansible-playbook pulp-demo-setup.yml -i 192.168.1.91,`

# Usage

You can now run minikube subcommands (beyond `start`):
`minikube --help`

There is a GNOME favorite app for `minikube dashboard` as well.
