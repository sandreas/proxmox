#!/bin/sh
###################
# Back in Proxmox #
###################

# create a strong encryption key
openssl rand -hex -out /root/data-encrypted.key 32

# recreate data with key based encryption
umount /rpool/data
zfs snapshot -r rpool/data@copy
zfs send -R rpool/data@copy | zfs receive rpool/copydata
zfs destroy -r rpool/data
zfs send -R rpool/copydata@copy | zfs receive -o encryption=on -o keyformat=hex -o keylocation=file:///root/data-encrypted.key rpool/data
zfs set mountpoint=/rpool/data rpool/data
zfs destroy -r rpool/copydata

# encryption needs to load key first, so you have to create a system service, which performs the following on boot
# zfs load-key -r rpool/data
# zfs mount rpool/data        # if not auto mounted

cat << 'EOF' > /etc/systemd/system/zfs-load-data-key.service
[Unit]
Description=Load ZFS keys
DefaultDependencies=no
Before=zfs-mount.service
After=zfs-import.target
Requires=zfs-import.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/sbin/zfs load-key -r rpool/data

[Install]
WantedBy=zfs-mount.service
EOF

systemctl enable --now zfs-load-data-key


read -p "data encryption successful, please make sure you backup /root/data-encrypted.key ..."
