# Luckfox Pico Ultra W Support for RaspberryMatic

This document describes the implementation of support for the Luckfox Pico Ultra W single-board computer in RaspberryMatic.

## Overview

The Luckfox Pico Ultra W is a powerful single-board computer based on the Rockchip RV1106G3 SoC, featuring WiFi, Bluetooth, and Ethernet connectivity. This implementation adds full support for running RaspberryMatic on this hardware platform.

## Implementation Details

### 1. Board Configuration

**Location**: `buildroot-external/board/luckfox-pico-ultra-w/`

**Files Created**:
- `kernel.config` - Kernel configuration fragment for RV1106 architecture
- `uboot.config` - U-Boot configuration fragment
- `post-build.sh` - Post-build script for board-specific setup
- `post-image.sh` - Post-image script for creating bootable images
- `README.md` - Board documentation

### 2. Buildroot Configuration

**Location**: `buildroot-external/configs/raspmatic_luckfox-pico-ultra-w.config`

**Key Features**:
- ARM 32-bit architecture (armv7)
- Linux kernel 5.10 from Luckfox repository
- U-Boot 2023.01 bootloader
- ext4 root filesystem
- WiFi and Bluetooth support
- GPIO and hardware support

### 3. Kernel Support

**Kernel Source**: https://github.com/LuckfoxTECH/luckfox-pico

**Device Tree**: `rv1106g-luckfox-pico-ultra-w.dts`

**Kernel Configuration**:
- RV1106 SoC support
- MMC/SD card support
- USB support (DWC3)
- WiFi support (RTL8723DS)
- Bluetooth support
- GPIO support
- Serial console support
- Network support (Ethernet)

### 4. Kernel Patches

**Location**: `buildroot-external/board/luckfox-pico-ultra-w/kernel-patches/`

**Patch**: `0001-add-luckfox-pico-ultra-w-device-tree.patch`
- Adds the device tree file for the Luckfox Pico Ultra W
- Includes all necessary hardware definitions
- Configures WiFi, Bluetooth, and other peripherals

### 5. Boot Configuration

**U-Boot Configuration**:
- ARM architecture support
- Rockchip RV1106 support
- MMC boot support
- Network boot support
- USB support
- Device tree support

**Boot Process**:
1. U-Boot loads from eMMC/SD card
2. Device tree is loaded
3. Kernel is loaded
4. Root filesystem is mounted
5. System boots to RaspberryMatic

## Hardware Features Supported

### Storage
- **eMMC**: 8GB built-in storage
- **SD Card**: microSD card slot
- **File Systems**: ext4, FAT32, NTFS

### Network
- **Ethernet**: 10/100M Ethernet port
- **WiFi**: RTL8723DS WiFi module (802.11 b/g/n)
- **Bluetooth**: Bluetooth 4.2 support

### Connectivity
- **USB**: USB 2.0 Type-C port
- **GPIO**: 40-pin header (Raspberry Pi compatible)
- **Serial**: UART2 console (115200 baud)

### Power
- **Input**: 5V via USB-C or GPIO header
- **Power Management**: Suspend/resume support

## Build Instructions

### Prerequisites
- Ubuntu 22.04 or similar Linux distribution
- Build dependencies (see RaspberryMatic documentation)

### Build Command
```bash
cd RaspberryMatic
make PRODUCT=raspmatic_luckfox-pico-ultra-w
```

### Build Output
The build will create:
- `RaspberryMatic-<version>-luckfox-pico-ultra-w.tar.gz` - Complete image archive
- Boot files (kernel, device tree, U-Boot)
- Root filesystem image

## Installation

### Method 1: SD Card
1. Flash the rootfs.ext2 to an SD card
2. Copy boot files to the boot partition
3. Insert SD card and power on

### Method 2: eMMC
1. Flash the complete image to eMMC
2. Power on the device

### First Boot
1. Connect to the device via Ethernet or WiFi
2. Access web interface at `http://homematic-raspi/`
3. Configure HomeMatic settings

## Configuration

### WiFi Setup
Set environment variables before building:
```bash
export LF_WIFI_SSID="Your WiFi SSID"
export LF_WIFI_PSK="Your WiFi Password"
```

### GPIO Access
GPIO is accessible through:
- `/sys/class/gpio/` sysfs interface
- `libgpiod` tools
- WiringPi compatibility

## Troubleshooting

### Serial Console
Connect USB-to-serial adapter to access console:
- Port: UART2 (ttyS2)
- Baud rate: 115200
- Pinout: TX, RX, GND

### Common Issues
1. **Boot failure**: Check power supply and storage media
2. **WiFi not working**: Verify credentials and firmware
3. **GPIO issues**: Check permissions and pin assignments

## Integration with Luckfox Repository

The implementation leverages the official Luckfox repository for:
- Kernel source code
- Device tree definitions
- Hardware-specific drivers
- Bootloader configuration

This ensures compatibility and access to the latest hardware support.

## Future Enhancements

Potential improvements:
1. **NPU Support**: Enable RV1106's neural processing unit
2. **Camera Support**: Add support for camera modules
3. **Audio Support**: Enable audio input/output
4. **Performance Optimization**: Tune for better performance
5. **Power Management**: Enhanced power saving features

## References

- [Luckfox Pico Repository](https://github.com/LuckfoxTECH/luckfox-pico)
- [RaspberryMatic Documentation](https://github.com/jens-maus/RaspberryMatic/wiki)
- [Rockchip RV1106 Documentation](https://www.rock-chips.com/a/en/products/RV11X/2019/1025/1001.html)
- [Luckfox Pico Ultra W Hardware Documentation](https://wiki.luckfox.com/Luckfox-Pico-Ultra-W)

## License

This implementation follows the same license as RaspberryMatic and the Luckfox repository. 