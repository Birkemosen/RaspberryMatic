#!/bin/bash

# Post-build script for Luckfox Pico Ultra W boards in RaspberryMatic
# This script runs after the main build process

set -e

# Source the common post-build functions
. "${BR2_EXTERNAL_EQ3_PATH}/board/post-build.sh"

echo "Running Luckfox Pico Ultra W post-build script..."

# Create board-specific directories
mkdir -p "${TARGET_DIR}/opt/luckfox-pico-ultra-w"
mkdir -p "${TARGET_DIR}/opt/luckfox-pico-ultra-w/camera"
mkdir -p "${TARGET_DIR}/opt/luckfox-pico-ultra-w/npu"
mkdir -p "${TARGET_DIR}/opt/luckfox-pico-ultra-w/scripts"

# Install Luckfox Pico Ultra W specific scripts
cat > "${TARGET_DIR}/opt/luckfox-pico-ultra-w/scripts/camera-setup.sh" << 'EOF'
#!/bin/bash
# Camera setup script for Luckfox Pico Ultra W

echo "Setting up camera for Luckfox Pico Ultra W..."

# Load camera drivers
modprobe rockchip_isp
modprobe rockchip_isp1

# Set camera permissions
chmod 666 /dev/video*
chmod 666 /dev/media*

# Create camera device symlinks
ln -sf /dev/video0 /dev/camera_main
ln -sf /dev/video1 /dev/camera_isp

echo "Camera setup complete"
EOF

cat > "${TARGET_DIR}/opt/luckfox-pico-ultra-w/scripts/npu-setup.sh" << 'EOF'
#!/bin/bash
# NPU setup script for Luckfox Pico Ultra W

echo "Setting up NPU for Luckfox Pico Ultra W..."

# Load NPU drivers
modprobe rockchip_npu

# Set NPU permissions
chmod 666 /dev/npu*

# Create NPU device symlinks
ln -sf /dev/npu0 /dev/npu_main

echo "NPU setup complete"
EOF

cat > "${TARGET_DIR}/opt/luckfox-pico-ultra-w/scripts/board-info.sh" << 'EOF'
#!/bin/bash
# Board information script for Luckfox Pico Ultra W

echo "=== Luckfox Pico Ultra W Board Information ==="
echo "Board: $(cat /proc/device-tree/model 2>/dev/null || echo 'Unknown')"
echo "SoC: $(cat /proc/cpuinfo | grep 'Hardware' | cut -d: -f2 | tr -d ' ' || echo 'Unknown')"
echo "Kernel: $(uname -r)"
echo "Architecture: $(uname -m)"

echo ""
echo "=== Hardware Features ==="
echo "Camera/ISP: $(ls /dev/video* 2>/dev/null | wc -l) devices"
echo "NPU: $(ls /dev/npu* 2>/dev/null | wc -l) devices"
echo "GPIO: $(ls /sys/class/gpio/ 2>/dev/null | grep -c 'gpiochip' || echo '0') chips"
echo "I2C: $(ls /dev/i2c* 2>/dev/null | wc -l) buses"
echo "SPI: $(ls /dev/spi* 2>/dev/null | wc -l) buses"

echo ""
echo "=== Storage ==="
echo "eMMC: $(ls /dev/mmcblk* 2>/dev/null | grep -c 'mmcblk0' || echo '0') devices"
echo "SDIO: $(ls /dev/mmcblk* 2>/dev/null | grep -c 'mmcblk1' || echo '0') devices"
echo "SPI NAND: $(ls /dev/mtd* 2>/dev/null | wc -l) devices"
EOF

# Make scripts executable
chmod +x "${TARGET_DIR}/opt/luckfox-pico-ultra-w/scripts/"*.sh

# Ensure systemd directory exists
mkdir -p "${TARGET_DIR}/etc/systemd/system"

# Create systemd service for camera
cat > "${TARGET_DIR}/etc/systemd/system/luckfox-camera.service" << 'EOF'
[Unit]
Description=Luckfox Pico Ultra W Camera Service
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/opt/luckfox-pico-ultra-w/scripts/camera-setup.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

# Create systemd service for NPU
cat > "${TARGET_DIR}/etc/systemd/system/luckfox-npu.service" << 'EOF'
[Unit]
Description=Luckfox Pico Ultra W NPU Service
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/opt/luckfox-pico-ultra-w/scripts/npu-setup.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

# Enable services (only if they exist)
mkdir -p "${TARGET_DIR}/etc/systemd/system/multi-user.target.wants"
if [ -f "${TARGET_DIR}/etc/systemd/system/luckfox-camera.service" ]; then
    ln -sf /etc/systemd/system/luckfox-camera.service "${TARGET_DIR}/etc/systemd/system/multi-user.target.wants/"
fi
if [ -f "${TARGET_DIR}/etc/systemd/system/luckfox-npu.service" ]; then
    ln -sf /etc/systemd/system/luckfox-npu.service "${TARGET_DIR}/etc/systemd/system/multi-user.target.wants/"
fi

echo "Luckfox Pico Ultra W post-build script completed"
