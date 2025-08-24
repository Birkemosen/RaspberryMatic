#!/bin/bash
# Camera setup script for Luckfox Pico
# Based on LuckfoxTECH SDK specifications

set -e

CAMERA_LOG="/var/log/luckfox-camera.log"
CAMERA_CONF="/etc/luckfox/camera.conf"

# Create log directory
mkdir -p "$(dirname "$CAMERA_LOG")"

log() {
    echo "$(date): $1" | tee -a "$CAMERA_LOG"
}

log "Starting Luckfox Pico camera setup..."

# Check if we're running on a Luckfox Pico board
if ! grep -q "Luckfox\|RV110" /proc/device-tree/model 2>/dev/null; then
    log "Warning: This doesn't appear to be a Luckfox Pico board"
fi

# Load camera drivers from SDK
log "Loading camera drivers..."

# Load ISP drivers
if modprobe rockchip_isp 2>/dev/null; then
    log "Loaded rockchip_isp driver"
else
    log "Warning: Failed to load rockchip_isp driver"
fi

if modprobe rockchip_isp1 2>/dev/null; then
    log "Loaded rockchip_isp1 driver"
else
    log "Warning: Failed to load rockchip_isp1 driver"
fi

# Load sensor drivers based on board type
if grep -q "RV1106" /proc/device-tree/model 2>/dev/null; then
    # RV1106 boards support more advanced sensors
    for sensor in ov5640 ov2640 gc2145 imx219; do
        if modprobe "$sensor" 2>/dev/null; then
            log "Loaded $sensor sensor driver"
        fi
    done
else
    # RV1103 boards
    for sensor in ov5640 ov2640; do
        if modprobe "$sensor" 2>/dev/null; then
            log "Loaded $sensor sensor driver"
        fi
    done
fi

# Wait for devices to appear
sleep 2

# Set camera permissions
log "Setting camera device permissions..."
for video_dev in /dev/video*; do
    if [ -e "$video_dev" ]; then
        chmod 666 "$video_dev"
        log "Set permissions for $video_dev"
    fi
done

for media_dev in /dev/media*; do
    if [ -e "$media_dev" ]; then
        chmod 666 "$media_dev"
        log "Set permissions for $media_dev"
    fi
done

# Create camera device symlinks
log "Creating camera device symlinks..."
if [ -e "/dev/video0" ]; then
    ln -sf /dev/video0 /dev/camera_main 2>/dev/null || true
    log "Created /dev/camera_main symlink"
fi

if [ -e "/dev/video1" ]; then
    ln -sf /dev/video1 /dev/camera_isp 2>/dev/null || true
    log "Created /dev/camera_isp symlink"
fi

# Create camera configuration
log "Creating camera configuration..."
mkdir -p "$(dirname "$CAMERA_CONF")"
cat > "$CAMERA_CONF" << 'EOF'
# Luckfox Pico Camera Configuration
# Based on LuckfoxTECH SDK

# Camera device settings
CAMERA_MAIN_DEV="/dev/video0"
CAMERA_ISP_DEV="/dev/video1"

# Supported resolutions
CAMERA_RESOLUTIONS="1920x1080,1280x720,640x480"

# Frame rate settings
CAMERA_FPS=30

# ISP settings
ISP_ENABLE=true
ISP_STABILIZATION=true
ISP_AUTO_FOCUS=true

# Sensor-specific settings
OV5640_I2C_ADDR=0x36
OV2640_I2C_ADDR=0x30
GC2145_I2C_ADDR=0x3C
IMX219_I2C_ADDR=0x10

# GPIO pins for camera control
CAMERA_POWER_GPIO=4
CAMERA_RESET_GPIO=5
CAMERA_PWDN_GPIO=6
EOF

# Set configuration permissions
chmod 644 "$CAMERA_CONF"

# Test camera functionality
log "Testing camera functionality..."
if [ -e "/dev/video0" ]; then
    if v4l2-ctl --device=/dev/video0 --list-formats-ext 2>/dev/null; then
        log "Camera test successful - video0 is working"
    else
        log "Warning: Camera test failed for video0"
    fi
else
    log "Warning: No camera devices found"
fi

# Create camera status file
echo "Camera Status: $(date)" > /var/run/luckfox-camera.status
echo "Devices: $(ls /dev/video* 2>/dev/null | wc -l)" >> /var/run/luckfox-camera.status
echo "Media: $(ls /dev/media* 2>/dev/null | wc -l)" >> /var/run/luckfox-camera.status

log "Camera setup completed successfully"
log "Camera devices: $(ls /dev/video* 2>/dev/null | tr '\n' ' ')"
log "Media devices: $(ls /dev/media* 2>/dev/null | tr '\n' ' ')"
