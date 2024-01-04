# Proxmox setup steps

## Boot proxmox setup

Go through the installation using ZFS and finish it

## Reboot into proxmox installer

- reboot into proxmox installer again
- chose advanced, debug terminal ui
- press ctrl+d after first prompt appears
- leave installer, enter shell and run the following

```bash
# show ip
ip a
# if apt update does not work, this might help
dhclient <interface-name>

apt update
apt -y install ssh curl
echo "PermitRootLogin yes" >> /etc/sshd_config
/etc/init.d/ssh restart 
passwd root
# choose a lose password
```



Boot the live rescue disk:
https://github.com/nchevsky/systemrescue-zfs/releases

Then proceed with the following steps:

```
curl -sL https://raw.githubusercontent.com/sandreas/proxmox/main/00-encrypt-rpool.sh | bash
```
