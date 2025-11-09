# Quickstart: WSL Xray Client Bootstrap

Date: 2025-11-08 | Branch: 001-wsl-xray-bootstrap

## Prerequisites

- Windows 11 with WSL2
- Ubuntu 22.04 or 24.04 LTS in WSL2
- Systemd enabled in WSL (see [WSL systemd guide](https://learn.microsoft.com/windows/wsl/systemd))
- Xray server connection parameters

### Check systemd in WSL

```bash
# Check systemd status
systemctl --version

# If systemd is not active, add to /etc/wsl.conf:
sudo tee /etc/wsl.conf << EOF
[boot]
systemd=true
EOF

# Restart WSL from Windows PowerShell:
# wsl --shutdown && wsl
```

## Installation

### 1. Clone and Setup

```bash
git clone <repository-url>
cd xray_wsl
cp .env.example .env
chmod 600 .env
```

### 2. Configuration

Edit `.env` file:

```bash
# Basic parameters (required)
XRAY_PROTOCOL=vless                    # vless, vmess or trojan
XRAY_SERVER_HOST=example.com           # Server IP or domain
XRAY_SERVER_PORT=443                   # Server port
XRAY_UUID_OR_PASS=550e8400-e29b...     # UUID for vless/vmess, password for trojan

# Local ports (required)
XRAY_LOCAL_SOCKS_PORT=1080             # Local SOCKS port
XRAY_LOCAL_HTTP_PORT=1081              # Local HTTP port (optional)

# Security (when needed)
XRAY_SECURITY=reality                  # tls, xtls, reality
XRAY_SNI=example.com                   # For TLS/Reality

# Reality parameters (if XRAY_SECURITY=reality)
XRAY_PUBLIC_KEY=abcd1234...            # Public key
XRAY_SHORT_ID=0123456789abcdef         # Hex string up to 16 characters
XRAY_FINGERPRINT=chrome                # chrome, firefox, safari, ios, android

# Additional settings
XRAY_AUTOSTART=off                     # on for autostart
XRAY_CLIENT_LANG=en                    # en or ru
```

### 3. Installation

```bash
./scripts/install.sh
```

### 4. Verification

```bash
# Service status
./scripts/manage.sh status

# Check external IP
./scripts/manage.sh check-ip
```

## Management Commands

### Basic Commands

```bash
# Service management
./scripts/manage.sh start              # Start
./scripts/manage.sh stop               # Stop
./scripts/manage.sh restart            # Restart
./scripts/manage.sh status             # Status and information

# Diagnostics
./scripts/manage.sh logs               # Recent logs
./scripts/manage.sh logs --lines 50    # Last 50 lines
./scripts/manage.sh logs --follow      # Monitor logs
./scripts/manage.sh check-ip           # Check external IP
./scripts/manage.sh version            # Client and Xray versions

# Autostart
./scripts/manage.sh autostart-enable   # Enable autostart
./scripts/manage.sh autostart-disable  # Disable autostart
```

### Using Proxy

After successful startup, configure applications to use proxy:

- **SOCKS5**: `127.0.0.1:1080` (port from XRAY_LOCAL_SOCKS_PORT)
- **HTTP**: `127.0.0.1:1081` (port from XRAY_LOCAL_HTTP_PORT, if configured)

## Uninstall

```bash
./scripts/uninstall.sh
```

This will remove systemd service, Xray binary and configuration files, but preserve `.env` file.

## Troubleshooting

### Systemd Issues

```bash
# Check systemd status in WSL
systemctl --version
systemctl list-units --type=service --state=running

# Check specific service
sudo systemctl status xray-wsl
sudo journalctl -u xray-wsl -f
```

### Network Issues

```bash
# Check ports
netstat -tlnp | grep :1080
ss -tlnp | grep :1080

# Check server connection
curl -x socks5://127.0.0.1:1080 https://ifconfig.co
curl -x http://127.0.0.1:1081 https://ifconfig.co
```

### Configuration Issues

```bash
# Configuration validation
./scripts/generate-config.sh --validate-only

# View generated config
cat configs/xray.json | jq '.'

# Test Xray configuration
/usr/local/bin/xray -c configs/xray.json -test
```

### Logs and Diagnostics

```bash
# System logs
sudo journalctl -u xray-wsl --since "1 hour ago"

# Installation logs
./scripts/manage.sh logs --level ERROR

# Check files
ls -la configs/
ls -la /usr/local/bin/xray
sudo systemctl cat xray-wsl
```

## Examples

### VLESS + Reality Configuration Example

```env
XRAY_PROTOCOL=vless
XRAY_SERVER_HOST=example.com
XRAY_SERVER_PORT=443
XRAY_UUID_OR_PASS=550e8400-e29b-41d4-a716-446655440000
XRAY_SECURITY=reality
XRAY_SNI=www.microsoft.com
XRAY_PUBLIC_KEY=Z84J2IelR9ch3k8VtlVhhs5ycBUlXZrtZu01YGd6T3Y
XRAY_SHORT_ID=abcdef0123456789
XRAY_FINGERPRINT=chrome
XRAY_LOCAL_SOCKS_PORT=1080
XRAY_AUTOSTART=on
```

### VMess + TLS Configuration Example

```env
XRAY_PROTOCOL=vmess
XRAY_SERVER_HOST=example.com
XRAY_SERVER_PORT=443
XRAY_UUID_OR_PASS=550e8400-e29b-41d4-a716-446655440000
XRAY_SECURITY=tls
XRAY_SNI=example.com
XRAY_LOCAL_SOCKS_PORT=1080
XRAY_LOCAL_HTTP_PORT=1081
```
