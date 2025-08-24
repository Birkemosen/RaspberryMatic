#!/bin/bash

# Post-build script for Luckfox Pico boards in RaspberryMatic
# This script runs after the main build process

set -e

# Source the common post-build functions
. "${BR2_EXTERNAL_EQ3_PATH}/board/post-build.sh"

echo "Running Luckfox Pico post-build script..."

# Create board-specific directories
mkdir -p "${TARGET_DIR}/opt/luckfox-pico"
mkdir -p "${TARGET_DIR}/opt/luckfox-pico/camera"
mkdir -p "${TARGET_DIR}/opt/luckfox-pico/npu"
mkdir -p "${TARGET_DIR}/opt/luckfox-pico/scripts"

# Install Luckfox Pico specific scripts
cat > "${TARGET_DIR}/opt/luckfox-pico/scripts/camera-setup.sh" << 'EOF'
#!/bin/bash
# Camera setup script for Luckfox Pico

echo "Setting up camera for Luckfox Pico..."

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

cat > "${TARGET_DIR}/opt/luckfox-pico/scripts/npu-setup.sh" << 'EOF'
#!/bin/bash
# NPU setup script for Luckfox Pico

echo "Setting up NPU for Luckfox Pico..."

# Load NPU drivers
modprobe rockchip_npu

# Set NPU permissions
chmod 666 /dev/npu*

# Create NPU device symlinks
ln -sf /dev/npu0 /dev/npu_main

echo "NPU setup complete"
EOF

cat > "${TARGET_DIR}/opt/luckfox-pico/scripts/board-info.sh" << 'EOF'
#!/bin/bash
# Board information script for Luckfox Pico

echo "=== Luckfox Pico Board Information ==="
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
echo "SD Card: $(ls /dev/mmcblk* 2>/dev/null | wc -l) devices"
echo "eMMC: $(ls /dev/mmcblk* 2>/dev/null | grep -c 'mmcblk0' || echo '0') devices"
echo "SPI NAND: $(ls /dev/mtd* 2>/dev/null | wc -l) devices"
EOF

# Make scripts executable
chmod +x "${TARGET_DIR}/opt/luckfox-pico/scripts/"*.sh

# Create systemd service for camera
cat > "${TARGET_DIR}/etc/systemd/system/luckfox-camera.service" << 'EOF'
[Unit]
Description=Luckfox Pico Camera Service
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/opt/luckfox-pico/scripts/camera-setup.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

# Create systemd service for NPU
cat > "${TARGET_DIR}/etc/systemd/system/luckfox-npu.service" << 'EOF'
[Unit]
Description=Luckfox Pico NPU Service
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/opt/luckfox-pico/scripts/npu-setup.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

# Enable services
ln -sf /etc/systemd/system/luckfox-camera.service "${TARGET_DIR}/etc/systemd/system/multi-user.target.wants/"
ln -sf /etc/systemd/system/luckfox-npu.service "${TARGET_DIR}/etc/systemd/system/multi-user.target.wants/"

# Create udev rules for camera and NPU
cat > "${TARGET_DIR}/etc/udev/rules.d/99-luckfox-pico.rules" << 'EOF'
# Luckfox Pico udev rules

# Camera devices
KERNEL=="video*", SUBSYSTEM=="video4linux", MODE="0666"
KERNEL=="media*", SUBSYSTEM=="media", MODE="0666"

# NPU devices
KERNEL=="npu*", MODE="0666"

# GPIO devices
KERNEL=="gpiochip*", SUBSYSTEM=="gpio", MODE="0666"

# I2C devices
KERNEL=="i2c-*", SUBSYSTEM=="i2c-dev", MODE="0666"

# SPI devices
KERNEL=="spidev*", SUBSYSTEM=="spidev", MODE="0666"
EOF

# Create board-specific configuration
cat > "${TARGET_DIR}/etc/luckfox-pico.conf" << 'EOF'
# Luckfox Pico Configuration for RaspberryMatic

# Board identification
BOARD_NAME="Luckfox Pico"
BOARD_MODEL="RV1106 Ultra"
BOARD_VENDOR="LuckfoxTECH"

# Hardware features
ENABLE_CAMERA=true
ENABLE_NPU=true
ENABLE_GPIO=true
ENABLE_I2C=true
ENABLE_SPI=true

# Camera settings
CAMERA_DEVICE="/dev/video0"
CAMERA_RESOLUTION="1920x1080"
CAMERA_FPS=30

# NPU settings
NPU_DEVICE="/dev/npu0"
NPU_FREQUENCY="800MHz"
NPU_MEMORY="512MB"

# GPIO settings
GPIO_BASE=0
GPIO_COUNT=40

# I2C settings
I2C_BUSES="0,1,2"
I2C_SPEED="400kHz"

# SPI settings
SPI_BUSES="0,1"
SPI_SPEED="50MHz"
EOF

# Create HomeMatic integration script
cat > "${TARGET_DIR}/opt/luckfox-pico/scripts/homematic-integration.sh" << 'EOF'
#!/bin/bash
# HomeMatic integration script for Luckfox Pico

echo "Setting up HomeMatic integration for Luckfox Pico..."

# Create HomeMatic device directories
mkdir -p /opt/luckfox-pico/homematic/devices
mkdir -p /opt/luckfox-pico/homematic/scripts
mkdir -p /opt/luckfox-pico/homematic/config

# Create camera-based motion detection script
cat > /opt/luckfox-pico/homematic/scripts/motion-detection.sh << 'MOTION_SCRIPT'
#!/bin/bash
# Motion detection script using Luckfox Pico camera

CAMERA_DEV="/dev/video0"
MOTION_THRESHOLD=50
MOTION_LOG="/var/log/motion.log"

# Check if camera is available
if [ ! -e "$CAMERA_DEV" ]; then
    echo "$(date): Camera device not found: $CAMERA_DEV" >> "$MOTION_LOG"
    exit 1
fi

# Motion detection logic here
echo "$(date): Motion detection active on $CAMERA_DEV" >> "$MOTION_LOG"

# This would integrate with HomeMatic system
# For now, just log the event
echo "$(date): Motion detected - threshold: $MOTION_THRESHOLD" >> "$MOTION_LOG"
MOTION_SCRIPT

chmod +x /opt/luckfox-pico/homematic/scripts/motion-detection.sh

# Create NPU-based AI script
cat > /opt/luckfox-pico/homematic/scripts/ai-analysis.sh << 'AI_SCRIPT'
#!/bin/bash
# AI analysis script using Luckfox Pico NPU

NPU_DEV="/dev/npu0"
AI_LOG="/var/log/ai-analysis.log"

# Check if NPU is available
if [ ! -e "$NPU_DEV" ]; then
    echo "$(date): NPU device not found: $NPU_DEV" >> "$AI_LOG"
    exit 1
fi

# AI analysis logic here
echo "$(date): AI analysis active on $NPU_DEV" >> "$AI_LOG"

# This would integrate with HomeMatic system
# For now, just log the event
echo "$(date): AI analysis completed" >> "$AI_LOG"
AI_SCRIPT

chmod +x /opt/luckfox-pico/homematic/scripts/ai-analysis.sh

echo "HomeMatic integration setup complete"
EOF

chmod +x "${TARGET_DIR}/opt/luckfox-pico/scripts/homematic-integration.sh"

# Run HomeMatic integration setup
"${TARGET_DIR}/opt/luckfox-pico/scripts/homematic-integration.sh"

echo "Luckfox Pico post-build script completed successfully"
