# Luckfox Pico Ultra W Board Support

This directory contains the board-specific configuration for the Luckfox Pico Ultra W single-board computer in RaspberryMatic.

## Hardware Overview

The Luckfox Pico Ultra W is a powerful AI-focused single-board computer featuring:

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

- `BoardConfig.mk` - Board configuration matching Luckfox build.sh expectations
- `kernel.config` - Kernel configuration fragment
- `recovery-kernel.config` - Recovery kernel configuration fragment
- `uboot.config` - U-Boot configuration fragment
- `post-build.sh` - Post-build setup script
- `post-image.sh` - Post-image packaging script
- `README.md` - This file

**Note**: Firmware extraction scripts are no longer needed as firmware is automatically managed by Buildroot.

## Building

To build RaspberryMatic for this board:

```bash
cd RaspberryMatic
make PRODUCT=raspmatic_luckfox-pico-ultra-w all
```

**Note**: Firmware files are automatically downloaded from the Luckfox repository during the build process. No manual firmware extraction is required.

## Features

- Full ARM Cortex-A7 compatibility
- Hardware-accelerated AI/ML with NPU
- Professional camera support with ISP
- WiFi 6 and Bluetooth 5.2
- Raspberry Pi compatible GPIO
- EMMC and SD card boot support

## Dependencies

This board configuration is **self-contained** and does not require external dependencies during build time.

**Note**: Firmware files are automatically downloaded from the Luckfox Pico repository during the build process.

## Build.sh Compatibility

The `BoardConfig.mk` file provides full compatibility with the Luckfox `build.sh` script:

- **Hardware Selection**: RV1106_Luckfox_Pico_Ultra_W (index 6)
- **Boot Medium**: EMMC (8GB internal storage)
- **System**: Buildroot
- **Partition Layout**: 4M(uboot), 32K(env), 32M(boot), 1G(rootfs), -(userdata)
- **WiFi**: AIC8800DC with WiFi 6 support
- **Recovery**: Full recovery system with OTA support
- **Fastboot**: Enhanced boot performance

## Firmware Management

Firmware is automatically managed by the Buildroot package system:

- **Automatic Download**: Firmware is downloaded from Luckfox repository during build
- **No Manual Extraction**: Build process handles everything automatically
- **Always Fresh**: Latest firmware versions are used for each build
- **Clean Repository**: No firmware files stored in RaspberryMatic codebase

**Build Process**: Single command downloads and installs all firmware

## Firmware Files

The integration automatically downloads and installs firmware files from the Luckfox repository during build:

### WiFi Firmware (AIC8800DC)
- **Source**: Downloaded from Luckfox repository during build
- **Files**: WiFi firmware binaries for 802.11ax support
- **Destination**: `/usr/lib/firmware/` in the target system

### Kernel Modules
- **Source**: Downloaded from Luckfox repository during build
- **Contents**: WiFi, Bluetooth, camera, and NPU drivers
- **Destination**: `/usr/lib/modules/` in the target system

### U-Boot Firmware
- **Source**: Downloaded from Luckfox repository during build
- **Contents**: RV1106 binaries, RKBOOT, RKTRUST, and configs
- **Destination**: `/usr/share/uboot-firmware/` in the target system

### MCU Firmware
- **Source**: Downloaded from Luckfox repository during build
- **Contents**: Microcontroller firmware and scripts
- **Destination**: `/usr/share/mcu-firmware/` in the target system

### Media Files
- **Source**: Downloaded from Luckfox repository during build
- **Contents**: ISP IQ files and calibration data (when available)
- **Destination**: `/usr/share/iqfiles/` and `/usr/share/avs_calib/` in the target system
