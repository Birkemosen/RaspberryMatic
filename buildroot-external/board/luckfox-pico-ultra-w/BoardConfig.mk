# Luckfox Pico Ultra W Board Configuration
# This file provides the configuration that the Luckfox build.sh script expects

# Chip and Architecture
export RK_CHIP=RV1106
export RK_ARCH=arm
export RK_TOOLCHAIN_CROSS=arm-rockchip830-linux-uclibcgnueabihf

# Boot Medium (EMMC for Pico Ultra W)
export RK_BOOT_MEDIUM=emmc

# Root Filesystem
export LF_TARGET_ROOTFS=buildroot

# U-Boot Configuration
export RK_UBOOT_DEFCONFIG=rv1106-luckfox-rgb-reset
export RK_UBOOT_DEFCONFIG_FRAGMENT=rk-emmc.config

# Kernel Configuration
export RK_KERNEL_DTS=rv1106g-luckfox-pico-ultra-w.dts
export RK_KERNEL_DEFCONFIG=luckfox_rv1106_linux_defconfig
export RK_KERNEL_DEFCONFIG_FRAGMENT=rv1106-luckfox-pico-ultra-w.config

# Buildroot Configuration
export RK_BUILDROOT_DEFCONFIG=luckfox_pico_w_defconfig

# Partition Configuration
export RK_PARTITION_CMD_IN_ENV="4M(uboot),32K(env),32M(boot),1G(rootfs),-(userdata)"
export RK_PARTITION_FS_TYPE_CFG="boot@ext4@/boot,rootfs@ext4@/,userdata@ext4@/data"

# WiFi Configuration
export RK_ENABLE_WIFI=y
export RK_ENABLE_WIFI_CHIP=AIC8800DC
export LF_WIFI_SSID=YourWiFiSSID
export LF_WIFI_PSK=YourWiFiPassword

# Recovery and OTA
export RK_ENABLE_RECOVERY=y
export RK_ENABLE_OTA=y

# Fastboot Support
export RK_ENABLE_FASTBOOT=y
export RK_ENABLE_RAMDISK_PARTITION=y

# Media and ISP Configuration
export RK_CAMERA_SENSOR_IQFILES="rv1106_isp_iqfiles"
export RK_CAMERA_SENSOR_CAC_BIN="rv1106_cac_bin"

# NPU Configuration
export RK_NPU_MODEL=object_detection_pfp.data

# Audio Configuration
export RK_AUDIO_MODEL=rkaudio_ultra_w.rknn

# AI ISP Configuration
export RK_AIISP_MODEL=rv1106_aiisp.aiisp

# Build Options
export RK_BUILD_VERSION_TYPE=RELEASE
export RK_JOBS=4

# Toolchain Path
export RK_PROJECT_TOOLCHAIN_CROSS=${RK_TOOLCHAIN_CROSS}

# Output Paths
export RK_PROJECT_OUTPUT=${SDK_ROOT_DIR}/output/out
export RK_PROJECT_OUTPUT_IMAGE=${SDK_ROOT_DIR}/output/image
export RK_PROJECT_PATH_MEDIA=${RK_PROJECT_OUTPUT}/media_out
export RK_PROJECT_PATH_SYSDRV=${RK_PROJECT_OUTPUT}/sysdrv_out
export RK_PROJECT_PATH_APP=${RK_PROJECT_OUTPUT}/app_out
export RK_PROJECT_PATH_MCU=${RK_PROJECT_OUTPUT}/mcu_out

# Post-build Scripts
export RK_POST_BUILD_SCRIPT=post-build.sh
export RK_POST_OVERLAY="base base-raspmatic"

# Application Configuration
export RK_APP_TYPE=IPC
export RK_APP_DEFCONFIG=luckfox_pico_w_defconfig

# Recovery Configuration
export RK_RECOVERY_KERNEL_DEFCONFIG_FRAGMENT=rv1106-luckfox-pico-ultra-w-recovery.config

# Power Domain Configuration
export RK_BOOTARGS_CMA_SIZE=66M

# Storage Configuration
export RK_ENABLE_SPI_NAND_FAST_BOOT=n

# Buildroot Configuration
export RK_BUILDROOT_DEFCONFIG_FRAGMENT=luckfox_pico_w_defconfig

# Kernel Command Line
export RK_KERNEL_CMDLINE_FRAGMENT="console=ttyS0,115200 root=/dev/mmcblk0p4 rootwait rw rootfstype=ext4"

# Partition Arguments
export RK_PARTITION_ARGS="blkdevparts=mmcblk0:4M(uboot),32K(env),32M(boot),1G(rootfs),-(userdata)"

# EROFS Compression
export RK_EROFS_COMP="-C lz4"

# SquashFS Compression
export RK_SQUASHFS_COMP="-comp lz4"

# UBIFS Configuration
export RK_UBIFS_COMP="-m 2048 -e 126976 -c 2048"

# JFFS2 Configuration
export RK_JFFS2_COMP="-n"

# ROMFS Configuration
export RK_ROMFS_COMP=""

# Initramfs Configuration
export RK_INITRAMFS_COMP=""

