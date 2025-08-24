#!/bin/bash

# Post-image script for Luckfox Pico boards in RaspberryMatic
# This script runs after the image creation process

set -e

# Source the common post-image functions
. "${BR2_EXTERNAL_EQ3_PATH}/board/post-image.sh"

echo "Running Luckfox Pico post-image script..."

# Create board-specific image name
BOARD_NAME="luckfox-pico"
IMAGE_NAME="${BOARD_NAME}-raspmatic-${BR2_VERSION}-${BR2_EXTERNAL_EQ3_VERSION}"

# Create SD card image for Luckfox Pico
create_sd_image() {
    echo "Creating SD card image for Luckfox Pico..."
    
    # Create output directory
    mkdir -p "${BINARIES_DIR}"
    
    # Create empty image file (2GB for Luckfox Pico)
    IMAGE_FILE="${BINARIES_DIR}/${IMAGE_NAME}.img"
    dd if=/dev/zero of="${IMAGE_FILE}" bs=1M count=2048
    
    # Create partition table
    parted "${IMAGE_FILE}" mklabel msdos
    parted "${IMAGE_FILE}" mkpart primary fat32 2048s 133119s
    parted "${IMAGE_FILE}" mkpart primary ext4 133120s 4194303s
    
    # Get loop device
    LOOP_DEV=$(losetup -f)
    losetup -P "${LOOP_DEV}" "${IMAGE_FILE}"
    
    # Format partitions
    mkfs.vfat -F 32 -n BOOT "${LOOP_DEV}p1"
    mkfs.ext4 -L rootfs "${LOOP_DEV}p2"
    
    # Mount partitions
    mkdir -p /tmp/boot /tmp/rootfs
    mount "${LOOP_DEV}p1" /tmp/boot
    mount "${LOOP_DEV}p2" /tmp/rootfs
    
    # Copy U-Boot
    if [ -f "${BINARIES_DIR}/u-boot.img" ]; then
        cp "${BINARIES_DIR}/u-boot.img" /tmp/boot/
    fi
    if [ -f "${BINARIES_DIR}/trust.img" ]; then
        cp "${BINARIES_DIR}/trust.img" /tmp/boot/
    fi
    
    # Copy kernel and device tree
    if [ -f "${BINARIES_DIR}/Image" ]; then
        cp "${BINARIES_DIR}/Image" /tmp/boot/
    fi
    if [ -d "${BINARIES_DIR}" ]; then
        cp "${BINARIES_DIR}"/*.dtb /tmp/boot/ 2>/dev/null || true
    fi
    
    # Copy rootfs
    if [ -f "${BINARIES_DIR}/rootfs.tar" ]; then
        tar -xf "${BINARIES_DIR}/rootfs.tar" -C /tmp/rootfs
    fi
    
    # Create boot script for Luckfox Pico
    cat > /tmp/boot/boot.scr << 'EOF'
# Boot script for Luckfox Pico with RaspberryMatic

# Set boot arguments
setenv bootargs "console=ttyS2,115200 root=/dev/mmcblk0p2 rootwait rw"

# Load kernel
fatload mmc 0:1 ${kernel_addr_r} Image

# Load device tree
fatload mmc 0:1 ${fdt_addr_r} rv1106-luckfox-pico-ultra.dtb

# Boot system
booti ${kernel_addr_r} - ${fdt_addr_r}
EOF

    # Compile boot script
    mkimage -A arm -T script -C none -n "Boot script" -d /tmp/boot/boot.scr /tmp/boot/boot.scr.uimg
    
    # Create README for SD card
    cat > /tmp/boot/README.txt << 'EOF'
Luckfox Pico RaspberryMatic SD Card

This SD card contains RaspberryMatic for Luckfox Pico boards.

Contents:
- U-Boot bootloader
- Linux kernel 6.1 (Rockchip develop-6.1)
- RaspberryMatic system
- HomeMatic/homematicIP support

Installation:
1. Insert SD card into Luckfox Pico
2. Power on the board
3. Access RaspberryMatic at http://homematic-raspi/

Features:
- Camera/ISP support for smart home monitoring
- NPU for AI-powered automation
- Full HomeMatic compatibility
- WiFi and Ethernet connectivity

For more information, visit:
https://github.com/jens-maus/RaspberryMatic
https://github.com/LuckfoxTECH/luckfox-pico
EOF

    # Unmount partitions
    umount /tmp/boot /tmp/rootfs
    losetup -d "${LOOP_DEV}"
    
    echo "SD card image created: ${IMAGE_FILE}"
}

# Create eMMC image for RV1106 boards
create_emmc_image() {
    echo "Creating eMMC image for Luckfox Pico..."
    
    # Create eMMC image name
    EMMC_IMAGE_NAME="${BOARD_NAME}-emmc-raspmatic-${BR2_VERSION}-${BR2_EXTERNAL_EQ3_VERSION}"
    EMMC_IMAGE_FILE="${BINARIES_DIR}/${EMMC_IMAGE_NAME}.img"
    
    # Copy SD image as base for eMMC
    cp "${IMAGE_FILE}" "${EMMC_IMAGE_FILE}"
    
    # Create eMMC README
    cat > "${BINARIES_DIR}/README_EMMC.txt" << 'EOF'
Luckfox Pico eMMC RaspberryMatic Image

This image is optimized for eMMC installation on RV1106 Luckfox Pico boards.

Installation:
1. Flash this image to eMMC using Rockchip tools
2. Boot from eMMC for faster performance
3. Access RaspberryMatic at http://homematic-raspi/

eMMC Advantages:
- Faster boot times
- Better reliability
- Higher performance
- Larger storage capacity

Note: eMMC installation requires Rockchip flashing tools
EOF
    
    echo "eMMC image created: ${EMMC_IMAGE_FILE}"
}

# Create compressed archives
create_archives() {
    echo "Creating compressed archives..."
    
    # Create SD card archive
    cd "${BINARIES_DIR}"
    tar -czf "${IMAGE_NAME}.tar.gz" "${IMAGE_NAME}.img"
    
    # Create eMMC archive
    if [ -f "${EMMC_IMAGE_NAME}.img" ]; then
        tar -czf "${EMMC_IMAGE_NAME}.tar.gz" "${EMMC_IMAGE_NAME}.img"
    fi
    
    echo "Compressed archives created"
}

# Create checksums
create_checksums() {
    echo "Creating checksums..."
    
    cd "${BINARIES_DIR}"
    
    # Create SHA256 checksums
    sha256sum *.img *.tar.gz > SHA256SUMS
    
    # Create MD5 checksums
    md5sum *.img *.tar.gz > MD5SUMS
    
    echo "Checksums created"
}

# Main execution
main() {
    echo "Starting Luckfox Pico post-image processing..."
    
    # Create SD card image
    create_sd_image
    
    # Create eMMC image
    create_emmc_image
    
    # Create compressed archives
    create_archives
    
    # Create checksums
    create_checksums
    
    echo "Luckfox Pico post-image script completed successfully"
    echo "Generated files in ${BINARIES_DIR}:"
    ls -la "${BINARIES_DIR}"/*.img "${BINARIES_DIR}"/*.tar.gz "${BINARIES_DIR}"/*SUMS 2>/dev/null || true
}

# Run main function
main "$@"
