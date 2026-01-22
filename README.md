# RAM Monitor 🖥️

[![Snap Status](https://snapcraft.io/ram-monitor/badge.svg)](https://snapcraft.io/ram-monitor)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub issues](https://img.shields.io/github/issues/djordjep/ram-monitor-snap)](https://github.com/djordjep/ram-monitor-snap/issues)
[![GitHub stars](https://img.shields.io/github/stars/djordjep/ram-monitor-snap)](https://github.com/djordjep/ram-monitor-snap/stargazers)

A lightweight Linux RAM usage monitor that runs as a background daemon and sends desktop notifications when memory usage exceeds a specified threshold.

## ✨ Features

- **Continuous Monitoring**: Real-time RAM usage tracking every 60 seconds
- **Desktop Notifications**: Native system notifications when threshold exceeded
- **Flexible Configuration**: Environment variables, snap config, or command-line
- **Systemd Integration**: Automatic startup and restart via snap daemon
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

### From Snap Store (Recommended)

```bash
# Install from Snap Store
sudo snap install ram-monitor

# Verify installation
snap list ram-monitor
snap services ram-monitor
```

**What happens after install:**
- ✅ Daemon starts automatically
- ✅ Monitors with default 80% threshold
- ✅ Survives system reboots
- ✅ Auto-updates when new versions available

### Manual Installation (Development)

```bash
# Clone repository
git clone https://github.com/djordjep/ram-monitor-snap.git
cd ram-monitor-snap

# Build snap (use remote build for production)
snapcraft remote-build --launchpad-accept-public-upload

# Install locally
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
2. **Configure** (optional): `sudo snap set ram-monitor ram-threshold=75`
3. **Monitor**: Check system notifications when RAM usage is high
4. **Status**: `snap services ram-monitor` (should show "active")

### Example Notification
```
High RAM Usage Alert
Current usage: 85.3% (exceeds 80%)
```

## 🔧 Technical Details

### Architecture
- **Language**: Bash shell script
- **Packaging**: Snap (confined sandbox)
- **Service**: systemd daemon (simple type)
- **Monitoring**: `/proc/meminfo` via `free` command
- **Notifications**: libnotify via `notify-send`

### How RAM Calculation Works
```bash
# Get total and used memory from /proc/meminfo
total=$(free -m | awk '/Mem/ {print $2}')      # Total RAM in MB
used=$(free -m | awk '/Mem/ {print $3}')       # Used RAM in MB
percentage=$(awk "BEGIN {printf \"%.2f\", $used/$total * 100}")
```

### Daemon Configuration
```yaml
daemon: simple               # Basic systemd service
restart-condition: always    # Auto-restart on failure/crash
plugs: [desktop]            # Access to desktop notifications
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

### Daemon Operation
The RAM monitor runs automatically as a systemd service after installation:

```bash
# Check status
snap services ram-monitor

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

#### Method 1: Persistent (Recommended)
```bash
# Set threshold permanently
sudo snap set ram-monitor ram-threshold=75

# Check current setting
snap get ram-monitor ram-threshold

# Reset to default
sudo snap unset ram-monitor ram-threshold

# View all settings
snap get ram-monitor
```

#### Method 2: Environment Variables
```bash
# One-time override
RAM_THRESHOLD=70 snap run ram-monitor.ram-monitor

# Temporary testing
RAM_THRESHOLD=50 timeout 60 snap run ram-monitor.ram-monitor
```

#### Method 3: Command Line (Testing Only)
```bash
# Manual run with custom threshold (doesn't work with daemon)
RAM_THRESHOLD=60 snap run ram-monitor.ram-monitor
```

### Example Configurations

```bash
# Conservative (alert at 70%)
sudo snap set ram-monitor ram-threshold=70

# Aggressive (alert at 90%)
sudo snap set ram-monitor ram-threshold=90

# Development machine (alert at 50%)
sudo snap set ram-monitor ram-threshold=50
```

### Configuration Files
Snap configuration is stored in: `~/snap/ram-monitor/common/`
- Persistent across updates
- Survives system reboots
- User-specific settings

## 🔍 Troubleshooting

### Common Issues

#### No Notifications Appearing
```bash
# Check if daemon is running
snap services ram-monitor

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
# Check current configuration
snap get ram-monitor

# Restart daemon after config changes
sudo snap restart ram-monitor
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
- `snap services ram-monitor`
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

# Service test: Daemon status
snap services ram-monitor | grep -q "active"

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
1. **Update version** in `snap/snapcraft.yaml`
2. **Test locally** with destructive build
3. **Remote build** for production release
4. **Upload to Snap Store**: `snapcraft upload ram-monitor_*.snap`
5. **Release**: `snapcraft release ram-monitor <revision> stable`
6. **Tag GitHub release** with same version

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
- [ ] Configuration persists: `snap set/get ram-monitor ram-threshold`
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

- **Version**: 0.1.0
- **Status**: Stable & Production Ready
- **License**: MIT (permissive, open source)
- **Downloads**: Check [Snap Store](https://snapcraft.io/ram-monitor)

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