# Meta Configuration
export RK_META_SIZE=32M
export RK_META_PARAM="--meta_part_size=32M"
export RK_CAMERA_PARAM="--camera_sensor_iqfiles=rv1106_isp_iqfiles"
export RK_TINY_META=""

# OEM Partition Configuration
export RK_BUILD_APP_TO_OEM_PARTITION=y

# Userdata Configuration
export RK_PRE_BUILD_USERDATA_SCRIPT=""

# Overlay Configuration
export RK_POST_OVERLAY="base base-raspmatic"

# Buildroot Configuration
export RK_BUILDROOT_DEFCONFIG_FRAGMENT=""

# Kernel Configuration Fragment
export RK_KERNEL_DEFCONFIG_FRAGMENT="rv1106-luckfox-pico-ultra-w.config"

# U-Boot Configuration Fragment
export RK_UBOOT_DEFCONFIG_FRAGMENT="rk-emmc.config"

# Recovery Configuration Fragment
export RK_RECOVERY_KERNEL_DEFCONFIG_FRAGMENT="rv1106-luckfox-pico-ultra-w-recovery.config"

# Buildroot Configuration Fragment
export RK_BUILDROOT_DEFCONFIG_FRAGMENT="luckfox_pico_w_defconfig"

# Application Configuration Fragment
export RK_APP_DEFCONFIG_FRAGMENT=""

# Media Configuration Fragment
export RK_MEDIA_DEFCONFIG_FRAGMENT=""

# Toolchain Configuration
export RK_TOOLCHAIN_CROSS_ARCH=arm
export RK_TOOLCHAIN_CROSS_OS=linux
export RK_TOOLCHAIN_CROSS_LIBC=uclibc
export RK_TOOLCHAIN_CROSS_ABI=gnueabihf

# Build Environment
export RK_BUILD_ENV=buildroot
export RK_BUILD_SYSTEM=buildroot
export RK_BUILD_TARGET=all

# Version Information
export RK_SDK_VERSION=1.0.0
export RK_BUILD_DATE=$(date +%Y%m%d)
export RK_BUILD_TIME=$(date +%H%M%S)

# Debug Configuration
export RK_DEBUG=n
export RK_VERBOSE=n

# Clean Configuration
export RK_CLEAN_LEVEL=all

# Save Configuration
export RK_SAVE_CONFIG=y

# Package Configuration
export RK_PACKAGE_TYPE=update
export RK_PACKAGE_FORMAT=img

# Image Configuration
export RK_IMAGE_TYPE=update
export RK_IMAGE_FORMAT=img

# Firmware Configuration
export RK_FIRMWARE_TYPE=update
export RK_FIRMWARE_FORMAT=img

# Recovery Configuration
export RK_RECOVERY_TYPE=recovery
export RK_RECOVERY_FORMAT=img

# OTA Configuration
export RK_OTA_TYPE=ota
export RK_OTA_FORMAT=tar

# Factory Configuration
export RK_FACTORY_TYPE=factory
export RK_FACTORY_FORMAT=img

# TFTP Configuration
export RK_TFTP_TYPE=tftp
export RK_TFTP_FORMAT=img

# SD Card Configuration
export RK_SD_CARD_TYPE=sd
export RK_SD_CARD_FORMAT=img

# EMMC Configuration
export RK_EMMC_TYPE=emmc
export RK_EMMC_FORMAT=img

# SPI NAND Configuration
export RK_SPI_NAND_TYPE=spi_nand
export RK_SPI_NAND_FORMAT=img

# SPI NOR Configuration
export RK_SPI_NOR_TYPE=spi_nor
export RK_SPI_NOR_FORMAT=img

# SLC NAND Configuration
export RK_SLC_NAND_TYPE=slc_nand
export RK_SLC_NAND_FORMAT=img

# Custom Configuration
export RK_CUSTOM_CONFIG=""
export RK_CUSTOM_SCRIPT=""
export RK_CUSTOM_OVERLAY=""

# Development Configuration
export RK_DEV_MODE=n
export RK_DEV_DEBUG=n
export RK_DEV_VERBOSE=n

# Production Configuration
export RK_PROD_MODE=y
export RK_PROD_RELEASE=y
export RK_PROD_STRIP=y

# Testing Configuration
export RK_TEST_MODE=n
export RK_TEST_DEBUG=n
export RK_TEST_VERBOSE=n

# Documentation Configuration
export RK_DOC_MODE=n
export RK_DOC_DEBUG=n
export RK_DOC_VERBOSE=n

# Support Configuration
export RK_SUPPORT_MODE=n
export RK_SUPPORT_DEBUG=n
export RK_SUPPORT_VERBOSE=n

# Community Configuration
export RK_COMMUNITY_MODE=n
export RK_COMMUNITY_DEBUG=n
export RK_COMMUNITY_VERBOSE=n

# Enterprise Configuration
export RK_ENTERPRISE_MODE=n
export RK_ENTERPRISE_DEBUG=n
export RK_ENTERPRISE_VERBOSE=n

# OEM Configuration
export RK_OEM_MODE=n
export RK_OEM_DEBUG=n
export RK_OEM_VERBOSE=n

# Custom Configuration
export RK_CUSTOM_MODE=n
export RK_CUSTOM_DEBUG=n
export RK_CUSTOM_VERBOSE=n
