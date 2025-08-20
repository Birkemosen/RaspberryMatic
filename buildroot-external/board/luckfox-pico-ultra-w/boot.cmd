# Luckfox Pico Ultra W Boot Commands
# This file contains U-Boot boot commands for the board

# Set boot delay
setenv bootdelay 0

# Set boot command for EMMC boot
setenv bootcmd "mmc dev 0; mmc read ${kernel_addr_r} ${kernel_offset} ${kernel_size}; bootm ${kernel_addr_r}"

# Set boot arguments
setenv bootargs "console=ttyS0,115200 root=/dev/mmcblk0p4 rootwait rw"

# Set kernel address
setenv kernel_addr_r 0x80008000
setenv kernel_offset 0x8000
setenv kernel_size 0x400000

# Set device tree address
setenv fdt_addr_r 0x82000000
setenv fdt_offset 0x400000
setenv fdt_size 0x10000

# Set ramdisk address
setenv ramdisk_addr_r 0x82100000
setenv ramdisk_offset 0x410000
setenv ramdisk_size 0x100000

# Set environment variables
setenv ethaddr 00:11:22:33:44:55
setenv ipaddr 192.168.1.100
setenv serverip 192.168.1.1
setenv netmask 255.255.255.0
setenv gatewayip 192.168.1.1

# Save environment
saveenv
