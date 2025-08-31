################################################################################
#
# luckfox-pico-drivers
#
################################################################################

LUCKFOX_PICO_DRIVERS_VERSION = main
LUCKFOX_PICO_DRIVERS_SITE = $(TOPDIR)/../luckfox-pico
LUCKFOX_PICO_DRIVERS_SITE_METHOD = local
LUCKFOX_PICO_DRIVERS_LICENSE = GPL-2.0
LUCKFOX_PICO_DRIVERS_LICENSE_FILES = LICENSE

# Define the SDK paths based on LuckfoxTECH repository structure
LUCKFOX_PICO_DRIVERS_SDK_SYSDRV = $(@D)/sysdrv
LUCKFOX_PICO_DRIVERS_SDK_MEDIA = $(@D)/media
LUCKFOX_PICO_DRIVERS_SDK_PROJECT = $(@D)/project

define LUCKFOX_PICO_DRIVERS_EXTRACT_CMDS
	# Extract the SDK and prepare driver sources
	$(MAKE) -C $(@D) clean
	$(MAKE) -C $(@D) env
endef

define LUCKFOX_PICO_DRIVERS_BUILD_CMDS
	# Build the kernel drivers from SDK
	$(MAKE) -C $(LUCKFOX_PICO_DRIVERS_SDK_SYSDRV) \
		ARCH=arm \
		CROSS_COMPILE=$(TARGET_CROSS) \
		KERNEL_SRC=$(LINUX_DIR) \
		KERNEL_OUT=$(LINUX_DIR) \
		KERNEL_MODULES_OUT=$(TARGET_DIR)/lib/modules/$(LINUX_VERSION_PROBED) \
		modules
	
	# Build media libraries if needed
	if [ -d "$(LUCKFOX_PICO_DRIVERS_SDK_MEDIA)" ]; then
		$(MAKE) -C $(LUCKFOX_PICO_DRIVERS_SDK_MEDIA) \
			ARCH=arm \
			CROSS_COMPILE=$(TARGET_CROSS) \
			KERNEL_SRC=$(LINUX_DIR) \
			KERNEL_OUT=$(LINUX_DIR) \
			KERNEL_MODULES_OUT=$(TARGET_DIR)/lib/modules/$(LINUX_VERSION_PROBED) \
			modules
	fi
endef

define LUCKFOX_PICO_DRIVERS_INSTALL_TARGET_CMDS
	# Install kernel driver modules from SDK
	$(MAKE) -C $(LUCKFOX_PICO_DRIVERS_SDK_SYSDRV) \
		ARCH=arm \
		CROSS_COMPILE=$(TARGET_CROSS) \
		KERNEL_SRC=$(LINUX_DIR) \
		KERNEL_OUT=$(LINUX_DIR) \
		KERNEL_MODULES_OUT=$(TARGET_DIR)/lib/modules/$(LINUX_VERSION_PROBED) \
		modules_install
	
	# Install media driver modules if available
	if [ -d "$(LUCKFOX_PICO_DRIVERS_SDK_MEDIA)" ]; then
		$(MAKE) -C $(LUCKFOX_PICO_DRIVERS_SDK_MEDIA) \
			ARCH=arm \
			CROSS_COMPILE=$(TARGET_CROSS) \
			KERNEL_SRC=$(LINUX_DIR) \
			KERNEL_OUT=$(LINUX_DIR) \
			KERNEL_MODULES_OUT=$(TARGET_DIR)/lib/modules/$(LINUX_VERSION_PROBED) \
			modules_install
	fi
	
	# Install device tree overlays from SDK
	if [ -d "$(LUCKFOX_PICO_DRIVERS_SDK_PROJECT)/cfg/BoardConfig_IPC" ]; then
		find $(LUCKFOX_PICO_DRIVERS_SDK_PROJECT)/cfg/BoardConfig_IPC -name "*.dts" -exec \
			$(INSTALL) -D -m 0644 {} $(TARGET_DIR)/boot/overlays/ \;
	fi
	
	# Install firmware files from SDK
	if [ -d "$(LUCKFOX_PICO_DRIVERS_SDK_PROJECT)/cfg/firmware" ]; then
		$(INSTALL) -D -m 0644 $(LUCKFOX_PICO_DRIVERS_SDK_PROJECT)/cfg/firmware/* \
			$(TARGET_DIR)/lib/firmware/ 2>/dev/null || true
	fi
	
	# Install udev rules for Luckfox Pico devices
	$(INSTALL) -D -m 0644 $(@D)/udev/*.rules $(TARGET_DIR)/etc/udev/rules.d/ 2>/dev/null || true
	
	# Install configuration files from SDK
	if [ -d "$(LUCKFOX_PICO_DRIVERS_SDK_PROJECT)/cfg" ]; then
		$(INSTALL) -D -m 0644 $(LUCKFOX_PICO_DRIVERS_SDK_PROJECT)/cfg/*.conf \
			$(TARGET_DIR)/etc/luckfox/ 2>/dev/null || true
	fi
	
	# Install HomeMatic integration scripts
	$(INSTALL) -D -m 0755 $(@D)/scripts/*.sh $(TARGET_DIR)/opt/luckfox-pico/scripts/ 2>/dev/null || true
	
	# Install systemd services
	$(INSTALL) -D -m 0644 $(@D)/systemd/*.service $(TARGET_DIR)/etc/systemd/system/ 2>/dev/null || true
	
	# Enable services
	mkdir -p $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants/
	ln -sf /etc/systemd/system/luckfox-camera.service $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants/ 2>/dev/null || true
	ln -sf /etc/systemd/system/luckfox-npu.service $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants/ 2>/dev/null || true
	
	# Create driver version file
	echo "Luckfox Pico Drivers v$(LUCKFOX_PICO_DRIVERS_VERSION)" > $(TARGET_DIR)/etc/luckfox/driver-version.txt
	echo "Built from SDK: $(LUCKFOX_PICO_DRIVERS_SITE)" >> $(TARGET_DIR)/etc/luckfox/driver-version.txt
	echo "Build date: $(shell date)" >> $(TARGET_DIR)/etc/luckfox/driver-version.txt
endef

# Define dependencies
LUCKFOX_PICO_DRIVERS_DEPENDENCIES = linux

# Handle the case where SDK might not be available
define LUCKFOX_PICO_DRIVERS_CONFIGURE_CMDS
	# Check if SDK is properly extracted
	if [ ! -d "$(LUCKFOX_PICO_DRIVERS_SDK_SYSDRV)" ]; then \
		echo "Warning: LuckfoxTECH SDK sysdrv directory not found"; \
		echo "Drivers may not be properly built"; \
	fi; \
	if [ ! -d "$(LUCKFOX_PICO_DRIVERS_SDK_MEDIA)" ]; then \
		echo "Warning: LuckfoxTECH SDK media directory not found"; \
		echo "Media drivers may not be available"; \
	fi
endef

$(eval $(generic-package))
