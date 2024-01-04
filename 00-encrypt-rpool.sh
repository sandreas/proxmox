#!/bin/bash
#####################
# Sytem Rescue Boot #
#####################

# request passphrase input and store variable
while [ 1 ]; do
  echo -n 'Please provide the rpool passphrase: '
  read -s RPOOL_PASSPHRASE
  echo ""

  if [ "$RPOOL_PASSPHRASE" = "" ]; then
    echo "Passphrase cannot be empty"
    continue
  fi

  echo -n 'Confirm passphrase: '
  read -s RPOOL_PASSPHRASE_CONFIRM
  echo ""

  if [ "$RPOOL_PASSPHRASE" = "$RPOOL_PASSPHRASE_CONFIRM" ]; then
    break
  else
    echo "Passphrases did not match"
  fi
done


# import proxmox pool
zpool import -f rpool

# Make a snapshot of the current one
zfs snapshot -r rpool/ROOT@copy

# Send the snapshot to a temporary root
zfs send -R rpool/ROOT@copy | zfs receive rpool/copyroot

# Destroy the old unencrypted root too prevent two datasets with the same mount point
zfs destroy -r rpool/ROOT

# Create a new zfs root, with encryption turned on
# OR -o encryption=aes-256-gcm - aes-256-ccm vs aes-256-gcm
echo "$RPOOL_PASSPHRASE" | zfs create -o encryption=on -o keyformat=passphrase rpool/ROOT

# choose a strong passphrase
# Copy the files from the copy to the new encrypted zfs root
zfs send -R rpool/copyroot/pve-1@copy | zfs receive -o encryption=on rpool/ROOT/pve-1

# Set the Mountpoint
zfs set mountpoint=/ rpool/ROOT/pve-1

# destroy the copyroot dataset
zfs destroy -r rpool/copyroot

# optional: verify that dataset structure is as expected
zfs list
zfs get encryption rpool/ROOT

# optional: enable trim for ssds
zpool set autotrim=on rpool # enable trim
zfs set atime=off rpool # disable access time logging

# optional: enable compression zstd-4, see https://www.reddit.com/r/zfs/comments/sxx9p7/a_simple_real_world_zfs_compression_speed_an/
# zfs set recordsize=1M compression=zstd-4 rpool
echo "Overview:"
zfs list
zfs get encryption rpool/ROOT

# Export the pool again
zpool export rpool

read -p "rpool encryption successful, please reboot"
