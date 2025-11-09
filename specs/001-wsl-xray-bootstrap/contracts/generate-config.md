# Configuration Generator Contract

**Path**: `scripts/generate-config.sh`
**Purpose**: Generate Xray JSON configuration from environment variables

## Interface

```bash
./scripts/generate-config.sh [--output PATH] [--validate-only] [--help]
```

### Arguments

- `--output PATH`: Path to configuration file (default: `configs/xray.json`)
- `--validate-only`: Only validate .env without file generation
- `--help`: Help

### Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Successful generation |
| 10 | Missing required variable |
| 11 | Invalid variable format |

### Validation Rules

| Variable | Validation |
|----------|------------|
| `XRAY_PROTOCOL` | enum: vless, vmess, trojan |
| `XRAY_SERVER_HOST` | non-empty, hostname/IP format |
| `XRAY_SERVER_PORT` | integer 1-65535 |
| `XRAY_UUID_OR_PASS` | UUID format for vless/vmess OR non-empty for trojan |
| `XRAY_LOCAL_SOCKS_PORT` | integer 1-65535, not equal to HTTP port |
| `XRAY_SECURITY` | enum: tls, xtls, reality (if specified) |

### Reality Protocol Requirements

When `XRAY_SECURITY=reality` required:

- `XRAY_PUBLIC_KEY`: base64/hex key
- `XRAY_SHORT_ID`: hex string 1-16 characters
- `XRAY_FINGERPRINT`: enum: chrome, firefox, safari, ios, android
- `XRAY_SNI`: hostname for ServerName

### Output

JSON file compatible with Xray-core with correct inbounds/outbounds structure.