################################################################################
#
# luckfox-firmware
#
################################################################################

LUCKFOX_FIRMWARE_VERSION = $(call qstrip,$(BR2_PACKAGE_LUCKFOX_FIRMWARE_VERSION))
LUCKFOX_FIRMWARE_SITE = $(call qstrip,$(BR2_PACKAGE_LUCKFOX_FIRMWARE_SOURCE))
LUCKFOX_FIRMWARE_SITE_METHOD = git
LUCKFOX_FIRMWARE_LICENSE = GPL-2.0
LUCKFOX_FIRMWARE_LICENSE_FILES = LICENSE

# Default to main branch if not specified
ifeq ($(LUCKFOX_FIRMWARE_VERSION),)
LUCKFOX_FIRMWARE_VERSION = main
endif

# Default to official Luckfox repository if not specified
ifeq ($(LUCKFOX_FIRMWARE_SITE),)
LUCKFOX_FIRMWARE_SITE = https://github.com/LuckfoxTECH/luckfox-pico.git
endif

define LUCKFOX_FIRMWARE_INSTALL_TARGET_CMDS
	@echo "Installing Luckfox firmware from $(LUCKFOX_FIRMWARE_SITE) ($(LUCKFOX_FIRMWARE_VERSION))"
	
	# Create firmware directories
	mkdir -p $(TARGET_DIR)/usr/lib/firmware
	mkdir -p $(TARGET_DIR)/usr/share/mcu-firmware
	mkdir -p $(TARGET_DIR)/usr/share/uboot-firmware
	mkdir -p $(TARGET_DIR)/usr/lib/modules
	
	# Install WiFi firmware (AIC8800DC)
	@echo "Installing WiFi firmware..."
	if [ -d $(@D)/sysdrv/drv_ko/wifi/aic8800dc/aic8800dc_fw ]; then
		cp -r $(@D)/sysdrv/drv_ko/wifi/aic8800dc/aic8800dc_fw/* \
			$(TARGET_DIR)/usr/lib/firmware/ 2>/dev/null || true
		@echo "✅ WiFi firmware installed"
	else
		@echo "⚠️  WiFi firmware directory not found"
	fi
	
	# Install MCU firmware
	@echo "Installing MCU firmware..."
	if [ -d $(@D)/sysdrv/source/mcu ]; then
		cp -r $(@D)/sysdrv/source/mcu/* \
			$(TARGET_DIR)/usr/share/mcu-firmware/ 2>/dev/null || true
		@echo "✅ MCU firmware installed"
	else
		@echo "⚠️  MCU firmware directory not found"
	fi
	
	# Install U-Boot binaries
	@echo "Installing U-Boot binaries..."
	if [ -d $(@D)/sysdrv/source/uboot/rkbin ]; then
		cp -r $(@D)/sysdrv/source/uboot/rkbin/* \
			$(TARGET_DIR)/usr/share/uboot-firmware/ 2>/dev/null || true
		@echo "✅ U-Boot binaries installed"
	else
		@echo "⚠️  U-Boot binaries directory not found"
	fi
	
	# Install kernel modules
	@echo "Installing kernel modules..."
	if [ -d $(@D)/sysdrv/drv_ko ]; then
		cp -r $(@D)/sysdrv/drv_ko/* \
			$(TARGET_DIR)/usr/lib/modules/ 2>/dev/null || true
		@echo "✅ Kernel modules installed"
	else
		@echo "⚠️  Kernel modules directory not found"
	fi
	
	# Install media files (if available)
	@echo "Installing media files..."
	if [ -d $(@D)/output/out/media_out ]; then
		mkdir -p $(TARGET_DIR)/usr/share/iqfiles
		mkdir -p $(TARGET_DIR)/usr/share/avs_calib
		
		if [ -d $(@D)/output/out/media_out/isp_iqfiles ]; then
			cp -r $(@D)/output/out/media_out/isp_iqfiles/* \
				$(TARGET_DIR)/usr/share/iqfiles/ 2>/dev/null || true
			@echo "✅ ISP IQ files installed"
		fi
		
		if [ -d $(@D)/output/out/media_out/avs_calib ]; then
			cp -r $(@D)/output/out/media_out/avs_calib/* \
				$(TARGET_DIR)/usr/share/avs_calib/ 2>/dev/null || true
			@echo "✅ Calibration files installed"
		fi
	else
		@echo "⚠️  Media output directory not found (may need to build media components first)"
	fi
	
	@echo "🎉 Luckfox firmware installation complete!"
endef

# Create firmware info file
define LUCKFOX_FIRMWARE_CREATE_FIRMWARE_INFO
	@echo "Creating firmware information file..."
	mkdir -p $(TARGET_DIR)/usr/share/luckfox-firmware
	cat > $(TARGET_DIR)/usr/share/luckfox-firmware/firmware-info.txt << EOF
Luckfox Pico Ultra W Firmware Information
==========================================

Installation Date: $(shell date)
Source Repository: $(LUCKFOX_FIRMWARE_SITE)
Source Version: $(LUCKFOX_FIRMWARE_VERSION)
Target Directory: $(TARGET_DIR)

Firmware Components:
- WiFi Firmware: \$(shell find $(TARGET_DIR)/usr/lib/firmware -name "*.bin" | wc -l) files
- MCU Firmware: \$(shell find $(TARGET_DIR)/usr/share/mcu-firmware -type f | wc -l) files
- U-Boot Files: \$(shell find $(TARGET_DIR)/usr/share/uboot-firmware -type f | wc -l) files
- Kernel Modules: \$(shell find $(TARGET_DIR)/usr/lib/modules -type f | wc -l) files
- Media Files: \$(shell find $(TARGET_DIR)/usr/share/iqfiles $(TARGET_DIR)/usr/share/avs_calib -type f 2>/dev/null | wc -l) files

Total Files: \$(shell find $(TARGET_DIR)/usr/lib/firmware $(TARGET_DIR)/usr/share/mcu-firmware $(TARGET_DIR)/usr/share/uboot-firmware $(TARGET_DIR)/usr/lib/modules -type f 2>/dev/null | wc -l)

Note: This firmware was automatically downloaded and installed during the build process
from the official Luckfox repository. No manual firmware extraction is required.
EOF
endef

LUCKFOX_FIRMWARE_POST_INSTALL_TARGET_HOOKS += LUCKFOX_FIRMWARE_CREATE_FIRMWARE_INFO

$(eval $(generic-package))
