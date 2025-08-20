#!/bin/bash
# Extract Firmware Script for Luckfox Pico Ultra W
# This script automatically clones the Luckfox repository, extracts firmware files,
# and cleans up afterwards to make the RaspberryMatic project self-contained

set -e

BOARD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FIRMWARE_DIR="${BOARD_DIR}/firmware"
LUCKFOX_REPO="https://github.com/LuckfoxTECH/luckfox-pico.git"
LUCKFOX_BRANCH="main"
TEMP_DIR="${BOARD_DIR}/temp_luckfox_extract"

echo "=========================================="
echo "Extracting Firmware Files for Luckfox Pico Ultra W"
echo "=========================================="

# Check if git is available
if ! command -v git &> /dev/null; then
    echo "❌ Error: git is not installed or not in PATH"
    echo "Please install git to continue"
    exit 1
fi

# Clean up any existing temporary directory
if [ -d "${TEMP_DIR}" ]; then
    echo "🧹 Cleaning up existing temporary directory..."
    rm -rf "${TEMP_DIR}"
fi

# Clone the Luckfox repository
echo "📥 Cloning Luckfox Pico repository..."
echo "Repository: ${LUCKFOX_REPO}"
echo "Branch: ${LUCKFOX_BRANCH}"
echo "Temporary directory: ${TEMP_DIR}"
echo ""

git clone --depth 1 --branch "${LUCKFOX_BRANCH}" "${LUCKFOX_REPO}" "${TEMP_DIR}"

if [ ! -d "${TEMP_DIR}" ]; then
    echo "❌ Error: Failed to clone Luckfox repository"
    exit 1
fi

echo "✅ Successfully cloned Luckfox repository"
echo "📁 Target firmware directory: ${FIRMWARE_DIR}"
echo ""

# Create firmware directory structure
echo "Creating firmware directory structure..."
mkdir -p "${FIRMWARE_DIR}/uboot/rkbin/bin/rv11"
mkdir -p "${FIRMWARE_DIR}/uboot/rkbin/RKBOOT"
mkdir -p "${FIRMWARE_DIR}/uboot/rkbin/RKTRUST"
mkdir -p "${FIRMWARE_DIR}/uboot/configs"
mkdir -p "${FIRMWARE_DIR}/wifi/aic8800dc"
mkdir -p "${FIRMWARE_DIR}/mcu"
mkdir -p "${FIRMWARE_DIR}/kernel"
mkdir -p "${FIRMWARE_DIR}/media/isp_iqfiles"
mkdir -p "${FIRMWARE_DIR}/media/avs_calib"

echo "✅ Directory structure created"
echo ""

# Extract U-Boot firmware files
echo "Extracting U-Boot firmware files..."

