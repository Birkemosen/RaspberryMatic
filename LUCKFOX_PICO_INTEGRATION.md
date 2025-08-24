# Luckfox Pico Integration with RaspberryMatic

This document describes the integration of Luckfox Pico development boards with RaspberryMatic, providing a powerful smart home solution with AI capabilities.

## 🎯 **Overview**

RaspberryMatic is a free, open-source operating system alternative for running a cloud-free smart-home IoT central that provides connectivity to HomeMatic/homematicIP hardware. By integrating Luckfox Pico boards, we add:

- **Camera/ISP Support** - Smart home monitoring and security
- **NPU Acceleration** - AI-powered home automation (RV1106)
- **Modern Kernel** - Linux 6.1 from Rockchip's develop-6.1 branch
- **Full HomeMatic Compatibility** - 100% compatible with CCU3 systems
- **Official SDK Integration** - Based on LuckfoxTECH SDK v1.4

## 🚀 **Key Benefits**

### **For Smart Home Users**
- **Cloud-Free Operation** - Complete local control
- **AI-Powered Automation** - Motion detection, object recognition
- **Security Monitoring** - Built-in camera with ISP processing
- **Professional Grade** - Based on proven RaspberryMatic system

### **For Developers**
- **Modern Hardware** - RV1103/RV1106 SoCs with latest kernel
- **AI Development** - NPU for custom machine learning models
- **Extensible Platform** - Easy to add custom functionality
- **Open Source** - Full access to source code and customization
- **Official SDK** - Direct integration with LuckfoxTECH SDK

## 🔧 **Hardware Support**

