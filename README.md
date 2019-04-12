** Prereqs **

Install from Fedora 30 (Beta/nightly at time of writing) Workstation ISO.

The kickstart file for partitioning is attached `anaconda-ks.cfg`

*You have unallocated space on the Volume Group. Grow it for whichever filesystem may need it later.*

`systemctl enable --now sshd`

`visudo`

Give %wheel the abiility to run any command without password.

`hostnamectl set-hostname pulp-demo-$(sudo cat /sys/devices/virtual/dmi/id/product_serial | awk '{ print tolower(substr($0,length($0)-1,2))}').localdomain`

The above command sets a unique hostname based on the last 2 characters of the machine's serial number.

`ip addr show`

Determine your IP address (assuming 192.168.1.91 for the rest of this.)

`ssh-copy-id -i ~/.ssh/id_ed25519.pub pulp@192.168.1.91`

Adapt the above command for your SSH pubkey and for the IP address of the system.

Apply the playbook:

`ansible-playbook pulp-demo-setup.yml -i 192.168.1.91,`
