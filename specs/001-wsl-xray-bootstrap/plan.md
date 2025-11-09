# Implementation Plan: WSL Xray Client Bootstrap

**Branch**: `001-wsl-xray-bootstrap` | **Date**: 2025-11-08 | **Spec**: ./spec.md
**Input**: Feature specification from `specs/001-wsl-xray-bootstrap/spec.md`

## Summary

Minimal Bash-oriented client for rapid Xray VPN deployment in WSL2 Ubuntu (22.04/24.04): clone → copy `.env.example` → fill required variables → run installation script that creates idempotent systemd unit, IP verification and management commands (start/stop/restart/status/logs/check-ip/version/autostart-enable|disable/uninstall). Supports VLESS/VMess/Trojan protocols with TLS/XTLS/Reality through correct JSON configuration generation based on environment variables.

## Technical Context

**Language/Version**: bash 5.x (WSL2 Ubuntu 22.04/24.04)
**Primary Dependencies**: Xray binary (download with sha256 verification), coreutils, systemd (already included), curl, jq (for safe JSON generation/validation), ip route (for network state checking)
**Storage**: Files in working directory + `/etc/systemd/system/xray-wsl.service` + temporary download directory
**Testing**: bats (unit + integration tests for config generation and commands), shellcheck + shfmt (static analysis/style)
**Target Platform**: WSL2 Ubuntu 22.04/24.04 with systemd enabled
**Project Type**: Collection of Bash scripts (scripts/, lib/) + `.env` config
**Performance Goals**: Installation < 120 seconds with normal network; management commands < 1 second
**Constraints**: Idempotent repeated installation; no secret leaks in logs; minimal external dependencies; no persistent root artifacts except systemd unit and binary
**Scale/Scope**: One client per WSL instance; no orchestration for multiple configurations in first version

## Constitution Check

All constitution points are followed:

1. Scripts will be split: `scripts/install.sh`, `scripts/manage.sh`, `scripts/generate-config.sh`, `scripts/check-ip.sh`, `scripts/version.sh`, `scripts/uninstall.sh`; common functions in `lib/common.sh`.
2. CLI `--help` implemented through argument parsing; strict validation of required variables.
3. Tests: create failing bats tests for each command before implementation.
4. Idempotency: install checks existence of binary, service file and config; safely updates when needed.
5. Secrets: `.env` (chmod 600); `.env.example` without real values.
6. Logging: through `log_info/log_error/log_warn` functions with TIMESTAMP and level.
7. Versioning: `.version` file + `scripts/version.sh`.
8. Traceability: decisions recorded in this `plan.md`; alternatives noted in Decision Log.
9. Security: Xray binary download with sha256 verification; reject without verification.
10. Portability: only POSIX/Bash 5.x constructs; no Windows-specific paths.

## Project Structure (feature scope)

```bash
scripts/
  install.sh               # установка / обновление
  generate-config.sh       # генерация xray.json из .env
  manage.sh                # start|stop|restart|status|logs|check-ip|version|autostart-enable|autostart-disable
  check-ip.sh              # отдельная проверка внешнего IP
  uninstall.sh             # полное удаление
  version.sh               # вывод версии
lib/
  common.sh                # логирование, загрузка .env, валидация
  validate.sh              # функции проверки переменных/портов/uuid
configs/
  xray.template.json       # шаблон с маркерами для протокола
.env.example               # пример конфигурации
.version                   # версия проекта
systemd/
  xray-wsl.service.template # шаблон юнита для параметризации
```

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|--------------------------------------|
| Using jq | Safe JSON generation instead of manual sed | Manual substitution increases risk of errors/injections |

## Phase 0: Research

### Goals

- Define minimal set of environment variables for all supported protocols.
- Create JSON template for Xray VLESS/VMess/Trojan with TLS/XTLS/Reality parameters.
- Verify reliable Xray download source (release URL + checksum file).

### Questions & Findings

1. **Xray Source**: GitHub Releases <https://github.com/XTLS/Xray-core/releases/latest> - download `Xray-linux-64.zip` + SHA256 verification from `SHA256SUMS`. Version determined by API <https://api.github.com/repos/XTLS/Xray-core/releases/latest>.
2. **Reality Parameters**: require `publicKey`, `shortId` (hex, 1-16 characters), `fingerprint` (chrome/firefox/safari/ios/android), `serverName` (SNI). Mandatory validation when Reality is selected.
3. **Dependencies**:
   - `jq` (for JSON generation): `apt install jq -y`
   - `curl` (for downloads and IP checking): pre-installed in Ubuntu
   - `systemctl` (for service management): available in WSL2 with systemd
   - `unzip` (for archive extraction): `apt install unzip -y`
