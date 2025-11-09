# Research: WSL Xray Client Bootstrap

Date: 2025-11-08 | Branch: 001-wsl-xray-bootstrap | Spec: ./spec.md

## Objectives

- Define minimal environment variables for VLESS/VMess/Trojan with TLS/XTLS/Reality.
- Determine secure Xray installation process (source, checksum, installation paths).
- Design systemd unit template for autostart in WSL2.
- Research bash-specific validation and error handling capabilities.

## Findings

### Xray Binary Distribution

- **Source**: GitHub Releases API <https://api.github.com/repos/XTLS/Xray-core/releases/latest>
- **Archive**: `Xray-linux-64.zip` (approximately 12MB)
- **Checksum**: `SHA256SUMS` file in same release
- **Installation Path**: `/usr/local/bin/xray` (requires sudo)
- **Config**: `$PROJECT_ROOT/configs/xray.json` (generated)

### Protocol Configuration Mapping

**VLESS**:

- UUID required (36 characters)
- Flow parameter for XTLS: `xtls-rprx-vision`
- Security: `tls`, `xtls`, `reality`

**VMess**:

- UUID required, alterId=0 (modern standard)
- Security: auto, aes-128-gcm
- Only `tls` support (no XTLS/Reality)

**Trojan**:

- Password instead of UUID
- Only TLS security (no XTLS/Reality support)

**Reality Protocol** (modern DPI bypass):

- `publicKey`: ed25519 public key (base64)
- `shortId`: hex string 0-16 characters
- `fingerprint`: chrome, firefox, safari, ios, android, edge, 360, qq
- `serverName`: SNI domain
- `spiderX`: server path (optional)

### WSL2 Systemd Integration

**Activation**:

```bash
# /etc/wsl.conf
[boot]
systemd=true
```

**Service Template**:

```ini
[Unit]
Description=Xray VPN Client for WSL
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=/usr/local/bin/xray -c /path/to/config/xray.json
Restart=always
RestartSec=5
User=nobody
Group=nogroup

[Install]
WantedBy=multi-user.target
```

### Bash Validation Patterns

**UUID Validation**:

```bash
validate_uuid() {
    [[ $1 =~ ^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$ ]]
}
```

**Port Validation**:

```bash
validate_port() {
    [[ $1 =~ ^[1-9][0-9]{0,4}$ ]] && [ "$1" -le 65535 ]
}
```

**JSON Generation with jq**:

```bash
jq -n --arg protocol "$XRAY_PROTOCOL" \
      --arg host "$XRAY_SERVER_HOST" \
      --argjson port "$XRAY_SERVER_PORT" \
      '{inbounds: [...]}'
```

### Dependency Management

**Required packages**:

```bash
apt update && apt install -y curl jq unzip
```

**Version detection**:

```bash
bash --version | head -1  # should be 5.0+
systemctl --version       # systemd check
```

## Resolved Questions

- **Default port**: Must be explicitly set in `.env` (otherwise error code 10)
- **Autostart**: Default OFF; enabled by `autostart-enable` command
- **Version support**: Ubuntu 22.04 and 24.04 LTS
- **Localization**: EN by default, RU fallback via `XRAY_CLIENT_LANG=ru`
- **Logs**: secret filtering through regex patterns
- **Idempotency**: file existence check before operations

## Security Considerations

- `.env` file must have `600` permissions (owner only)
- Logs must not contain UUIDs, passwords, keys
- Download only with SHA256 verification
- Config generated to temporary file, then atomic `mv`
- Service runs as `nobody` user

## References

- Xray docs: <https://xtls.github.io/> (architecture and config examples)
- WSL systemd: <https://learn.microsoft.com/windows/wsl/systemd>
- Reality protocol: <https://github.com/XTLS/REALITY>
- Bash manual: <https://www.gnu.org/software/bash/manual/bash.html>

