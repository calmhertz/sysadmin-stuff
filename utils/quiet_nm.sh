#!/bin/bash

sudo mkdir -p /etc/NetworkManager/conf.d

sudo tee -a /etc/NetworkManager/conf.d/20-connectivity.conf > /dev/null << 'EOF'
[connectivity]
enabled=false
EOF

sudo tee /etc/NetworkManager/conf.d/no-hostname.conf > /dev/null << 'EOF'
[connection]
ipv4.dhcp-send-hostname=false
ipv6.dhcp-send-hostname=false
EOF

