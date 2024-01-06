#!/bin/bash
#####################
# SSH REMOTE UNLOCK #
#####################

# before doing this, you have to copy the ssh key (RSA is required) to the system
# PROXMOX_HOST="192.168.1.10"
# ssh-copy-id root@$PROXMOX_HOST
# ssh "root@$PROXMOX_HOST"

apt update
apt -y install zfs-initramfs dropbear-initramfs
# configure dropbear and ignore these errors, since we are not using cryptsetup, but native ZFS encryption
# cryptsetup: ERROR: Couldn't resolve device rpool/ROOT/pve-1
# cryptsetup: WARNING: Couldn't determine root device
mkdir -p /etc/dropbear-initramfs
cp "/root/.ssh/authorized_keys" /etc/dropbear-initramfs/

# optional: unlock-only shell with direct password prompt instead of a real shell
# bearbeitet die authorized_keys-Datei so, dass vor dem Key noch eingestellt wird, welche Kommandos erlaubt sind
# andernfalls muss man beim remote login noch zfsunlock ausführen
sed -i.bak 's/^ssh-/no-port-forwarding,no-agent-forwarding,no-X11-forwarding,command="\/usr\/bin\/zfsunlock" ssh-/g' /etc/dropbear-initramfs/authorized_keys

# configure dropbear options
grep '^DROPBEAR_OPTIONS' /etc/dropbear-initramfs/config > /dev/null || (echo 'DROPBEAR_OPTIONS="-p 2222 -s -j -k -I 60"' >> /etc/dropbear-initramfs/config && update-initramfs -u)
