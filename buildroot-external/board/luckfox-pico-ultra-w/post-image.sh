#!/bin/bash

# Post-image script for Luckfox Pico Ultra W
# This script runs after the image is created

set -e

echo "Running Luckfox Pico Ultra W post-image script..."

# Get build variables
BOARD_NAME="luckfox-pico-ultra-w"
BOARD_MODEL="RV1106 Ultra W"
BOARD_VARIANT="Ultra W"
BOARD_SOC="RV1106G3"

# Create board-specific image name
IMAGE_NAME="raspmatic-${BOARD_NAME}-$(date +%Y%m%d)"
echo "Creating image: ${IMAGE_NAME}"

# Create boot partition content
BOOT_DIR="${BINARIES_DIR}/boot"
mkdir -p "${BOOT_DIR}"

# Copy kernel image
if [ -f "${BINARIES_DIR}/Image" ]; then
    cp "${BINARIES_DIR}/Image" "${BOOT_DIR}/"
    echo "Copied kernel Image to boot partition"
fi

# Copy device tree
if [ -f "${BINARIES_DIR}/rv1106g-luckfox-pico-ultra-w.dtb" ]; then
    cp "${BINARIES_DIR}/rv1106g-luckfox-pico-ultra-w.dtb" "${BOOT_DIR}/"
    echo "Copied device tree to boot partition"
fi

# Copy U-Boot
if [ -f "${BINARIES_DIR}/u-boot.img" ]; then
    cp "${BINARIES_DIR}/u-boot.img" "${BOOT_DIR}/"
    echo "Copied U-Boot to boot partition"
fi

# Create boot script
cat > "${BOOT_DIR}/boot.scr" << 'EOF'
# Boot script for Luckfox Pico Ultra W
setenv bootargs "console=ttyS2,115200 root=/dev/mmcblk0p2 rootwait rw"

# Load kernel
fatload mmc 0:1 ${kernel_addr_r} Image

# Load device tree
fatload mmc 0:1 ${fdt_addr_r} rv1106g-luckfox-pico-ultra-w.dtb

# Boot kernel
booti ${kernel_addr_r} - ${fdt_addr_r}
EOF

# Compile boot script
if command -v mkimage >/dev/null 2>&1; then
    mkimage -A arm -T script -C none -n "Boot script" -d "${BOOT_DIR}/boot.scr" "${BOOT_DIR}/boot.scr.uimg"
    echo "Created boot script image"
fi

# Create README
cat > "${BOOT_DIR}/README.txt" << EOF
Luckfox Pico Ultra W Boot Files
===============================

This partition contains the boot files for the Luckfox Pico Ultra W board.

Files:
- Image: Linux kernel image
- rv1106g-luckfox-pico-ultra-w.dtb: Device tree blob
- u-boot.img: U-Boot bootloader
- boot.scr: Boot script
- boot.scr.uimg: Compiled boot script

Board: ${BOARD_MODEL}
SoC: ${BOARD_SOC}
Variant: ${BOARD_VARIANT}

For more information, visit:
https://github.com/LuckfoxTECH/luckfox-pico
EOF

# Create eMMC image for RV1106 boards
if command -v genimage >/dev/null 2>&1; then
    cat > "${BINARIES_DIR}/genimage.cfg" << 'EOF'
image eMMC.img {
    hdimage {
        gpt = true
    }
    
    partition boot {
        partition-type = 0x0C
        bootable = true
        image = "boot.vfat"
        size = 64M
    }
    
    partition rootfs {
        partition-type = 0x83
        image = "rootfs.ext2"
        size = 2G
    }
}
EOF

    # Create boot.vfat
    if [ -d "${BOOT_DIR}" ]; then
        mkfs.vfat -n "BOOT" -S 512 -s 16 -v "${BINARIES_DIR}/boot.vfat" 64M
        mcopy -i "${BINARIES_DIR}/boot.vfat" "${BOOT_DIR}"/* ::/
        echo "Created boot.vfat partition"
    fi
    
    # Create rootfs.ext2
    if [ -f "${BINARIES_DIR}/rootfs.ext2" ]; then
        echo "Using existing rootfs.ext2"
    else
        echo "Creating rootfs.ext2..."
        # This would need to be implemented based on your rootfs
    fi
    
    # Generate eMMC image
    genimage --rootpath "${TARGET_DIR}" --inputpath "${BINARIES_DIR}" --outputpath "${BINARIES_DIR}" --config "${BINARIES_DIR}/genimage.cfg"
    echo "Generated eMMC image: ${BINARIES_DIR}/eMMC.img"
fi

echo "Luckfox Pico Ultra W post-image script completed"