4. **WSL systemd**: activation via `/etc/wsl.conf` → `[boot] systemd=true` and WSL restart
5. **Localization**: variable `XRAY_CLIENT_LANG` (en|ru, default=en) or fallback via `LANG=ru`

### Artifacts

- Variable list: `XRAY_PROTOCOL`, `XRAY_SERVER_HOST`, `XRAY_SERVER_PORT`, `XRAY_UUID_OR_PASS`, `XRAY_SECURITY`, `XRAY_SNI`, `XRAY_PUBLIC_KEY`, `XRAY_SHORT_ID`, `XRAY_FINGERPRINT`, `XRAY_LOCAL_SOCKS_PORT`, `XRAY_LOCAL_HTTP_PORT`, `XRAY_AUTOSTART`, `XRAY_CLIENT_LANG`.
- Bash version: 5.0+ (Ubuntu 22.04/24.04), strict mode (`set -euo pipefail`)
- Xray JSON template: base template in `configs/xray.template.json` with `{{VAR_NAME}}` variables

## Phase 1: Data Model & Contracts

### Data Model (environment-driven)

| Variable | Required | Description |
|----------|----------|-------------|
| XRAY_PROTOCOL | yes | vless or vmess or trojan | Defines outbound protocol |
| XRAY_SERVER_HOST | yes | Server domain or IP |
| XRAY_SERVER_PORT | yes | Server port |
| XRAY_UUID_OR_PASS | yes | UUID for VLESS/VMess or password for Trojan |
| XRAY_SECURITY | conditional | tls or xtls or reality if required |
| XRAY_SNI | for tls/reality | SNI/ServerName |
| XRAY_PUBLIC_KEY | for reality | Reality public key |
| XRAY_SHORT_ID | for reality | ShortId hex format |
| XRAY_FINGERPRINT | for reality | Fingerprint e.g. chrome |
| XRAY_LOCAL_SOCKS_PORT | yes | Local SOCKS proxy port |
| XRAY_LOCAL_HTTP_PORT | optional | Local HTTP proxy port |
| XRAY_AUTOSTART | optional | on or off default off |

### Contracts (CLI)

- `scripts/install.sh`: no arguments — performs installation; `--force` regeneration.
- `scripts/manage.sh <action>`: actions: start or stop or restart or status or logs or check-ip or version or autostart-enable or autostart-disable.
- `scripts/generate-config.sh`: generates `xray.json` validating variables.
- `scripts/uninstall.sh`: removes unit, binary, config.
- All scripts: `--help` support.

Detailed contracts see in `contracts/`

### Error Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 10 | Missing required variable |
| 11 | Invalid value format |
| 12 | Download failure |
| 13 | Checksum mismatch |
| 14 | Service operation failed |
| 15 | Uninstall incomplete |

### Logging Format

`TIMESTAMP LEVEL script FUNCTION message`

## Phase 1: Quickstart

1. `git clone <repo>`
2. `cp .env.example .env && chmod 600 .env`
3. Fill variables (minimum protocol, host, port, uuid/pass, local ports).
4. `./scripts/install.sh`
5. `./scripts/manage.sh check-ip` for verification.
6. (Optional) `./scripts/manage.sh autostart-enable`.
7. Logs: `./scripts/manage.sh logs`.
8. Removal: `./scripts/uninstall.sh`.

## Decision Log

| Decision | Rationale | Alternatives |
|----------|-----------|-------------|
| Use jq | Reliable JSON generation | sed/printf manually |
| Split manage/install | SRP, testability | One monolithic script |
| SHA256 verification | Binary integrity | No verification (risk) |

## Phase 2: Tasks (Draft Outline)

1. Create `lib/common.sh` (logging, .env loading, exit helpers).
2. Create bats tests for common.sh (log format, missing .env → error).
3. Implement `scripts/generate-config.sh` + tests (empty variable → code 10).
4. Implement `scripts/install.sh` (download, sha256 check, systemd unit generation, enable if XRAY_AUTOSTART=on).
5. Implement `scripts/manage.sh` (actions start/stop/restart/status/logs/check-ip/version/autostart-enable|disable).
6. Implement `scripts/check-ip.sh` (curl <https://ipinfo.io/ip>) + comparison.
7. Implement `scripts/uninstall.sh` (remove unit, binary, config, check remainder).
8. Add `scripts/version.sh` (reads `.version`).
9. Add shellcheck + shfmt config, CI (separately later).
10. Complete README (Quickstart + Troubleshooting).

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|-----------|
| Missing systemd | Autostart impossible | Check and explicit message about limitation |
| Invalid Reality parameters | Failed connection | Preliminary format/presence validation |
| Service crash | Tunnel loss | Logs + status for quick diagnosis |
| Missing jq | Generation error | Dependency check in install + instruction |

## Next Steps

After plan approval, create `tasks.md` with breakdown by executors/order and proceed to implementation.
