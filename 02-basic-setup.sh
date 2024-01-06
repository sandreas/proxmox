#!/bin/bash
# todo
# - zfs-auto-snapshot - see https://raw.githubusercontent.com/extremeshok/xshok-proxmox/master/install-post.sh
# - docker lxc - see https://tteck.github.io/Proxmox/ (docker)
# - create "shared" user
# - configure portainer
# - configure pi-hole
# - configure immich
# - check zfs get written and destroy copy datasets
# update lists
apt update

# reduce ssd wearout
systemctl disable --now corosync pve-ha-lrm pve-ha-crm
JOURNALD_CONF="/etc/systemd/journald.conf"
grep -q 'Storage=volatile' "$JOURNALD_CONF" || cat << 'EOF' >> "$JOURNALD_CONF"
Storage=volatile
ForwardToSyslog=no
EOF

# reduce power consumption by cpu governor and powertop
# see https://forums.unraid.net/topic/98070-reduce-power-consumption-with-powertop/
cat << 'EOF' > /etc/systemd/system/sg-powersave.service
[Unit]
Description=Scaling governor powersave
DefaultDependencies=yes
After=network.target
[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/bin/echo "powersave" | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor >/dev/null 2>&1

[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now sg-powersave 

dpkg -s powertop &> /dev/null || apt -y install powertop
# maybe powertop --calibrate and a reboot is required followed by another powertop --calibrate
powertop --auto-tune &> /dev/null

# zfs-auto-snapshot
if [ "${XS_ZFSAUTOSNAPSHOT,,}" == "yes" ] ; then
    ## Install zfs-auto-snapshot
    /usr/bin/env DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::='--force-confdef' install zfs-auto-snapshot
    # make 5min snapshots , keep 12 5min snapshots
    if [ -f "/etc/cron.d/zfs-auto-snapshot" ] ; then
      sed -i 's|--keep=[0-9]*|--keep=12|g' /etc/cron.d/zfs-auto-snapshot
      sed -i 's|*/[0-9]*|*/5|g' /etc/cron.d/zfs-auto-snapshot
    fi
    # keep 24 hourly snapshots
    if [ -f "/etc/cron.hourly/zfs-auto-snapshot" ] ; then
      sed -i 's|--keep=[0-9]*|--keep=24|g' /etc/cron.hourly/zfs-auto-snapshot
    fi
    # keep 7 daily snapshots
    if [ -f "/etc/cron.daily/zfs-auto-snapshot" ] ; then
      sed -i 's|--keep=[0-9]*|--keep=7|g' /etc/cron.daily/zfs-auto-snapshot
    fi
    # keep 4 weekly snapshots
    if [ -f "/etc/cron.weekly/zfs-auto-snapshot" ] ; then
      sed -i 's|--keep=[0-9]*|--keep=4|g' /etc/cron.weekly/zfs-auto-snapshot
    fi
    # keep 3 monthly snapshots
    if [ -f "/etc/cron.monthly/zfs-auto-snapshot" ] ; then
      sed -i 's|--keep=[0-9]*|--keep=3|g' /etc/cron.monthly/zfs-auto-snapshot
    fi
fi
