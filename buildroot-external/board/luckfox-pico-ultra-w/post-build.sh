#!/bin/bash

# Luckfox Pico Ultra W post-build script
# This script is executed after the rootfs is built

set -e

# Create board-specific directories if needed
mkdir -p ${TARGET_DIR}/opt/luckfox-pico-ultra-w

# Set up WiFi configuration if needed
if [ -n "${LF_WIFI_SSID}" ] && [ -n "${LF_WIFI_PSK}" ]; then
    cat > ${TARGET_DIR}/etc/wpa_supplicant.conf << EOF
ctrl_interface=/var/run/wpa_supplicant
ctrl_interface_group=0
update_config=1

network={
    ssid="${LF_WIFI_SSID}"
    psk="${LF_WIFI_PSK}"
    key_mgmt=WPA-PSK
}
EOF
fi

# Create systemd service for WiFi setup if needed
if [ -n "${LF_WIFI_SSID}" ]; then
    cat > ${TARGET_DIR}/etc/systemd/system/wifi-setup.service << EOF
[Unit]
Description=WiFi Setup for Luckfox Pico Ultra W
After=network.target

[Service]
Type=oneshot
ExecStart=/bin/sh -c 'if [ -f /etc/wpa_supplicant.conf ]; then wpa_supplicant -B -i wlan0 -c /etc/wpa_supplicant.conf; dhclient wlan0; fi'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

    # Enable the service
    ln -sf /etc/systemd/system/wifi-setup.service ${TARGET_DIR}/etc/systemd/system/multi-user.target.wants/
fi

# Set up GPIO permissions
echo "gpio:x:1000:1000:GPIO group:/dev/null:/bin/false" >> ${TARGET_DIR}/etc/group
echo "gpio:x:1000:1000::/dev/null:/bin/false" >> ${TARGET_DIR}/etc/passwd

# Create udev rules for GPIO access
cat > ${TARGET_DIR}/etc/udev/rules.d/99-gpio.rules << EOF
SUBSYSTEM=="gpio", GROUP="gpio", MODE="0660"
SUBSYSTEM=="bcm2835-gpiomem", GROUP="gpio", MODE="0660"
EOF

echo "Luckfox Pico Ultra W post-build script completed" 