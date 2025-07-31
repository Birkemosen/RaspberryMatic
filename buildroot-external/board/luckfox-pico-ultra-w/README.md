# Luckfox Pico Ultra W Support for RaspberryMatic

This directory contains the board-specific configuration for the Luckfox Pico Ultra W single-board computer to run RaspberryMatic.

## Hardware Specifications

- **SoC**: Rockchip RV1106G3
- **CPU**: ARM Cortex-A7 dual-core @ 1.2GHz
- **RAM**: 1GB LPDDR4
- **Storage**: 8GB eMMC + microSD card slot
- **Network**: 10/100M Ethernet + WiFi (RTL8723DS) + Bluetooth
- **USB**: 1x USB 2.0 Type-C
- **GPIO**: 40-pin header compatible with Raspberry Pi
- **Display**: RGB LED + Status LED
- **Power**: 5V via USB-C or GPIO header

## Features

- **WiFi Support**: Built-in RTL8723DS WiFi module
- **Bluetooth Support**: Built-in Bluetooth 4.2
- **Ethernet**: 10/100M Ethernet port
- **Storage**: eMMC and microSD card support
- **GPIO**: 40-pin GPIO header with Raspberry Pi compatibility
- **USB**: USB 2.0 Type-C port for power and data

## Build Configuration

The board uses the following configuration:

- **Architecture**: ARM 32-bit (armv7)
- **Kernel**: Linux 5.10 from Luckfox repository
- **Bootloader**: U-Boot 2023.01
- **Root Filesystem**: ext4 on eMMC or SD card
- **Device Tree**: rv1106g-luckfox-pico-ultra-w.dts

## Build Instructions

To build RaspberryMatic for the Luckfox Pico Ultra W:

```bash
cd RaspberryMatic
make PRODUCT=raspmatic_luckfox-pico-ultra-w
```

## Installation

1. Download the generated image from the build output
2. Flash the image to an SD card or eMMC
3. Insert the storage media into the Luckfox Pico Ultra W
4. Power on the device
5. Access the web interface at `http://homematic-raspi/`

## WiFi Configuration

The board supports automatic WiFi configuration through environment variables:

```bash
export LF_WIFI_SSID="Your WiFi SSID"
export LF_WIFI_PSK="Your WiFi Password"
```

## GPIO Support

The board provides a 40-pin GPIO header compatible with Raspberry Pi pinout. GPIO access is available through:

- `/sys/class/gpio/` sysfs interface
- `libgpiod` tools and library
- WiringPi compatibility layer

## Troubleshooting

### Serial Console

The board provides a serial console on UART2 (ttyS2) at 115200 baud. Connect a USB-to-serial adapter to access the console for debugging.

### Boot Issues

If the board doesn't boot:
1. Check the power supply (5V required)
2. Verify the SD card/eMMC is properly flashed
3. Check the serial console for error messages
4. Ensure the device tree and kernel are compatible

### WiFi Issues

If WiFi doesn't work:
1. Check the WiFi credentials in the configuration
2. Verify the RTL8723DS firmware is loaded
3. Check the serial console for WiFi-related errors

## References

- [Luckfox Pico Ultra W Documentation](https://github.com/LuckfoxTECH/luckfox-pico)
- [RaspberryMatic Documentation](https://github.com/jens-maus/RaspberryMatic/wiki)
- [Rockchip RV1106 Documentation](https://www.rock-chips.com/a/en/products/RV11X/2019/1025/1001.html) 