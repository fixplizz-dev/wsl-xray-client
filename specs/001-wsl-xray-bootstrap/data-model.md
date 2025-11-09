# Data Model: WSL Xray Client Bootstrap

Date: 2025-11-08 | Branch: 001-wsl-xray-bootstrap

## Overview

Data model is based on environment variables (.env) and generated Xray JSON configurations. All dynamic parameters are set by user through .env; system transforms them into corresponding Xray inbound/outbound structures.

## Environment Variables

| Name | Required | Type | Validation | Notes |
|------|----------|------|------------|-------|
| XRAY_PROTOCOL | yes | enum | vless or vmess or trojan | Defines outbound protocol |
| XRAY_SERVER_HOST | yes | string | non-empty, hostname/IP | Server address |
| XRAY_SERVER_PORT | yes | int | 1..65535 | Server port |
| XRAY_UUID_OR_PASS | yes | string | uuid for vless/vmess OR non-empty for trojan | Authentication |
| XRAY_SECURITY | conditional | enum | tls or xtls or reality | Depends on selected protocol/security |
| XRAY_SNI | tls/reality | string | hostname | SNI/ServerName |
| XRAY_PUBLIC_KEY | reality | base64/hex | non-empty | PublicKey for Reality |
| XRAY_SHORT_ID | reality | hex up to 16 | regex `^[0-9a-fA-F]{1,16}$` | ShortId |
| XRAY_FINGERPRINT | reality | enum | chrome or firefox or safari or ios or android | Client fingerprint |
| XRAY_LOCAL_SOCKS_PORT | yes | int | 1..65535 | Local SOCKS port |
| XRAY_LOCAL_HTTP_PORT | optional | int | 1..65535 | Local HTTP port if needed |
| XRAY_AUTOSTART | optional | enum | on or off | Default off |
| XRAY_CLIENT_LANG | optional | enum | en or ru | Message language (English primary, Russian fallback via =ru) |

## Derived Values

| Name | Source | Description |
|------|--------|-------------|
| XRAY_JSON_PATH | constant | Path to generated config (e.g. `configs/xray.json`) |
| XRAY_BIN_PATH | constant | `/usr/local/bin/xray` |
| XRAY_SERVICE_NAME | constant | `xray-wsl` |
| XRAY_SERVICE_FILE | constant | `/etc/systemd/system/xray-wsl.service` |

## JSON Configuration Structure (Simplified)

```json
{
  "inbounds": [
    {
      "port": ${XRAY_LOCAL_SOCKS_PORT},
      "listen": "127.0.0.1",
      "protocol": "socks",
      "settings": {"udp": true}
    }
  ],
  "outbounds": [
    {
      "protocol": "${XRAY_PROTOCOL}",
      "settings": {
        "vnext": [
          {
            "address": "${XRAY_SERVER_HOST}",
            "port": ${XRAY_SERVER_PORT},
            "users": [
              {
                "id": "${XRAY_UUID_OR_PASS}",
                "security": "auto"
              }
            ]
          }
        ]
      },
      "streamSettings": {
        "network": "tcp",
        "security": "${XRAY_SECURITY}",
        "realitySettings": {
          "fingerprint": "${XRAY_FINGERPRINT}",
          "publicKey": "${XRAY_PUBLIC_KEY}",
          "shortId": "${XRAY_SHORT_ID}",
          "serverName": "${XRAY_SNI}"
        }
      }
    }
  ]
}
```

## Validation Rules

1. If `XRAY_SECURITY=reality`, required: `XRAY_PUBLIC_KEY`, `XRAY_SHORT_ID`, `XRAY_FINGERPRINT`, `XRAY_SNI`.
2. `XRAY_UUID_OR_PASS`: UUID format for vless/vmess (`xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`) or simple string for trojan.
3. Ports must not conflict: SOCKS vs HTTP (if HTTP specified) — different values.
4. Empty required variables → immediate exit with code 10.
5. Invalid value format → exit code 11.

## Error Conditions Mapping

| Condition | Code | Action |
|-----------|------|--------|
| Missing required variable | 10 | Message + abort |
| Invalid format | 11 | Message + abort |
| Port conflict | 11 | Message + abort |

## Data Integrity

- JSON generation only through jq template with key presence verification.
- Config overwritten atomically: temporary file first, then mv.

