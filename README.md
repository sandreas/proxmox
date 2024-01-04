# Proxmox setup steps

## Boot proxmox setup

Go through the installation using ZFS and finish it

## Reboot into live rescue disk

Boot the live rescue disk:
https://github.com/nchevsky/systemrescue-zfs/releases

Then proceed with the following steps:

```
curl -sL https://raw.githubusercontent.com/sandreas/proxmox/main/00-encrypt-rpool.sh | bash
```
