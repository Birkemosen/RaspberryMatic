#!/bin/bash
# Luckfox Pico Ultra W Post-Build Script
# This script runs after the main build to configure board-specific settings

set -e

BOARD_DIR="${BR2_EXTERNAL_EQ3_PATH}/board/luckfox-pico-ultra-w"
TARGET_DIR="${TARGET_DIR:-${BUILD_DIR}/target}"
BINARIES_DIR="${BINARIES_DIR:-${BUILD_DIR}/images}"

echo "Running Luckfox Pico Ultra W post-build script..."

# Create necessary directories
mkdir -p "${TARGET_DIR}/etc/init.d"
mkdir -p "${TARGET_DIR}/etc/rc.d"
mkdir -p "${TARGET_DIR}/usr/bin"
mkdir -p "${TARGET_DIR}/usr/lib"
mkdir -p "${TARGET_DIR}/usr/share/iqfiles"

# Copy board-specific files from overlay
if [ -d "${BOARD_DIR}/overlay" ]; then
    echo "Copying board overlay files..."
    cp -r "${BOARD_DIR}/overlay"/* "${TARGET_DIR}/" 2>/dev/null || true
fi

# Firmware installation is now handled by Buildroot package system
echo "✅ Firmware installation handled by Buildroot package system"
echo "   No manual firmware copying required"

# Create board-specific init script
cat > "${TARGET_DIR}/etc/init.d/S20luckfox-setup" << 'EOF'
#!/bin/sh
# Luckfox Pico Ultra W Board Setup Script

case "$1" in
    start)
        echo "Setting up Luckfox Pico Ultra W board..."
        
        # Set up GPIO
        if [ -d /sys/class/gpio ]; then
            # Export commonly used GPIO pins
            echo 0 > /sys/class/gpio/export 2>/dev/null || true
            echo 1 > /sys/class/gpio/export 2>/dev/null || true
            echo 2 > /sys/class/gpio/export 2>/dev/null || true
            echo 3 > /sys/class/gpio/export 2>/dev/null || true
        fi
        
        # Set up I2C
        if [ -e /dev/i2c-0 ]; then
            echo "I2C-0 available"
        fi
        
        # Set up SPI
        if [ -e /dev/spidev0.0 ]; then
            echo "SPI-0 available"
        fi
        
        # Set up UART
        if [ -e /dev/ttyS0 ]; then
            echo "UART-0 available"
        fi
        if [ -e /dev/ttyS1 ]; then
            echo "UART-1 available"
        fi
        
        # Set up WiFi power management
        if [ -e /sys/module/rk_wifi/parameters/power_mode ]; then
            echo 1 > /sys/module/rk_wifi/parameters/power_mode
        fi
        
        # Set up Bluetooth power management
        if [ -e /sys/module/rk_bluetooth/parameters/power_mode ]; then
            echo 1 > /sys/module/rk_bluetooth/parameters/power_mode
        fi
        
        echo "Luckfox Pico Ultra W board setup complete"
        ;;
    stop)
        echo "Stopping Luckfox Pico Ultra W board services..."
        ;;
    restart)
        $0 stop
        $0 start
        ;;
    *)
        echo "Usage: $0 {start|stop|restart}"
        exit 1
        ;;
esac

exit 0
EOF

chmod +x "${TARGET_DIR}/etc/init.d/S20luckfox-setup"

# Create symlink for rc.d
ln -sf ../init.d/S20luckfox-setup "${TARGET_DIR}/etc/rc.d/S20luckfox-setup" 2>/dev/null || true

# Create modules load configuration
cat > "${TARGET_DIR}/etc/modules-load.d/luckfox.conf" << 'EOF'
# Luckfox Pico Ultra W Kernel Modules
# WiFi and Bluetooth
aic8800dc
aic8800_btlpm

# Camera and ISP
rockchip_isp
rockchip_isp_dphy

# NPU
rockchip_rvnpu

# GPIO and I2C
rockchip_gpio
i2c_dev

# USB
dwc3
dwc3_rockchip

# Storage
mmc_block
sdhci
sdhci_pltfm
EOF

# Create board info file
cat > "${TARGET_DIR}/etc/luckfox-board-info" << 'EOF'
# Luckfox Pico Ultra W Board Information
BOARD_NAME="Luckfox Pico Ultra W"
SOC="Rockchip RV1106G3"
CPU="ARM Cortex-A7 32-bit with NEON and FPU"
NPU="4th generation NPU with 1TOPS int8 performance"
ISP="3rd generation ISP3.2 with 5MP support"
MEMORY="16-bit DDR3L DRAM"
WIFI="WiFi 6 (802.11ax)"
BLUETOOTH="Bluetooth 5.2/BLE"
STORAGE="8GB eMMC + microSD card slot"
GPIO="40-pin header (Raspberry Pi compatible)"
USB="USB 2.0 Type-C"
ETHERNET="10/100M Ethernet port"
EOF

# Create board-specific environment
cat > "${TARGET_DIR}/etc/environment" << 'EOF'
# Luckfox Pico Ultra W Environment Variables
BOARD_TYPE=luckfox-pico-ultra-w
SOC_TYPE=rv1106g3
CPU_TYPE=cortex-a7
NPU_ENABLED=1
ISP_ENABLED=1
WIFI_ENABLED=1
BLUETOOTH_ENABLED=1
EOF

# Set up board-specific permissions
if [ -e "${TARGET_DIR}/etc/udev/rules.d" ]; then
    cat > "${TARGET_DIR}/etc/udev/rules.d/99-luckfox-gpio.rules" << 'EOF'
# Luckfox Pico Ultra W GPIO permissions
SUBSYSTEM=="gpio", KERNEL=="gpiochip*", ACTION=="add", PROGRAM="/bin/sh -c 'chown -R root:gpio /sys/class/gpio && chmod -R 770 /sys/class/gpio'"
SUBSYSTEM=="gpio", KERNEL=="gpio*", ACTION=="add", PROGRAM="/bin/sh -c 'chown root:gpio /sys/class/gpio/export /sys/class/gpio/unexport ; chmod 220 /sys/class/gpio/export /sys/class/gpio/unexport'"
EOF
fi

# Create board-specific systemd service if systemd is enabled
if [ -e "${TARGET_DIR}/lib/systemd/system" ]; then
    cat > "${TARGET_DIR}/lib/systemd/system/luckfox-board.service" << 'EOF'
[Unit]
Description=Luckfox Pico Ultra W Board Setup
After=local-fs.target
Before=network.target

[Service]
Type=oneshot
ExecStart=/etc/init.d/S20luckfox-setup start
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

    # Enable the service
    mkdir -p "${TARGET_DIR}/etc/systemd/system/multi-user.target.wants"
    ln -sf /lib/systemd/system/luckfox-board.service "${TARGET_DIR}/etc/systemd/system/multi-user.target.wants/"
fi

echo "Luckfox Pico Ultra W post-build script completed successfully."
