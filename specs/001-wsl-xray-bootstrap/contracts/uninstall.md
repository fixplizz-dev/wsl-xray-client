# Uninstall Script Contract

**Path**: `scripts/uninstall.sh`
**Purpose**: Complete removal of Xray client and all related components

## Interface

```bash
./scripts/uninstall.sh [--force] [--help]
```

### Arguments

- `--force`: Force removal without interactive confirmations
- `--help`: Help

### Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Successful removal |
| 15 | Incomplete removal (some components not removed) |

### Removed Components

1. Systemd service: `/etc/systemd/system/xray-wsl.service`
2. Xray binary: `/usr/local/bin/xray`
3. Configuration files: `configs/xray.json`
4. Service disable + daemon-reload

### Preserved Components

- `.env` file (contains user data)
- Systemd logs (automatic rotation)
- Project scripts

### Behavior

1. Stops service if running
2. Disables autostart
3. Removes systemd unit
4. Removes Xray binary
5. Cleans configuration files
6. Reloads systemd daemon
7. Outputs report of removed components

### Safety Features

- Interactive confirmation before removal (except --force)
- Success check for each removal step
- Detailed report of what was/wasn't removed