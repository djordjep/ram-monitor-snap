# RAM Monitor

A simple Linux RAM usage monitor that runs as a background daemon and sends desktop notifications when memory usage exceeds a specified threshold.

## Features

- Monitors RAM usage continuously
- Sends desktop notifications when threshold is exceeded
- Configurable monitoring interval and threshold
- Runs as a systemd service (via snap)
- Lightweight and efficient

## Installation

### From Snap Store (Recommended)

```bash
sudo snap install ram-monitor
```

### Manual Installation (Development)

```bash
git clone https://github.com/djordjepuzic/ram-monitor.git
cd ram-monitor
snapcraft pack --destructive-mode
sudo snap install ram-monitor_*.snap --dangerous
```

## Usage

The snap runs automatically as a daemon after installation. It monitors RAM usage every 60 seconds with a default threshold of 80%.

You can also run it manually with custom options:

### Custom Threshold

To run with a custom threshold:

```bash
snap run ram-monitor.ram-monitor <percentage>
```

For example, to monitor with a 50% threshold:
```bash
snap run ram-monitor.ram-monitor 50
```

### Help

To see usage information:

```bash
snap run ram-monitor.ram-monitor --help
```

## Configuration

- **Default threshold**: 80% RAM usage
- **Check interval**: 60 seconds
- **Cooldown period**: 5 minutes after notification

## Requirements

- Linux system with snap support
- Desktop environment with notification support
- libnotify (automatically included in snap)

## Development

### Building

**Important:** Due to GLIBC compatibility issues with destructive builds, it is recommended to use remote building for production releases:

```bash
snapcraft remote-build --launchpad-accept-public-upload
```

For local development testing only:

```bash
snapcraft pack --destructive-mode
```

### Testing

```bash
# Install locally
sudo snap install ram-monitor_*.snap --dangerous

# Test with custom threshold
timeout 30 snap run ram-monitor.ram-monitor 50

# Show help
snap run ram-monitor.ram-monitor --help
```

## License

MIT License - see LICENSE file for details.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## Support

For issues and questions:
- GitHub Issues: https://github.com/djordjepuzic/ram-monitor/issues
- Snap Store: https://snapcraft.io/ram-monitor

## Author

Djordje Puzic - djordjepuzic@gmail.com