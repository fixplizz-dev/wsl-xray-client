# Install Script Contract

**Path**: `scripts/install.sh`
**Purpose**: Idempotent installation/update of Xray client

## Interface

```bash
./scripts/install.sh [--force] [--help]
```

### Arguments

- `--force`: Force reinstallation (reload binary, regenerate config)
- `--help`: Display help

### Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Successful installation/update |
| 10 | Missing required variable in .env |
| 11 | Invalid variable format |
| 12 | Xray download error |
| 13 | SHA256 checksum mismatch |

### Prerequisites

- WSL2 Ubuntu 22.04/24.04 with systemd
- `.env` file with correct variables
- Internet access for Xray download
- Sudo rights for installation to `/usr/local/bin/` and systemd unit creation

### Behavior

1. Checks presence and validity of `.env`
2. Installs dependencies (`jq`, `unzip`) if missing
3. Downloads latest Xray version with SHA256 verification
4. Generates JSON configuration from environment variables
5. Creates systemd unit `xray-wsl.service`
6. If `XRAY_AUTOSTART=on` → enables autostart
7. Starts service

### Output

- Operation progress with timestamps
- Warnings when overwriting files
- Service status after installation