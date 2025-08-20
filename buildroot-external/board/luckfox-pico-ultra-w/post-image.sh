#!/bin/bash
# Luckfox Pico Ultra W Post-Image Script
# This script runs after the image creation to prepare the final bootable image

set -e

BOARD_DIR="${BR2_EXTERNAL_EQ3_PATH}/board/luckfox-pico-ultra-w"
BINARIES_DIR="${BINARIES_DIR:-${BUILD_DIR}/images}"
TARGET_DIR="${TARGET_DIR:-${BUILD_DIR}/target}"

echo "Running Luckfox Pico Ultra W post-image script..."

# Create output directory
mkdir -p "${BINARIES_DIR}/luckfox-pico-ultra-w"

# Firmware files are now installed by Buildroot package system
echo "✅ Firmware files installed by Buildroot package system"
echo "   No manual firmware copying required"

# Create firmware summary from installed files
echo "Creating firmware summary..."
FIRMWARE_COUNT=$(find "${TARGET_DIR}/usr/lib/firmware" "${TARGET_DIR}/usr/share/mcu-firmware" "${TARGET_DIR}/usr/share/uboot-firmware" "${TARGET_DIR}/usr/lib/modules" -type f 2>/dev/null | wc -l)
FIRMWARE_SIZE=$(du -sh "${TARGET_DIR}/usr/lib/firmware" "${TARGET_DIR}/usr/share/mcu-firmware" "${TARGET_DIR}/usr/share/uboot-firmware" "${TARGET_DIR}/usr/lib/modules" 2>/dev/null | awk '{sum+=$1} END {print sum "K"}')
echo "Firmware summary: $FIRMWARE_COUNT files, $FIRMWARE_SIZE total size"

# Create boot script
cat > "${BINARIES_DIR}/luckfox-pico-ultra-w/boot.cmd" << 'EOF'
# Luckfox Pico Ultra W Boot Script

# Set boot delay
setenv bootdelay 0

# Set boot command
setenv bootcmd "mmc dev 0; mmc read ${kernel_addr_r} ${kernel_offset} ${kernel_size}; bootm ${kernel_addr_r}"

# Set boot arguments
setenv bootargs "console=ttyS0,115200 root=/dev/mmcblk0p4 rootwait rw"

# Set kernel address
setenv kernel_addr_r 0x80008000
setenv kernel_offset 0x8000
setenv kernel_size 0x400000

# Set device tree address
setenv fdt_addr_r 0x82000000
setenv fdt_offset 0x400000
setenv fdt_size 0x10000

# Set ramdisk address
setenv ramdisk_addr_r 0x82100000
setenv ramdisk_offset 0x410000
setenv ramdisk_size 0x100000

# Set environment variables
setenv ethaddr 00:11:22:33:44:55
setenv ipaddr 192.168.1.100
setenv serverip 192.168.1.1
setenv netmask 255.255.255.0
setenv gatewayip 192.168.1.1

# Save environment
saveenv
EOF

# Create installation script
cat > "${BINARIES_DIR}/luckfox-pico-ultra-w/install.sh" << 'EOF'
#!/bin/bash
# Luckfox Pico Ultra W Installation Script

set -e

echo "Luckfox Pico Ultra W Installation Script"
echo "========================================"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root (use sudo)"
    exit 1
fi

# Check if SD card is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <device>"
    echo "Example: $0 /dev/sdb"
    echo ""
    echo "Available devices:"
    lsblk -d -o NAME,SIZE,TYPE,MOUNTPOINT | grep -E "^(sd|mmcblk)"
    exit 1
fi

DEVICE="$1"

# Verify device exists
if [ ! -b "$DEVICE" ]; then
    echo "Error: Device $DEVICE does not exist"
    exit 1
fi

# Check if device is mounted
if mount | grep -q "$DEVICE"; then
    echo "Error: Device $DEVICE is mounted. Please unmount first."
    exit 1
fi

echo "Installing to device: $DEVICE"
echo "WARNING: This will erase all data on $DEVICE"
read -p "Are you sure? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Installation cancelled"
    exit 0
fi

# Create partitions
echo "Creating partitions..."
fdisk "$DEVICE" << EOF
o
n
p
1
2048
+32K
n
p
2
4096
+512K
n
p
3
9216
+256K
n
p
4
12288
+32M
n
p
5
77824
+512M
n
p
6
1126400
+256M
n
p
7
1638400

w
EOF

