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

. .functions.sh

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

# dpkg -s powertop &> /dev/null || apt -y install powertop
install_package powertop

# maybe powertop --calibrate and a reboot is required followed by another powertop --calibrate
powertop --auto-tune &> /dev/null

## Install zfs-auto-snapshot
install_package zfs-auto-snapshot
