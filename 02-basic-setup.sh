#!/bin/bash

# reduce ssd wearout
systemctl disable --now pve-ha-lrm.service pve-ha-crm.service
JOURNALD_CONF="/etc/systemd/journald.conf"
grep -q 'Storage=volatile' "$JOURNALD_CONF" || cat << 'EOF' >> "$JOURNALD_CONF"
Storage=volatile
ForwardToSyslog=no
EOF

