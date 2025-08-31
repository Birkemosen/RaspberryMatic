#!/bin/bash

# Script to download Luckfox SDK, extract U-Boot sources, and update buildroot hashes
# This creates a reproducible U-Boot source tarball for the RV1106 build

set -e  # Exit on any error

# Configuration
LUCKFOX_SDK_URL="https://github.com/LuckfoxTECH/luckfox-pico.git"
LUCKFOX_SDK_BRANCH="main"
UBOOT_SOURCE_DIR="luckfox-pico/sysdrv/source/uboot/u-boot"
TARBALL_NAME="uboot-luckfox-rv1106-2023.01.tar.gz"
HASH_FILE="buildroot-2025.05/boot/uboot/uboot.hash"
BUILDROOT_EXTERNAL="buildroot-external"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    if ! command_exists git; then
        print_error "git is not installed"
        exit 1
    fi
    
    if ! command_exists sha256sum; then
        print_error "sha256sum is not installed"
        exit 1
    fi
    
    if ! command_exists tar; then
        print_error "tar is not installed"
        exit 1
    fi
    
    print_success "All prerequisites are available"
}

# Clean up previous downloads
cleanup() {
    print_status "Cleaning up previous downloads..."
    
    if [ -d "luckfox-pico" ]; then
        rm -rf luckfox-pico
        print_success "Removed previous luckfox-pico directory"
    fi
    
    if [ -f "$TARBALL_NAME" ]; then
        rm -f "$TARBALL_NAME"
        print_success "Removed previous tarball"
    fi
}

# Download Luckfox SDK
download_sdk() {
    print_status "Downloading Luckfox SDK from $LUCKFOX_SDK_URL..."
    
    if [ -d "luckfox-pico" ]; then
        print_warning "luckfox-pico directory already exists, updating..."
        cd luckfox-pico
        git fetch origin
        git checkout -f origin/$LUCKFOX_SDK_BRANCH
        cd ..
    else
        git clone --depth 1 --branch $LUCKFOX_SDK_BRANCH $LUCKFOX_SDK_URL
    fi
    
    print_success "Luckfox SDK downloaded successfully"
}

# Extract U-Boot sources and create tarball
create_tarball() {
    print_status "Creating U-Boot source tarball..."
    
    if [ ! -d "$UBOOT_SOURCE_DIR" ]; then
        print_error "U-Boot source directory not found: $UBOOT_SOURCE_DIR"
        exit 1
    fi
    
    # Create tarball with U-Boot sources
    tar -czf "$TARBALL_NAME" \
        --transform "s|$UBOOT_SOURCE_DIR|u-boot|" \
        -C "$(dirname "$UBOOT_SOURCE_DIR")" \
        "$(basename "$UBOOT_SOURCE_DIR")"
    
    print_success "Tarball created: $TARBALL_NAME"
}

# Calculate hash
calculate_hash() {
    print_status "Calculating SHA256 hash..."
    
    HASH_VALUE=$(sha256sum "$TARBALL_NAME" | cut -d' ' -f1)
    print_success "Hash calculated: $HASH_VALUE"
}

# Update hash file
update_hash_file() {
    print_status "Updating hash file: $HASH_FILE"
    
    if [ ! -f "$HASH_FILE" ]; then
        print_error "Hash file not found: $HASH_FILE"
        exit 1
    fi
    
    # Create backup
    cp "$HASH_FILE" "${HASH_FILE}.backup"
    print_success "Backup created: ${HASH_FILE}.backup"
    
    # Add new hash entry
    echo "" >> "$HASH_FILE"
    echo "# Locally computed:" >> "$HASH_FILE"
    echo "sha256  $HASH_VALUE  $TARBALL_NAME" >> "$HASH_FILE"
    
    print_success "Hash file updated successfully"
}

# Update buildroot-external configuration
update_config() {
    print_status "Updating buildroot-external configuration..."
    
    CONFIG_FILE="$BUILDROOT_EXTERNAL/configs/raspmatic_luckfox-pico-ultra-w.config"
    
    if [ ! -f "$CONFIG_FILE" ]; then
        print_error "Configuration file not found: $CONFIG_FILE"
        exit 1
    fi
    
    # Create backup
    cp "$CONFIG_FILE" "${CONFIG_FILE}.backup"
    print_success "Configuration backup created: ${CONFIG_FILE}.backup"
    
    # Update U-Boot configuration to use local tarball
    sed -i 's|BR2_TARGET_UBOOT_CUSTOM_GIT=y|BR2_TARGET_UBOOT_CUSTOM_TARBALL=y|g' "$CONFIG_FILE"
    sed -i 's|BR2_TARGET_UBOOT_CUSTOM_REPO_URL=.*|BR2_TARGET_UBOOT_CUSTOM_TARBALL_LOCATION="$(BR2_EXTERNAL_EQ3_PATH)/downloads/uboot-luckfox-rv1106-2023.01.tar.gz"|g' "$CONFIG_FILE"
    sed -i 's|BR2_TARGET_UBOOT_CUSTOM_REPO_VERSION=.*|# BR2_TARGET_UBOOT_CUSTOM_REPO_VERSION removed|g' "$CONFIG_FILE"
    
    print_success "Configuration updated successfully"
}

# Create downloads directory and move tarball
setup_downloads() {
    print_status "Setting up downloads directory..."
    
    mkdir -p "$BUILDROOT_EXTERNAL/downloads"
    mv "$TARBALL_NAME" "$BUILDROOT_EXTERNAL/downloads/"
    
    print_success "Tarball moved to $BUILDROOT_EXTERNAL/downloads/"
}

# Main execution
main() {
    print_status "Starting Luckfox U-Boot update process..."
    
    # Check if we're in the right directory
    if [ ! -d "buildroot-2025.05" ]; then
        print_error "Please run this script from the RaspberryMatic root directory"
        exit 1
    fi
    
    check_prerequisites
    cleanup
    download_sdk
    create_tarball
    calculate_hash
    update_hash_file
    update_config
    setup_downloads
    
    print_success "Luckfox U-Boot update completed successfully!"
    echo ""
    echo "Summary:"
    echo "  - Tarball created: $BUILDROOT_EXTERNAL/downloads/$TARBALL_NAME"
    echo "  - Hash added to: $HASH_FILE"
    echo "  - Configuration updated: $BUILDROOT_EXTERNAL/configs/raspmatic_luckfox-pico-ultra-w.config"
    echo ""
    echo "Next steps:"
    echo "  1. Review the changes in the configuration file"
    echo "  2. Run: make raspmatic_luckfox-pico-ultra-w"
    echo ""
}

# Run main function
main "$@"