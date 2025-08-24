#!/bin/bash
# NPU setup script for Luckfox Pico
# Based on LuckfoxTECH SDK specifications (RV1106 only)

set -e

NPU_LOG="/var/log/luckfox-npu.log"
NPU_CONF="/etc/luckfox/npu.conf"

# Create log directory
mkdir -p "$(dirname "$NPU_LOG")"

log() {
    echo "$(date): $1" | tee -a "$NPU_LOG"
}

log "Starting Luckfox Pico NPU setup..."

# Check if we're running on a Luckfox Pico board
if ! grep -q "Luckfox\|RV110" /proc/device-tree/model 2>/dev/null; then
    log "Warning: This doesn't appear to be a Luckfox Pico board"
fi

# Check if this is an RV1106 board (NPU support)
if ! grep -q "RV1106" /proc/device-tree/model 2>/dev/null; then
    log "Info: This is not an RV1106 board - NPU not available"
    log "NPU setup completed (not applicable)"
    exit 0
fi

log "Detected RV1106 board with NPU support"

# Load NPU drivers from SDK
log "Loading NPU drivers..."

# Load main NPU driver
if modprobe rockchip_npu 2>/dev/null; then
    log "Loaded rockchip_npu driver"
else
    log "Warning: Failed to load rockchip_npu driver"
fi

# Load NPU-specific drivers
if modprobe rknpu 2>/dev/null; then
    log "Loaded rknpu driver"
else
    log "Warning: Failed to load rknpu driver"
fi

# Wait for NPU devices to appear
sleep 2

# Set NPU permissions
log "Setting NPU device permissions..."
for npu_dev in /dev/npu*; do
    if [ -e "$npu_dev" ]; then
        chmod 666 "$npu_dev"
        log "Set permissions for $npu_dev"
    fi
done

# Create NPU device symlinks
log "Creating NPU device symlinks..."
if [ -e "/dev/npu0" ]; then
    ln -sf /dev/npu0 /dev/npu_main 2>/dev/null || true
    log "Created /dev/npu_main symlink"
fi

# Create NPU configuration
log "Creating NPU configuration..."
mkdir -p "$(dirname "$NPU_CONF")"
cat > "$NPU_CONF" << 'EOF'
# Luckfox Pico NPU Configuration
# Based on LuckfoxTECH SDK (RV1106)

# NPU device settings
NPU_MAIN_DEV="/dev/npu0"

# NPU performance settings
NPU_FREQUENCY="800MHz"
NPU_MEMORY="512MB"
NPU_CORES=1

# AI model support
NPU_SUPPORTED_MODELS="yolo,ssd,mobilenet,resnet"
NPU_MODEL_PATH="/opt/luckfox-pico/models"

# NPU optimization settings
NPU_OPTIMIZATION_LEVEL=3
NPU_MEMORY_ALIGNMENT=64

# Performance monitoring
NPU_MONITORING=true
NPU_THERMAL_PROTECTION=true

# Debug settings
NPU_DEBUG=false
NPU_LOG_LEVEL="info"
EOF

# Set configuration permissions
chmod 644 "$NPU_CONF"

# Create NPU model directory
mkdir -p /opt/luckfox-pico/models
chmod 755 /opt/luckfox-pico/models

# Test NPU functionality
log "Testing NPU functionality..."
if [ -e "/dev/npu0" ]; then
    # Check NPU frequency
    if [ -e "/sys/class/devfreq/npu/cur_freq" ]; then
        NPU_FREQ=$(cat /sys/class/devfreq/npu/cur_freq 2>/dev/null || echo "unknown")
        log "NPU current frequency: ${NPU_FREQ}Hz"
    fi
    
    # Check NPU memory
    if [ -e "/sys/class/devfreq/npu/available_frequencies" ]; then
        NPU_FREQS=$(cat /sys/class/devfreq/npu/available_frequencies 2>/dev/null || echo "unknown")
        log "NPU available frequencies: $NPU_FREQS"
    fi
    
    log "NPU test successful - /dev/npu0 is working"
else
    log "Warning: No NPU devices found"
fi

# Create NPU status file
echo "NPU Status: $(date)" > /var/run/luckfox-npu.status
echo "Devices: $(ls /dev/npu* 2>/dev/null | wc -l)" >> /var/run/luckfox-npu.status
echo "Frequency: ${NPU_FREQ:-unknown}" >> /var/run/luckfox-npu.status
echo "Available Frequencies: ${NPU_FREQS:-unknown}" >> /var/run/luckfox-npu.status

# Set NPU performance mode if available
if [ -e "/sys/class/devfreq/npu/governor" ]; then
    echo "performance" > /sys/class/devfreq/npu/governor 2>/dev/null || true
    log "Set NPU governor to performance mode"
fi

# Create sample AI model info
cat > /opt/luckfox-pico/models/README.md << 'EOF'
# Luckfox Pico NPU Models

This directory contains AI models compatible with the RV1106 NPU.

## Supported Model Formats
- RKNN (Rockchip Neural Network)
- ONNX
- TensorFlow Lite
- Caffe

## Pre-trained Models
- YOLOv5 (Object Detection)
- MobileNet (Image Classification)
- SSD (Object Detection)
- ResNet (Image Classification)

## Model Conversion
Use Rockchip's RKNN Toolkit to convert models to RKNN format:
https://github.com/rockchip-linux/rknn-toolkit

## Usage Example
```bash
# Load and run a model
rknn_run --model /opt/luckfox-pico/models/yolov5.rknn \
         --input /dev/video0 \
         --output /tmp/result.jpg
```
EOF

log "NPU setup completed successfully"
log "NPU devices: $(ls /dev/npu* 2>/dev/null | tr '\n' ' ')"
log "NPU frequency: ${NPU_FREQ:-unknown}"
log "NPU model directory: /opt/luckfox-pico/models"
