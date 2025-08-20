#!/bin/bash
# Luckfox Pico Ultra W Build Script
# This script helps build the board with proper configuration

set -e

BOARD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RASPMATIC_DIR="$(cd "${BOARD_DIR}/../../.." && pwd)"
LUCKFOX_SOURCE="${RASPMATIC_DIR}/tmp/luckfox-pico"

echo "=========================================="
echo "Luckfox Pico Ultra W Build Script"
echo "=========================================="

# Check if we're in the right directory
if [ ! -f "${RASPMATIC_DIR}/Makefile" ]; then
    echo "Error: This script must be run from the RaspberryMatic root directory"
    exit 1
fi

# Check if Luckfox source is available
if [ ! -d "${LUCKFOX_SOURCE}" ]; then
    echo "Warning: Luckfox source not found at ${LUCKFOX_SOURCE}"
    echo "Please ensure the luckfox-pico repository is cloned to tmp/luckfox-pico"
    echo "You can clone it with:"
    echo "  cd tmp && git clone https://github.com/LuckfoxTECH/luckfox-pico.git"
    echo ""
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Check dependencies
echo "Checking build dependencies..."
if ! command -v make >/dev/null 2>&1; then
    echo "Error: 'make' command not found"
    exit 1
fi

if ! command -v gcc >/dev/null 2>&1; then
    echo "Error: GCC compiler not found"
    exit 1
fi

# Clean previous builds if requested
if [ "$1" = "clean" ]; then
    echo "Cleaning previous builds..."
    make clean
    echo "Clean completed"
    exit 0
fi

# Show build information
echo "Build Information:"
echo "  Board: Luckfox Pico Ultra W"
echo "  SoC: Rockchip RV1106G3"
echo "  CPU: ARM Cortex-A7 32-bit"
echo "  Storage: EMMC + SD Card"
echo "  Architecture: ARM 32-bit"
echo ""

# Check board configuration
if [ ! -f "${BOARD_DIR}/kernel.config" ]; then
    echo "Error: Kernel configuration not found"
    exit 1
fi

if [ ! -f "${BOARD_DIR}/uboot.config" ]; then
    echo "Error: U-Boot configuration not found"
    exit 1
fi

if [ ! -f "${BOARD_DIR}/post-build.sh" ]; then
    echo "Error: Post-build script not found"
    exit 1
fi

if [ ! -f "${BOARD_DIR}/post-image.sh" ]; then
    echo "Error: Post-image script not found"
    exit 1
fi

echo "Board configuration files found and verified"
echo ""

# Set environment variables for the build
export LF_BOARD_TYPE="luckfox-pico-ultra-w"
export LF_SOC_TYPE="rv1106g3"
export LF_CPU_TYPE="cortex-a7"
export LF_STORAGE_TYPE="emmc"

# Show build command
echo "To build the Luckfox Pico Ultra W image, run:"
echo "  make PRODUCT=raspmatic_luckfox-pico-ultra-w"
echo ""
echo "Or to build with all dependencies:"
echo "  make PRODUCT=raspmatic_luckfox-pico-ultra-w all"
echo ""

# Ask if user wants to start the build
read -p "Start building now? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Starting build..."
    echo ""
    
    # Start the build
    make PRODUCT=raspmatic_luckfox-pico-ultra-w all
    
    echo ""
    echo "Build completed successfully!"
    echo "Output files are in: output/images/"
    echo ""
    echo "To create a bootable SD card, use the install script:"
    echo "  sudo ./output/images/luckfox-pico-ultra-w/install.sh /dev/sdX"
else
    echo "Build not started. You can run it manually when ready."
fi

echo ""
echo "Build script completed."