# Copy RV1106 binary files
if [ -d "${TEMP_DIR}/sysdrv/source/uboot/rkbin/bin/rv11" ]; then
    echo "  📁 Copying RV1106 binary files..."
    cp -r "${TEMP_DIR}/sysdrv/source/uboot/rkbin/bin/rv11"/* \
           "${FIRMWARE_DIR}/uboot/rkbin/bin/rv11/" 2>/dev/null || true
    
    # Count copied files
    count=$(find "${FIRMWARE_DIR}/uboot/rkbin/bin/rv11" -type f | wc -l)
    echo "    ✅ Copied $count RV1106 binary files"
else
    echo "  ❌ RV1106 binary directory not found"
fi

# Copy RKBOOT configuration files
if [ -d "${TEMP_DIR}/sysdrv/source/uboot/rkbin/RKBOOT" ]; then
    echo "  📁 Copying RKBOOT configuration files..."
    cp -r "${TEMP_DIR}/sysdrv/source/uboot/rkbin/RKBOOT"/* \
           "${FIRMWARE_DIR}/uboot/rkbin/RKBOOT/" 2>/dev/null || true
    
    count=$(find "${FIRMWARE_DIR}/uboot/rkbin/RKBOOT" -type f | wc -l)
    echo "    ✅ Copied $count RKBOOT configuration files"
else
    echo "  ❌ RKBOOT directory not found"
fi

# Copy RKTRUST files
if [ -d "${TEMP_DIR}/sysdrv/source/uboot/rkbin/RKTRUST" ]; then
    echo "  📁 Copying RKTRUST files..."
    cp -r "${TEMP_DIR}/sysdrv/source/uboot/rkbin/RKTRUST"/* \
           "${FIRMWARE_DIR}/uboot/rkbin/RKTRUST/" 2>/dev/null || true
    
    count=$(find "${FIRMWARE_DIR}/uboot/rkbin/RKTRUST" -type f | wc -l)
    echo "    ✅ Copied $count RKTRUST files"
else
    echo "  ❌ RKTRUST directory not found"
fi

# Copy U-Boot configuration fragments
if [ -f "${TEMP_DIR}/sysdrv/source/uboot/u-boot/configs/rk-emmc.config" ]; then
    echo "  📁 Copying U-Boot configuration fragments..."
    cp "${TEMP_DIR}/sysdrv/source/uboot/u-boot/configs/rk-emmc.config" \
       "${FIRMWARE_DIR}/uboot/configs/" 2>/dev/null || true
    echo "    ✅ Copied rk-emmc.config"
fi

if [ -f "${TEMP_DIR}/sysdrv/source/uboot/u-boot/configs/rv1106-luckfox-rgb-reset.config" ]; then
    cp "${TEMP_DIR}/sysdrv/source/uboot/u-boot/configs/rv1106-luckfox-rgb-reset.config" \
       "${FIRMWARE_DIR}/uboot/configs/" 2>/dev/null || true
    echo "    ✅ Copied rv1106-luckfox-rgb-reset.config"
fi

echo ""

# Extract WiFi firmware files
echo "Extracting WiFi firmware files..."

if [ -d "${TEMP_DIR}/sysdrv/drv_ko/wifi/aic8800dc/aic8800dc_fw" ]; then
    echo "  📁 Copying AIC8800DC WiFi firmware..."
    cp -r "${TEMP_DIR}/sysdrv/drv_ko/wifi/aic8800dc/aic8800dc_fw"/* \
           "${FIRMWARE_DIR}/wifi/aic8800dc/" 2>/dev/null || true
    
    count=$(find "${FIRMWARE_DIR}/wifi/aic8800dc" -type f | wc -l)
    echo "    ✅ Copied $count WiFi firmware files"
else
    echo "  ❌ AIC8800DC WiFi firmware directory not found"
fi

echo ""

# Extract kernel modules and drivers
echo "Extracting kernel modules and drivers..."

if [ -d "${TEMP_DIR}/sysdrv/drv_ko" ]; then
    echo "  📁 Copying kernel modules..."
    cp -r "${TEMP_DIR}/sysdrv/drv_ko"/* \
           "${FIRMWARE_DIR}/kernel/" 2>/dev/null || true
    
    count=$(find "${FIRMWARE_DIR}/kernel" -type f | wc -l)
    echo "    ✅ Copied $count kernel module files"
else
    echo "  ❌ Kernel modules directory not found"
fi

echo ""

# Extract MCU firmware
echo "Extracting MCU firmware..."

if [ -d "${TEMP_DIR}/sysdrv/source/mcu" ]; then
    echo "  📁 Copying MCU firmware and scripts..."
    cp -r "${TEMP_DIR}/sysdrv/source/mcu"/* \
           "${FIRMWARE_DIR}/mcu/" 2>/dev/null || true
    
    count=$(find "${FIRMWARE_DIR}/mcu" -type f | wc -l)
    echo "    ✅ Copied $count MCU files"
else
    echo "  ❌ MCU directory not found"
fi

echo ""

# Extract media and ISP files
echo "Extracting media and ISP files..."

# Check if media output exists (may need to build first)
if [ -d "${TEMP_DIR}/output/out/media_out/isp_iqfiles" ]; then
    echo "  📁 Copying ISP IQ files..."
    cp -r "${TEMP_DIR}/output/out/media_out/isp_iqfiles"/* \
           "${FIRMWARE_DIR}/media/isp_iqfiles/" 2>/dev/null || true
    
    count=$(find "${FIRMWARE_DIR}/media/isp_iqfiles" -type f | wc -l)
    echo "    ✅ Copied $count ISP IQ files"
else
    echo "  ⚠️  ISP IQ files not found (may need to build media components first)"
    echo "     Run: cd ${TEMP_DIR}/project && ./build.sh media"
fi

if [ -d "${TEMP_DIR}/output/out/media_out/avs_calib" ]; then
    echo "  📁 Copying calibration files..."
    cp -r "${TEMP_DIR}/output/out/media_out/avs_calib"/* \
           "${FIRMWARE_DIR}/media/avs_calib/" 2>/dev/null || true
    
    count=$(find "${FIRMWARE_DIR}/media/avs_calib" -type f | wc -l)
    echo "    ✅ Copied $count calibration files"
else
    echo "  ⚠️  Calibration files not found (may need to build media components first)"
fi

echo ""

# Create firmware info file
echo "Creating firmware information file..."
cat > "${FIRMWARE_DIR}/firmware-info.txt" << EOF
Luckfox Pico Ultra W Firmware Information
==========================================

Extraction Date: $(date)
Source: ${LUCKFOX_REPO} (${LUCKFOX_BRANCH} branch)
Target: ${FIRMWARE_DIR}

Firmware Components:
- U-Boot: $(find "${FIRMWARE_DIR}/uboot" -type f | wc -l) files
- WiFi: $(find "${FIRMWARE_DIR}/wifi" -type f | wc -l) files
- MCU: $(find "${FIRMWARE_DIR}/mcu" -type f | wc -l) files
- Kernel: $(find "${FIRMWARE_DIR}/kernel" -type f | wc -l) files
- Media: $(find "${FIRMWARE_DIR}/media" -type f | wc -l) files

Total Files: $(find "${FIRMWARE_DIR}" -type f | wc -l)

Note: This firmware directory is now self-contained and does not require
the original Luckfox source repository for building.
EOF

echo "✅ Firmware information file created"
echo ""

# Summary
echo "=========================================="
echo "Firmware Extraction Summary"
echo "=========================================="

TOTAL_FILES=$(find "${FIRMWARE_DIR}" -type f | wc -l)
TOTAL_SIZE=$(du -sh "${FIRMWARE_DIR}" | cut -f1)

echo "Total firmware files extracted: $TOTAL_FILES"
echo "Total firmware size: $TOTAL_SIZE"
echo ""
echo "🎉 Firmware extraction completed successfully!"
echo ""
echo "Next steps:"
echo "1. Review extracted firmware files in: ${FIRMWARE_DIR}"
echo "2. Update post-build and post-image scripts to use local firmware"
echo "3. Remove dependency on tmp/luckfox-pico repository"
echo "4. Test build with local firmware files"
echo ""
echo "Firmware extraction completed."

# Clean up temporary directory
echo ""
echo "🧹 Cleaning up temporary files..."
if [ -d "${TEMP_DIR}" ]; then
    rm -rf "${TEMP_DIR}"
    echo "✅ Temporary directory removed: ${TEMP_DIR}"
else
    echo "⚠️  Temporary directory not found for cleanup"
fi

echo ""
echo "🎯 RaspberryMatic is now self-contained with all necessary firmware files!"