# Format partitions
echo "Formatting partitions..."
mkfs.ext4 "${DEVICE}4" -L boot
mkfs.ext4 "${DEVICE}5" -L oem
mkfs.ext4 "${DEVICE}6" -L userdata
mkfs.ext4 "${DEVICE}7" -L rootfs

# Mount partitions
echo "Mounting partitions..."
mkdir -p /tmp/luckfox-boot /tmp/luckfox-rootfs
mount "${DEVICE}4" /tmp/luckfox-boot
mount "${DEVICE}7" /tmp/luckfox-rootfs

# Copy files
echo "Copying files..."
cp -r rootfs/* /tmp/luckfox-rootfs/
cp boot.img /tmp/luckfox-boot/
cp rv1106g-luckfox-pico-ultra-w.dtb /tmp/luckfox-boot/

# Unmount
echo "Unmounting partitions..."
umount /tmp/luckfox-boot
umount /tmp/luckfox-rootfs
rmdir /tmp/luckfox-boot /tmp/luckfox-rootfs

echo "Installation completed successfully!"
echo "You can now boot from the SD card"
EOF

chmod +x "${BINARIES_DIR}/luckfox-pico-ultra-w/install.sh"

# Create README
cat > "${BINARIES_DIR}/luckfox-pico-ultra-w/README.md" << 'EOF'
# Luckfox Pico Ultra W for RaspberryMatic

This directory contains the build artifacts and configuration files for running RaspberryMatic on the Luckfox Pico Ultra W board.

## Hardware Specifications

- **SoC**: Rockchip RV1106G3
- **CPU**: Single-core ARM Cortex-A7 32-bit with NEON and FPU
- **NPU**: 4th generation NPU with 1TOPS int8 performance
- **ISP**: 3rd generation ISP3.2 with 5MP support
- **Memory**: 16-bit DDR3L DRAM
- **Storage**: 8GB eMMC + microSD card slot
- **WiFi**: WiFi 6 (802.11ax)
- **Bluetooth**: Bluetooth 5.2/BLE
- **GPIO**: 40-pin header (Raspberry Pi compatible)
- **USB**: USB 2.0 Type-C
- **Ethernet**: 10/100M Ethernet port

## Files

- `rv1106g-luckfox-pico-ultra-w.dts` - Device tree source
- `luckfox_rv1106_linux_defconfig` - Kernel configuration
- `luckfox_rv1106_uboot_defconfig` - U-Boot configuration
- `luckfox_pico_w_defconfig` - Buildroot configuration
- `BoardConfig-EMMC-Buildroot-RV1106_Luckfox_Pico_Ultra_W-IPC.mk` - Board configuration
- `boot.cmd` - U-Boot boot script
- `install.sh` - Installation script

## Installation

1. Insert a microSD card into your computer
2. Run the installation script: `sudo ./install.sh /dev/sdX` (replace sdX with your device)
3. Insert the SD card into the Luckfox Pico Ultra W
4. Power on the device

## Building

To build this image:

```bash
cd RaspberryMatic
make PRODUCT=raspmatic_luckfox-pico-ultra-w
```

## Features

- Full ARM Cortex-A7 compatibility
- Hardware-accelerated AI/ML with NPU
- Professional camera support with ISP
- WiFi 6 and Bluetooth 5.2
- Raspberry Pi compatible GPIO
- EMMC and SD card boot support

## Support

For more information, see:
- [Luckfox Pico Ultra W Documentation](https://wiki.luckfox.com/Luckfox-Pico-Ultra-W)
- [RaspberryMatic Documentation](https://github.com/jens-maus/RaspberryMatic/wiki)
EOF

# Create version info
echo "Creating version information..."
cat > "${BINARIES_DIR}/luckfox-pico-ultra-w/version.txt" << EOF
Luckfox Pico Ultra W for RaspberryMatic
=======================================
Build Date: $(date)
Build Host: $(hostname)
Build User: $(whoami)
RaspberryMatic Version: $(cat "${BR2_EXTERNAL_EQ3_PATH}/../VERSION" 2>/dev/null || echo "unknown")
Board: Luckfox Pico Ultra W
SoC: Rockchip RV1106G3
CPU: ARM Cortex-A7
Architecture: ARM 32-bit
EOF

# Create checksums
echo "Creating checksums..."
cd "${BINARIES_DIR}/luckfox-pico-ultra-w"
if command -v sha256sum >/dev/null 2>&1; then
    sha256sum * > SHA256SUMS
elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 * > SHA256SUMS
fi

echo "Luckfox Pico Ultra W post-image script completed successfully."
echo "Output files are in: ${BINARIES_DIR}/luckfox-pico-ultra-w/"
