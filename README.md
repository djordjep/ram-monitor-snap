# RAM Monitor 🖥️

[![Snap Status](https://snapcraft.io/ram-monitor/badge.svg)](https://snapcraft.io/ram-monitor)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub issues](https://img.shields.io/github/issues/djordjep/ram-monitor-snap)](https://github.com/djordjep/ram-monitor-snap/issues)
[![GitHub stars](https://img.shields.io/github/stars/djordjep/ram-monitor-snap)](https://github.com/djordjep/ram-monitor-snap/stargazers)

A lightweight Linux RAM usage monitor that runs in your desktop session and sends notifications when memory usage exceeds a specified threshold.

## ✨ Features

- **Continuous Monitoring**: Real-time RAM usage tracking every 60 seconds
- **Desktop Notifications**: Native system notifications when threshold exceeded
- **Flexible Configuration**: Environment variables, snap config, or command-line
- **Desktop Autostart**: Starts automatically when you log into your desktop session
- **Lightweight**: Minimal resource usage (< 1MB memory, < 0.1% CPU)
- **Cross-Distribution**: Works on Ubuntu, Fedora, Debian, and other Linux distros
- **Snap Confinement**: Secure sandboxed execution

## 📋 Table of Contents

- [Installation](#installation)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Usage](#usage)
- [Technical Details](#technical-details)
- [Troubleshooting](#troubleshooting)
- [Development](#development)
- [Contributing](#contributing)
- [License](#license)

## 🚀 Installation

### .deb Package (Recommended)

Download the latest `.deb` package from [GitHub Releases](https://github.com/djordjep/ram-monitor-snap/releases):

```bash
# Download and install
wget https://github.com/djordjep/ram-monitor-snap/releases/download/v0.2.0/ram-monitor_0.2.0_amd64.deb
sudo dpkg -i ram-monitor_0.2.0_amd64.deb

# Verify installation
systemctl --user status ram-monitor.service
```

**What happens after install:**
- ✅ Service starts automatically on login
- ✅ Monitors with default 80% threshold
- ✅ Desktop notifications work reliably
- ✅ Survives system reboots
- ✅ View logs: `journalctl --user -u ram-monitor`

### Snap Package (Limited)

⚠️ **Note**: Snap has limitations with autostart and notifications. Use `.deb` for best experience.

```bash
# Install from Snap Store
sudo snap install ram-monitor

# Manual start required
snap run ram-monitor.ram-monitor
```

### Manual Installation (Development)

```bash
# Clone repository
git clone https://github.com/djordjep/ram-monitor-snap.git
cd ram-monitor-snap

# Build .deb (recommended)
dpkg-deb --build deb-package ram-monitor_0.1.6_amd64.deb
sudo dpkg -i ram-monitor_0.1.6_amd64.deb

# Or build snap (limited functionality)
snapcraft pack --destructive-mode
sudo snap install ram-monitor_*.snap --dangerous
```

### System Requirements

- **OS**: Linux with systemd
- **Snap**: snapd ≥ 2.36
- **Desktop**: Environment with libnotify support (GNOME, KDE, XFCE, etc.)
- **Memory**: < 1MB additional RAM usage
- **Storage**: ~15MB installed size
- **Permissions**: Desktop notifications access

## ⚡ Quick Start

1. **Install**: `sudo snap install ram-monitor`
2. **Configure** (optional): `RAM_THRESHOLD=75 snap run ram-monitor.ram-monitor`
3. **Monitor**: Check system notifications when RAM usage is high
4. **Status**: `pgrep -fa ram-monitor.sh` (should show running process)

### Example Notification
```
High RAM Usage Alert
Current usage: 85.3% (exceeds 80%)
```

## 🔧 Technical Details

### Architecture
- **Language**: Bash shell script
- **Packaging**: Snap (confined sandbox)
- **Startup model**: Desktop session autostart (`snap/gui/ram-monitor.desktop`)
- **Monitoring**: `/proc/meminfo` via `free` command
- **Notifications**: libnotify via `notify-send`

### How RAM Calculation Works
```bash
# Get total and used memory from /proc/meminfo
total=$(free -m | awk '/Mem/ {print $2}')      # Total RAM in MB
used=$(free -m | awk '/Mem/ {print $3}')       # Used RAM in MB
percentage=$(awk "BEGIN {printf \"%.2f\", $used/$total * 100}")
```

### RAM Percentage Differences
**Important**: The script may show different RAM percentages than your system monitor:

- **Script calculation**: Physical memory only (`used/total * 100`)
- **System monitors**: May include buffers, cache, or use different rounding
- **Example**: Script shows 53%, system monitor shows 63%

**Recommendation**: Set thresholds based on what the script reports, not your system monitor. Test with `RAM_THRESHOLD=50 snap run ram-monitor.ram-monitor` to see actual behavior.

### Startup Configuration
```yaml
autostart: ram-monitor.desktop
plugs: [desktop, desktop-legacy, wayland, x11]  # Desktop notification paths
```

### Snap Interfaces
- **desktop**: Access to X11/Wayland for notifications
- **desktop-legacy**: Compatibility with older desktop environments

### Performance Characteristics
- **CPU Usage**: < 0.1% average
- **Memory Usage**: ~800KB resident
- **Disk I/O**: Minimal (logs only)
- **Network**: None required

## 📖 Usage

### Runtime Operation
The RAM monitor starts automatically when your desktop session starts:

```bash
# Check running process
pgrep -fa ram-monitor.sh

# View logs
snap logs ram-monitor -f

# Stop temporarily
sudo snap stop ram-monitor

# Start again
sudo snap start ram-monitor
```

### Manual Testing
For testing and debugging, you can run manually:

```bash
# Test with custom threshold
RAM_THRESHOLD=50 timeout 120 snap run ram-monitor.ram-monitor

# Check RAM usage manually
free -h && echo "Usage: $(free | awk '/Mem/ {printf "%.1f%%", $3/$2 * 100}')"
```

### Help System
```bash
# Show built-in help
snap run ram-monitor.ram-monitor --help

# Check snap info
snap info ram-monitor
```

### Notification Examples
When threshold is exceeded, you'll see notifications like:
- **Title**: "High RAM Usage Alert"
- **Body**: "Current usage: 85.3% (exceeds 80%)"
- **Urgency**: Normal
- **Timeout**: System default

## ⚙️ Configuration

### Priority Order
Settings are applied in this order (highest priority first):

1. **Environment Variables** (temporary, overrides all)
2. **Snap Configuration** (persistent, system-wide)
3. **Command-line Arguments** (manual testing only)
4. **Defaults** (built-in fallbacks)

### Default Values
- **Threshold**: 80% RAM usage
- **Check Interval**: 60 seconds
- **Cooldown Period**: 5 minutes after notification
- **Notification Urgency**: Normal

### Configuration Methods

#### Environment Variables (Primary Method)
```bash
# One-time override
RAM_THRESHOLD=70 snap run ram-monitor.ram-monitor

# Temporary testing
RAM_THRESHOLD=50 timeout 60 snap run ram-monitor.ram-monitor

# Manual run with custom threshold
RAM_THRESHOLD=60 snap run ram-monitor.ram-monitor
```

#### Persistent Configuration
Add to your shell profile for permanent settings:
```bash
# Add to ~/.bashrc or ~/.zshrc
echo 'export RAM_THRESHOLD=75' >> ~/.bashrc
source ~/.bashrc

# Verify
echo $RAM_THRESHOLD
```

#### Example Configurations

```bash
# Conservative (alert at 70%)
RAM_THRESHOLD=70 snap run ram-monitor.ram-monitor

# Aggressive (alert at 90%)
RAM_THRESHOLD=90 snap run ram-monitor.ram-monitor

# Development machine (alert at 50%)
RAM_THRESHOLD=50 snap run ram-monitor.ram-monitor
```

## 🔍 Troubleshooting

### Common Issues

#### No Notifications Appearing
```bash
# Check if monitor process is running
pgrep -fa ram-monitor.sh

# Test notifications manually
notify-send "Test" "This is a test notification"

# Check snap logs
snap logs ram-monitor -n 50

# Verify desktop interface connection
snap connections ram-monitor
```

#### High CPU/Memory Usage
- **Issue**: RAM monitor itself using too many resources
- **Check**: `ps aux | grep ram-monitor`
- **Expected**: < 1MB RAM, < 0.1% CPU

#### Configuration Not Applied
```bash
# Check if RAM_THRESHOLD is set
echo $RAM_THRESHOLD

# Test with explicit environment variable
RAM_THRESHOLD=70 snap run ram-monitor.ram-monitor

# For persistent settings, check your shell profile
grep RAM_THRESHOLD ~/.bashrc ~/.zshrc 2>/dev/null || echo "Not found in profile"
```

#### Threshold Not Triggering
```bash
# Test current RAM usage
free -m | awk '/Mem/ {printf "%.2f", $3/$2 * 100}'

# Test with low threshold to verify
RAM_THRESHOLD=30 snap run ram-monitor.ram-monitor

# Note: Script uses physical memory only
# May differ from system monitor readings
```

#### Service Won't Start
```bash
# Check systemd status
systemctl status snap.ram-monitor.ram-monitor.service

# View detailed logs
journalctl -u snap.ram-monitor.ram-monitor.service -f
```

### Debug Mode
```bash
# Run with verbose output
RAM_THRESHOLD=50 snap run ram-monitor.ram-monitor 2>&1 | head -20

# Check system RAM manually
free -h && cat /proc/meminfo | grep -E "(MemTotal|MemAvailable)"
```

### Environment-Specific Issues

#### Wayland vs X11
- **Wayland**: May need additional permissions
- **X11**: Usually works out of the box
- **Check**: `echo $XDG_SESSION_TYPE`

#### Different Desktop Environments
- **GNOME/KDE**: Full notification support
- **XFCE/LXDE**: Basic notification support
- **Console-only**: No notifications (expected)

### Reset to Defaults
```bash
# Stop and reset configuration
sudo snap stop ram-monitor
sudo snap unset ram-monitor ram-threshold
sudo snap start ram-monitor

# Complete reinstall
sudo snap remove ram-monitor
sudo snap install ram-monitor
```

### Support Information
When reporting issues, please include:
- `snap version`
- `snap list ram-monitor`
- `pgrep -fa ram-monitor.sh`
- `snap connections ram-monitor`
- Your desktop environment (GNOME, KDE, etc.)
- Linux distribution and version

## 🛠️ Development

### Project Structure
```
ram-monitor-snap/
├── ram-monitor.sh          # Main monitoring script
├── snap/
│   └── snapcraft.yaml      # Snap packaging configuration
├── README.md               # This documentation
├── LICENSE                 # MIT license
└── *.snap                  # Built snap packages
```

### Local Development Setup
```bash
# Clone and setup
git clone https://github.com/djordjep/ram-monitor-snap.git
cd ram-monitor-snap

# Make script executable
chmod +x ram-monitor.sh

# Test script locally
./ram-monitor.sh --help
RAM_THRESHOLD=50 timeout 30 ./ram-monitor.sh
```

### Building Methods

#### Remote Build (Recommended for Production)
```bash
# Clean build environment
snapcraft clean

# Build on Launchpad (takes 15-45 minutes)
snapcraft remote-build --launchpad-accept-public-upload

# Download and install result
sudo snap install ram-monitor_*.snap --dangerous
```

#### Local Build (Development Only)
```bash
# Fast iterative development (GLIBC issues on some systems)
snapcraft pack --destructive-mode
sudo snap install ram-monitor_*.snap --dangerous
```

### Testing Suite
```bash
# Unit test: Help functionality
snap run ram-monitor.ram-monitor --help | grep -q "USAGE"

# Integration test: Custom threshold
RAM_THRESHOLD=50 timeout 10 snap run ram-monitor.ram-monitor 2>&1 | grep -q "50%"

# Process test: Monitor is running
pgrep -fa ram-monitor.sh | grep -q "ram-monitor.sh"

# Configuration test
sudo snap set ram-monitor ram-threshold=75
snap get ram-monitor ram-threshold | grep -q "75"
```

### Code Quality
```bash
# Lint shell script
shellcheck ram-monitor.sh

# Validate snapcraft.yaml
snapcraft validate-desktop snap/snapcraft.yaml

# Check for security issues
grep -r "sudo\|eval\|source.*http" .
```

### Release Process
1. **Update version** in `deb-package/DEBIAN/control`
2. **Build .deb**: `dpkg-deb --build deb-package ram-monitor_*.deb`
3. **Test installation**: `sudo dpkg -i ram-monitor_*.deb`
4. **Create GitHub release** with .deb asset
5. **Update README** with new version links

### Snap Releases (Limited)
For snap maintenance only:
1. **Update version** in `snap/snapcraft.yaml`
2. **Build**: `snapcraft pack --destructive-mode`
3. **Upload**: `snapcraft upload ram-monitor_*.snap --release=stable`

### Development Dependencies
- **snapcraft** ≥ 7.0
- **snapd** ≥ 2.36
- **shellcheck** (optional, for linting)
- **Launchpad account** (for remote builds)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2026 Djordje Puzic

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## 🙏 Acknowledgments

- **Canonical** for the Snap packaging system
- **Ubuntu Community** for Launchpad build infrastructure
- **libnotify** project for desktop notification support
- **Linux Community** for the robust `/proc` filesystem

## 🔗 Links & Resources

- **Homepage**: https://github.com/djordjep/ram-monitor-snap
- **Snap Store**: https://snapcraft.io/ram-monitor
- **Issues**: https://github.com/djordjep/ram-monitor-snap/issues
- **Discussions**: https://github.com/djordjep/ram-monitor-snap/discussions
- **Snap Documentation**: https://snapcraft.io/docs
- **Snapcraft Forum**: https://forum.snapcraft.io

---

**Made with ❤️ by Djordje Puzic**

*Monitor your RAM, free your mind!* 🧠✨

## 🤝 Contributing

We welcome contributions! Please follow these guidelines:

### Development Workflow
1. **Fork** the repository on GitHub
2. **Clone** your fork: `git clone https://github.com/yourusername/ram-monitor-snap.git`
3. **Create** a feature branch: `git checkout -b feature/amazing-feature`
4. **Make** your changes with tests
5. **Test** thoroughly (see Development section)
6. **Commit** with clear messages: `git commit -m "Add: amazing feature description"`
7. **Push** to your fork: `git push origin feature/amazing-feature`
8. **Create** a Pull Request on GitHub

### Code Standards
- **Shell**: Follow [Google Shell Style Guide](https://google.github.io/styleguide/shell.xml)
- **Commits**: Use conventional format: `type: description`
- **Documentation**: Update README for any user-facing changes
- **Testing**: Test on multiple desktop environments

### Types of Contributions
- 🐛 **Bug fixes**: Fix issues and add regression tests
- ✨ **Features**: New functionality with documentation
- 📚 **Documentation**: Improve docs, examples, tutorials
- 🧪 **Testing**: Add tests, improve test coverage
- 🎨 **UI/UX**: Improve user experience and notifications
- 🔧 **Tooling**: Build scripts, development tools

### Testing Checklist
- [ ] Local build works: `snapcraft pack --destructive-mode`
- [ ] Remote build works: `snapcraft remote-build`
- [ ] Help command works: `snap run ram-monitor.ram-monitor --help`
- [ ] Custom threshold works: `RAM_THRESHOLD=50 snap run ram-monitor.ram-monitor`
- [ ] Daemon starts automatically after install
- [ ] Notifications appear on threshold breach
- [ ] Environment variable works: `RAM_THRESHOLD=50 snap run ram-monitor.ram-monitor`
- [ ] Works on different desktop environments

### Issue Reporting
When reporting bugs, please include:
- **Steps to reproduce**
- **Expected vs actual behavior**
- **System information**: `snap version`, desktop environment
- **Logs**: `snap logs ram-monitor -n 20`

## 📞 Support

### Community Support
- **GitHub Issues**: https://github.com/djordjep/ram-monitor-snap/issues
- **GitHub Discussions**: https://github.com/djordjep/ram-monitor-snap/discussions
- **Snap Store**: https://snapcraft.io/ram-monitor

### Documentation
- **README**: This comprehensive guide
- **Snap Documentation**: https://snapcraft.io/docs
- **Snapcraft Forum**: https://forum.snapcraft.io

### Professional Support
For enterprise support or custom development:
- Email: djordjepuzic@gmail.com

## 👤 Author & Maintainers

**Djordje Puzic** - *Creator & Lead Developer*
- Email: djordjepuzic@gmail.com
- GitHub: [@djordjep](https://github.com/djordjep)
- Snap Store: [djordjep](https://snapcraft.io/publisher/djordjep)

## 📊 Project Status

- **Version**: 0.2.0
- **Status**: Production Ready (.deb) / Limited (snap)
- **License**: MIT (permissive, open source)
- **Primary Distribution**: [.deb packages](https://github.com/djordjep/ram-monitor-snap/releases)
- **Alternative**: [Snap Store](https://snapcraft.io/ram-monitor) (manual start required)

## 🗺️ Roadmap

### Version 0.2.0 (Planned)
- [ ] Configurable check intervals
- [ ] Multiple notification levels
- [ ] System load monitoring
- [ ] Historical data logging
- [ ] Web dashboard interface

### Version 0.3.0 (Future)
- [ ] Email/SMS notifications
- [ ] Integration with monitoring systems
- [ ] Custom notification sounds
- [ ] Mobile app companion