### **Supported Boards**
Based on [LuckfoxTECH/luckfox-pico](https://github.com/LuckfoxTECH/luckfox-pico) SDK v1.4:

- **RV1103 Series** (1GB RAM)
  - Luckfox Pico
  - Luckfox Pico Mini
  - Luckfox Pico Plus
  - Luckfox Pico WebBee

- **RV1106 Series** (2GB RAM)
  - Luckfox Pico Ultra
  - Luckfox Pico Ultra W
  - Luckfox Pico Pro Max

### **Hardware Features**
- **CPU**: ARM Cortex-A7 dual-core @ 1.2GHz
- **GPU**: Mali-400 MP2
- **NPU**: 1.2 TOPS AI accelerator (RV1106 only)
- **Camera**: ISP with support for multiple sensors
- **Storage**: SD Card, eMMC, SPI NAND
- **Connectivity**: WiFi, Ethernet, USB, I2C, SPI, GPIO

## 📋 **Installation**

### **Prerequisites**
- Luckfox Pico development board
- MicroSD card (8GB+ recommended)
- USB-C cable for power
- Network connection (WiFi or Ethernet)

### **Quick Start**
1. **Download Image**
   ```bash
   # Download the latest RaspberryMatic image for Luckfox Pico
   wget https://github.com/jens-maus/RaspberryMatic/releases/latest/download/raspmatic-luckfox-pico-latest.img.gz
   ```

2. **Flash to SD Card**
   ```bash
   # Extract and flash the image
   gunzip raspmatic-luckfox-pico-latest.img.gz
   sudo dd if=raspmatic-luckfox-pico-latest.img of=/dev/sdX bs=4M status=progress
   ```

3. **Boot and Configure**
   - Insert SD card into Luckfox Pico
   - Power on the board
   - Access RaspberryMatic at `http://homematic-raspi/`
   - Follow the setup wizard

## 🏗️ **Building from Source**

### **Build Environment**
```bash
# Clone RaspberryMatic repository
git clone https://github.com/jens-maus/RaspberryMatic.git
cd RaspberryMatic

# Build for Luckfox Pico
make raspmatic_luckfox-pico
```

### **Build Options**
```bash
# Build with specific features
make raspmatic_luckfox-pico_defconfig
make menuconfig  # Customize configuration
make -j$(nproc)  # Build the system
```

## 🔌 **HomeMatic Integration**

### **Standard HomeMatic Features**
- **RF Modules** - Support for all HomeMatic RF devices
- **Wired Systems** - BidCos wired device support
- **homematicIP** - Cloud-free IP-based communication
- **Add-ons** - Full CCU3 add-on compatibility

### **Luckfox Pico Specific Features**
- **Camera Integration** - Motion detection and security monitoring
- **AI Analysis** - NPU-powered object recognition (RV1106)
- **GPIO Control** - Direct hardware control for custom devices
- **Sensor Integration** - I2C/SPI sensor support

### **Add-on Development**
```bash
# Create custom HomeMatic add-on
mkdir -p /opt/luckfox-pico/homematic/addons/my-addon
cat > /opt/luckfox-pico/homematic/addons/my-addon/addon.cfg << 'EOF'
[Addon]
Name=My Custom Addon
Version=1.0
Description=Custom addon for Luckfox Pico
Author=Your Name
EOF
```

## 📷 **Camera and AI Features**

### **Camera Support**
Based on LuckfoxTECH SDK specifications:
- **Multiple Sensors** - OV5640, OV2640, GC2145, IMX219
- **ISP Processing** - Hardware image stabilization, auto-focus
- **Video Formats** - H.264, H.265, MJPEG
- **Resolutions** - Up to 4K support

### **AI Capabilities** (RV1106 only)
- **Object Detection** - People, vehicles, animals
- **Motion Analysis** - Intelligent motion detection
- **Face Recognition** - Identify family members
- **Custom Models** - Load your own AI models

### **AI Integration Example**
```bash
# Run AI analysis on camera feed
/opt/luckfox-pico/scripts/ai-analysis.sh

# Check AI processing status
cat /var/log/ai-analysis.log

# View camera feed
ffplay /dev/video0
```

## 🌐 **Network and Connectivity**

### **WiFi Configuration**
```bash
# Configure WiFi
wpa_passphrase "YourSSID" "YourPassword" > /etc/wpa_supplicant.conf
systemctl restart wpa_supplicant

# Check WiFi status
iwconfig
iw dev wlan0 link
```

### **Ethernet Configuration**
```bash
# Configure static IP
cat > /etc/network/interfaces << 'EOF'
auto eth0
iface eth0 inet static
    address 192.168.1.100
    netmask 255.255.255.0
    gateway 192.168.1.1
EOF

# Restart networking
systemctl restart networking
```

## 🔧 **System Administration**

### **System Information**
```bash
# Board information
/opt/luckfox-pico/scripts/board-info.sh

# System status
systemctl status luckfox-camera
systemctl status luckfox-npu

# Hardware detection
lsmod | grep luckfox
ls /dev/video* /dev/npu* /dev/gpiochip*
```

### **Logs and Debugging**
```bash
# View system logs
journalctl -u luckfox-camera
journalctl -u luckfox-npu

# Check kernel messages
dmesg | grep -i luckfox

# Monitor system resources
htop
iotop
```

### **Updates and Maintenance**
```bash
# Update system packages
apt update && apt upgrade

# Update HomeMatic
# Use the RaspberryMatic web interface

# Backup configuration
tar -czf homematic-backup.tar.gz /opt/luckfox-pico/homematic/
```

## 🚀 **Performance Optimization**

### **System Tuning**
```bash
# Enable performance governor
echo performance | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# Optimize memory usage
echo 1 > /proc/sys/vm/drop_caches

# Optimize storage
fstrim -v /
```

### **AI Model Optimization** (RV1106 only)
```bash
# Optimize NPU performance
echo 800000000 > /sys/class/devfreq/npu/cur_freq

# Monitor NPU usage
cat /sys/class/devfreq/npu/cur_freq
cat /sys/class/devfreq/npu/available_frequencies
```

## 🐛 **Troubleshooting**

### **Common Issues**

1. **Camera Not Working**
   ```bash
   # Check camera drivers
   lsmod | grep isp
   ls /dev/video*
   
   # Restart camera service
   systemctl restart luckfox-camera
   ```

2. **NPU Not Responding** (RV1106 only)
   ```bash
   # Check NPU drivers
   lsmod | grep npu
   ls /dev/npu*
   
   # Restart NPU service
   systemctl restart luckfox-npu
   ```

3. **WiFi Connection Issues**
   ```bash
   # Check WiFi status
   iw dev wlan0 link
   
   # Restart WiFi
   systemctl restart wpa_supplicant
   ```

### **Debug Mode**
```bash
# Enable debug logging
echo "DEBUG=1" >> /etc/luckfox-pico.conf

# Restart services
systemctl restart luckfox-camera luckfox-npu

# Check debug logs
journalctl -f -u luckfox-camera
```

## 📚 **Development and Customization**

### **Adding Custom Drivers**
```bash
# Create custom driver
mkdir -p /opt/luckfox-pico/drivers
cat > /opt/luckfox-pico/drivers/my-driver.ko << 'EOF'
# Custom driver module
EOF

# Load custom driver
insmod /opt/luckfox-pico/drivers/my-driver.ko
```

### **Custom HomeMatic Scripts**
```bash
# Create custom script
cat > /opt/luckfox-pico/homematic/scripts/custom.sh << 'EOF'
#!/bin/bash
# Custom HomeMatic script
echo "Custom script executed at $(date)"
EOF

chmod +x /opt/luckfox-pico/homematic/scripts/custom.sh
```

### **API Integration**
```bash
# Create REST API endpoint
cat > /opt/luckfox-pico/api/server.py << 'EOF'
#!/usr/bin/env python3
from flask import Flask, jsonify
import subprocess

app = Flask(__name__)

@app.route('/api/camera/status')
def camera_status():
    result = subprocess.run(['ls', '/dev/video*'], capture_output=True, text=True)
    return jsonify({'cameras': result.stdout.split()})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
EOF
```

## 🔗 **Community and Support**

### **Resources**
- [RaspberryMatic Wiki](https://github.com/jens-maus/RaspberryMatic/wiki)
- [Luckfox Pico Documentation](https://github.com/LuckfoxTECH/luckfox-pico)
- [HomeMatic Community](https://homematic-forum.de/)
- [Rockchip Linux Kernel](https://github.com/rockchip-linux/kernel)

### **Getting Help**
- **GitHub Issues** - Report bugs and request features
- **Community Forum** - Ask questions and share solutions
- **Documentation** - Comprehensive guides and examples
- **Discord/Slack** - Real-time community support

## 📄 **License and Contributions**

### **License**
This integration is released under the same license as RaspberryMatic (GPL-2.0).

### **Contributing**
We welcome contributions! Please see:
- [Contributing Guidelines](CONTRIBUTING.md)
- [Development Guide](DEVELOPMENT.md)
- [Code of Conduct](CODE_OF_CONDUCT.md)

### **Acknowledgments**
- **RaspberryMatic Team** - For the excellent base system
- **LuckfoxTECH** - For the amazing Pico hardware and SDK
- **Rockchip** - For the Linux kernel support
- **HomeMatic Community** - For the smart home ecosystem

---

**Happy Smart Home Automation with Luckfox Pico and RaspberryMatic! 🏠✨**
