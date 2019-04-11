** Prereqs **

Install from Fedora 30 (Beta/nightly at time of writing) Workstation ISO.

The kickstart file for partitioning is attached.

`systemctl enable --now sshd`

`visudo`

Give %wheel the abiility to run any command without password.

`hostnamectl set-hostname pulp-demo-$(sudo cat /sys/devices/virtual/dmi/id/product_serial | awk '{ print tolower(substr($0,length($0)-1,2))}').localdomain`

The above command sets a unique hostname based on the last 2 characters of the machine's serial number.
