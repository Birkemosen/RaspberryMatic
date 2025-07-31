#!/bin/bash

# Luckfox Pico Ultra W post-image script
# This script is executed after the image is built

set -e

BOARD_DIR="$1"
PRODUCT="$2"
PRODUCT_VERSION="$3"

echo "Creating Luckfox Pico Ultra W image..."

# Create output directory
mkdir -p ${BINARIES_DIR}/luckfox-pico-ultra-w

# Copy kernel image and device tree
if [ -f "${BINARIES_DIR}/Image" ]; then
    cp "${BINARIES_DIR}/Image" "${BINARIES_DIR}/luckfox-pico-ultra-w/"
fi

if [ -f "${BINARIES_DIR}/rv1106g-luckfox-pico-ultra-w.dtb" ]; then
    cp "${BINARIES_DIR}/rv1106g-luckfox-pico-ultra-w.dtb" "${BINARIES_DIR}/luckfox-pico-ultra-w/"
fi

# Copy U-Boot files
if [ -f "${BINARIES_DIR}/u-boot.img" ]; then
    cp "${BINARIES_DIR}/u-boot.img" "${BINARIES_DIR}/luckfox-pico-ultra-w/"
fi

if [ -f "${BINARIES_DIR}/idbloader.img" ]; then
    cp "${BINARIES_DIR}/idbloader.img" "${BINARIES_DIR}/luckfox-pico-ultra-w/"
fi

# Copy rootfs
if [ -f "${BINARIES_DIR}/rootfs.ext2" ]; then
    cp "${BINARIES_DIR}/rootfs.ext2" "${BINARIES_DIR}/luckfox-pico-ultra-w/"
fi

# Create a simple boot script
cat > "${BINARIES_DIR}/luckfox-pico-ultra-w/boot.scr" << 'EOF'
# Boot script for Luckfox Pico Ultra W
setenv bootargs "console=ttyS2,115200 root=/dev/mmcblk0p2 rootwait"
setenv bootcmd "fatload mmc 0:1 0x80080000 Image; fatload mmc 0:1 0x80f80000 rv1106g-luckfox-pico-ultra-w.dtb; booti 0x80080000 - 0x80f80000"
saveenv
EOF

# Create a README file
cat > "${BINARIES_DIR}/luckfox-pico-ultra-w/README.txt" << EOF
Luckfox Pico Ultra W - RaspberryMatic Image
============================================

Product: ${PRODUCT}
Version: ${PRODUCT_VERSION}
Date: $(date)

Files included:
- Image: Linux kernel image
- rv1106g-luckfox-pico-ultra-w.dtb: Device tree blob
- u-boot.img: U-Boot bootloader
- idbloader.img: Initial bootloader
- rootfs.ext2: Root filesystem
- boot.scr: Boot script

Installation:
1. Flash the rootfs.ext2 to an SD card or eMMC
2. Copy the boot files to the boot partition
3. Insert the storage media into the Luckfox Pico Ultra W
4. Power on the device

For more information, visit: https://github.com/jens-maus/RaspberryMatic
EOF

# Create a compressed archive
cd "${BINARIES_DIR}"
tar -czf "RaspberryMatic-${PRODUCT_VERSION}-luckfox-pico-ultra-w.tar.gz" luckfox-pico-ultra-w/

echo "Luckfox Pico Ultra W image created successfully!"
echo "Archive: ${BINARIES_DIR}/RaspberryMatic-${PRODUCT_VERSION}-luckfox-pico-ultra-w.tar.gz" 