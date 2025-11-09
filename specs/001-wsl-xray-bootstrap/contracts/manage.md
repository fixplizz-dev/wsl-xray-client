# Management Script Contract

**Path**: `scripts/manage.sh`
**Purpose**: Xray service lifecycle management

## Interface

```bash
./scripts/manage.sh <action> [options]
```

### Actions

| Action | Description | Options |
|--------|-------------|---------|
| `start` | Start service | - |
| `stop` | Stop service | - |
| `restart` | Restart service | - |
| `status` | Service status (state, start time, IP, errors) | - |
| `logs` | Show logs | `--lines N`, `--follow`, `--level LEVEL` |
| `check-ip` | Check external IP | - |
| `version` | Client and Xray version | - |
| `autostart-enable` | Enable autostart | - |
| `autostart-disable` | Disable autostart | - |

### Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Successful execution |
| 14 | Service operation error |
| 20 | Unknown command |

### Output Examples

#### Status Command

```bash
$ ./scripts/manage.sh status
Status: active (running)
Started: 2025-11-08 12:34:56
External IP: 203.0.113.42 (via VPN)
Errors: none
```

#### Logs Command

```bash
$ ./scripts/manage.sh logs --lines 10 --level ERROR
2025-11-08 12:35:01 ERROR xray connection failed to server:443
```

### Localization

Support for English (default) and Russian language via `XRAY_CLIENT_LANG=ru` or `LANG=ru`.