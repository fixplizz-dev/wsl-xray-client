# Feature Specification: WSL Xray Client Bootstrap

**Feature Branch**: `001-wsl-xray-bootstrap`
**Created**: 2025-11-08
**Status**: Draft
**Input**: User description: "WSL Xray Client — быстрый деплой Xray VPN клиента в WSL2: клон → заполнить .env → запуск; поддержка VLESS/VMess/Trojan с TLS/XTLS; автозапуск через systemd; быстрые команды (start/stop/restart/status/logs/check-ip/version); полное удаление."

## User Scenarios & Testing *(mandatory)*

<!--
  IMPORTANT: User stories should be PRIORITIZED as user journeys ordered by importance.
  Each user story/journey must be INDEPENDENTLY TESTABLE - meaning if you implement just ONE of them,
  you should still have a viable MVP (Minimum Viable Product) that delivers value.

  Assign priorities (P1, P2, P3, etc.) to each story, where P1 is the most critical.
  Think of each story as a standalone slice of functionality that can be:
  - Developed independently
  - Tested independently
  - Deployed independently
  - Demonstrated to users independently
-->

### User Story 1 - Быстрая установка и подключение (Priority: P1)

Пользователь хочет развернуть VPN клиент в WSL2 за несколько минут без тонкой настройки Windows: он клонирует проект, копирует шаблон конфигурации, вводит параметры сервера и запускает установку, после чего трафик из WSL идёт через VPN.

**Why this priority**: Это основной сценарий ценности — минимальный путь к работающему VPN в WSL.

**Independent Test**: Заполнить `.env` валидными параметрами и выполнить установку → подтвердить смену внешнего IP.

**Acceptance Scenarios**:

1. Given чистая WSL Ubuntu с включённым systemd и заполненный `.env`, When пользователь запускает установку, Then сервис запускается и устанавливается подключение к VPN.
2. Given активное подключение, When пользователь запускает проверку IP, Then отображается IP адрес со стороны VPN.

---

### User Story 2 - Управление и автозапуск (Priority: P1)

Пользователь управляет клиентом через удобные команды: запуск, остановка, перезапуск, статус; может включить/отключить автозапуск через systemd.

**Why this priority**: Контроль жизненного цикла и автозапуск — базовый операционный опыт.

**Independent Test**: Выполнить команды управления и проверить статус/поведение сервиса, а также переключение автозапуска.

**Acceptance Scenarios**:

1. Given установленный сервис, When пользователь запускает команду статуса, Then видит текущее состояние и последние события.
2. Given сервис выключен, When пользователь запускает команду запуска, Then сервис переходит в состояние «running».
3. Given автозапуск выключен, When пользователь включает автозапуск, Then при следующем старте WSL сервис запускается автоматически.

---

### User Story 3 - Конфигурация протоколов (Priority: P2)

Пользователь выбирает протокол (VLESS/VMess/Trojan) и тип защиты (TLS/XTLS/Reality), задаёт необходимые параметры и успешно подключается.

**Why this priority**: Поддержка распространённых протоколов — ключ к совместимости с большинством серверов.

**Independent Test**: Для каждого протокола заполнить соответствующие поля в конфигурации и подтвердить успешное подключение.

**Acceptance Scenarios**:

1. Given конфигурация VLESS, When выполнено подключение, Then туннель активен и трафик идёт через VPN.
2. Given конфигурация VMess/Trojan, When выполнено подключение, Then туннель активен и проверка IP подтверждает маршрут через VPN.

---

### User Story 4 - Диагностика и версия (Priority: P2)

Пользователь просматривает логи, фильтрует ошибки, узнаёт установленную версию клиента/конфигурации.

**Why this priority**: Быстрый анализ неполадок и прозрачность версии повышают поддерживаемость.

**Independent Test**: Вызвать команды логов/версии и убедиться в корректном и безопасном выводе.

**Acceptance Scenarios**:

1. Given работающий сервис, When пользователь запрашивает последние N строк логов, Then получает вывод без утечек секретов.
2. Given установленная сборка, When пользователь запрашивает версию, Then отображается версия проекта.

---

### User Story 5 - Полное удаление (Priority: P3)

Пользователь полностью удаляет клиент, конфигурацию и системные элементы, возвращаясь к исходному состоянию.

**Why this priority**: Чистая деинсталляция важна для безопасности и контроля.

**Independent Test**: Выполнить команду удаления и проверить отсутствие сервисов/файлов.

**Acceptance Scenarios**:

1. Given установленный клиент, When запускается сценарий удаления, Then удаляются конфигурации и системные артефакты без остатка.
2. Given удалённый клиент, When вызывается статус, Then сообщается об отсутствии установленного сервиса.

[Add more user stories as needed, each with an assigned priority]

### Edge Cases

<!--
  ACTION REQUIRED: The content in this section represents placeholders.
  Fill them out with the right edge cases.
-->

- Отсутствуют обязательные параметры в конфигурации
- Неверный UUID/ключ/сертификат
- Отсутствует доступ в сеть/сервер недоступен
- Порт уже занят локальным процессом
- systemd отключён в текущей WSL среде
- Повторный запуск установки (идемпотентность)
- Ошибки прав доступа к файлам конфигурации

Assumptions (разумные допущения):

- Пользователь использует WSL2 Ubuntu 22.04 или 24.04 с активным systemd.
- Пользователь имеет валидные данные сервера (адрес, порт, UUID/пароль, параметры TLS/XTLS/Reality) и может их получить из своей панели.
- Права суперпользователя доступны для операций, требующих системных изменений.

## Requirements *(mandatory)*

<!--
  ACTION REQUIRED: The content in this section represents placeholders.
  Fill them out with the right functional requirements.
-->

### Functional Requirements

- **FR-001**: Решение должно обеспечивать установку и подключение к VPN за один понятный процесс с максимум 3 шагами пользователя: копирование .env.example → .env, заполнение обязательных параметров, запуск ./scripts/install.sh.
- **FR-002**: Перед выполнением операций конфигурация должна валидироваться; при отсутствии обязательных значений — понятное сообщение и ненулевой код завершения.
- **FR-003**: Должна поддерживаться работа с протоколами VLESS, VMess, Trojan с вариантами защиты TLS/XTLS/Reality (при наличии параметров).
- **FR-004**: Должен быть доступен набор команд управления: запуск, остановка, перезапуск, статус (включая краткую сводку состояния).
- **FR-005**: Должна быть команда проверки текущего внешнего IP для подтверждения маршрута через VPN.
- **FR-006**: Должна быть команда отображения версии решения.
- **FR-007**: Должна быть предусмотрена команда просмотра логов с параметрами (последние N строк, follow), исключая вывод секретов.
- **FR-008**: Должна быть возможность включать и отключать автозапуск через механизмы ОС.
- **FR-009**: Процесс удаления должен полностью убирать созданные файлы/юниты/настройки, оставляя систему чистой.
- **FR-010**: Повторный запуск установки не должен ломать существующую установку и должен быть идемпотентным.
- **FR-011**: Вся пользовательская документация должна быть доступна из репозитория: краткий старт, справка по настройке и устранение проблем.
- **FR-012**: Выходные коды команд должны соответствовать успешному/неуспешному исходу, сообщения об ошибках — понятные и диагностичные.

### Decisions from Clarifications

- **FR-013**: Автозапуск по умолчанию отключён. Пользователь включает его явной командой.
- **FR-014**: Порт прокси (например 1080/1081) обязан быть явно задан в `.env`; отсутствие значения вызывает отказ запуска.
- **FR-015**: Поддержка гарантируется для WSL2 + Ubuntu 22.04 LTS и 24.04 LTS.

### Localization & UX Requirements

- **FR-016**: All user messages (help, validation errors, status) must support English as primary language and Russian as fallback through environment variable `XRAY_CLIENT_LANG=ru` or `LANG=ru`.
- **FR-017**: `status` command must output structured information: service state (running/stopped/failed), last start date, error indication (if any), external IP (if active).
- **FR-018**: `logs` command must support parameters: `--lines N` (last N lines, default 20), `--follow` (tail -f mode), `--level LEVEL` (level filter: ERROR, WARN, INFO, DEBUG).
- **FR-019**: Logging must not output secret variables: forbidden values `XRAY_UUID_OR_PASS`, `XRAY_PUBLIC_KEY`, `XRAY_SHORT_ID`, any fields with `_KEY` or `_PASS` suffix.

### Help & Documentation Requirements

- **FR-020**: All user-facing scripts must provide comprehensive `--help` output including: usage syntax, required parameters, optional parameters with defaults, example commands, common error codes with explanations.
- **FR-021**: `manage.sh` must document all available commands: start, stop, restart, status, logs, check-ip, version, autostart-enable, autostart-disable with parameter descriptions.
- **FR-022**: Help text must be formatted for readability: 80-character line width, consistent parameter grouping, examples section, troubleshooting hints.

### Error Handling & User Guidance Requirements

- **FR-023**: Error messages must suggest specific corrective actions: "Missing XRAY_SERVER_HOST. Set it in .env file, example: XRAY_SERVER_HOST=vpn.example.com".
- **FR-024**: Validation errors must distinguish between missing required variables (exit code 10) and invalid format errors (exit code 11) with different message formatting.
- **FR-025**: System requirement failures must provide clear installation instructions: "systemd not enabled. Run: sudo systemctl enable systemd-resolved".

### Installation & Uninstall Behavior Requirements

- **FR-026**: `install.sh --force` must regenerate all configuration files and re-download Xray binary; normal `install.sh` must skip existing valid installations.
- **FR-027**: Full uninstall must remove specific artifacts: `/usr/local/bin/xray`, `/etc/systemd/system/xray-wsl.service`, `~/.config/xray-wsl/`, configuration files, with verification step.
- **FR-028**: Successful VPN connection must be verified by external IP change: baseline IP recorded before connection, VPN IP confirmed after, with clear success/failure messaging.

### Edge Cases & Recovery Requirements

- **FR-029**: Port conflict detection must validate SOCKS port != HTTP port and check if ports are available before starting service.
- **FR-030**: Missing optional HTTP port must be handled gracefully: omit HTTP inbound from Xray configuration, document in status output as "HTTP proxy: disabled".
- **FR-031**: Reality protocol must validate complete parameter set: publicKey, shortId (hex 1-16 chars), fingerprint (chrome/firefox/safari/ios/android), serverName (SNI).
- **FR-032**: Dependency failures must provide installation commands: "jq not found. Install: sudo apt install jq -y".
- **FR-033**: Network connectivity failures must distinguish between DNS resolution, connection timeout, and authentication errors with specific troubleshooting steps.

### Data Format & Validation Requirements

- **FR-034**: UUID format must match regex `^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$` for VLESS/VMess protocols.
- **FR-035**: Environment variable validation must treat zero-length and whitespace-only values as missing, not invalid format.
- **FR-036**: Protocol names must be case-insensitive but normalized to lowercase; typos must suggest nearest match: "Unknown protocol 'vles'. Did you mean 'vless'?".
- **FR-037**: Configuration changes after initial install must trigger warning: "Configuration changed. Run './scripts/install.sh --force' to apply changes".

### Non-Interactive & Logging Requirements

- **FR-038**: All scripts must operate non-interactively: no prompts, all input via environment variables or command line arguments.
- **FR-039**: CLI output must be plain text without ANSI colors or formatting for compatibility with logging and automation tools.
- **FR-040**: Idempotency validation must ensure two sequential installs produce identical system state and both exit with code 0.

### Scenario & Flow Requirements

- **FR-041**: Primary user flows (first install, lifecycle management, uninstall) must be documented with complete examples in help text.
- **FR-042**: Protocol changes after installation must be supported: "Configuration protocol changed from 'vless' to 'vmess'. Run './scripts/install.sh --force' to reconfigure".
- **FR-043**: Download failures must retry automatically (3 attempts) with exponential backoff before displaying error with corrective action.
- **FR-044**: Port conflicts must be detected before installation: "Port 1080 already in use by process PID 1234. Choose different SOCKS_PORT or stop conflicting service".
- **FR-045**: Reality parameters must be validated as complete set: missing values trigger "Reality requires all 4 parameters: SNI, public_key, fingerprint, short_id".
- **FR-046**: Repeated uninstall operations must be idempotent: "System already clean. No Xray installation found" with exit code 0.
- **FR-047**: Empty vs missing environment variables must be handled distinctly with specific error messages for each case.
- **FR-048**: Invalid protocol names must suggest corrections: "Unknown protocol 'vles'. Did you mean 'vless'? Supported: vless, vmess, trojan".

### Dependency & System Requirements

- **FR-049**: Missing system dependencies must provide installation commands: "jq not found. Install with: sudo apt update && sudo apt install jq".
- **FR-050**: Systemd availability must be verified with clear error: "Systemd not available or disabled. Enable with: sudo systemctl enable systemd".
- **FR-051**: Network availability must be checked before downloads with offline mode guidance when applicable.

### Non-Functional UX Requirements

- **FR-052**: Help text must use consistent formatting: max 80 characters per line, logical grouping with section headers, consistent parameter syntax.
- **FR-053**: Logging verbosity levels must be controllable via LOG_LEVEL environment variable (ERROR, WARN, INFO, DEBUG) with appropriate defaults.
- **FR-054**: All output must exclude ANSI color codes and special formatting for compatibility with logging systems and non-interactive environments.
- **FR-055**: Command disambiguation must be clear: 'status' shows current state, 'logs' shows recent activity, no overlapping information.
- **FR-056**: Interactive prompts are explicitly prohibited; all operations must be scriptable and automatable with appropriate exit codes.

### Error Handling & Edge Cases

- **FR-057**: Permission denied errors must include specific corrective actions: "Permission denied accessing '/etc/systemd/system'. Run with sudo or check file permissions".
- **FR-058**: Partial file write failures must trigger cleanup and retry: detect incomplete downloads, remove corrupted files, attempt recovery.
- **FR-059**: Corrupted download detection must verify checksums before extraction with clear error messages and retry instructions.
- **FR-060**: All error messages must follow consistent ID scheme (ERR-001 through ERR-999) with corresponding documentation and resolution steps.

### Key Entities *(include if feature involves data)*

- **Конфигурация подключения**: сервер (адрес, порт), идентификатор (UUID/пароль), параметры защиты (TLS/XTLS/Reality: SNI, pubkey, fingerprint, sid), локальные параметры (порт прокси, автозапуск).
- **Состояние сервиса**: активен/остановлен, дата/время последнего изменения, признаки ошибок из логов.

## Success Criteria *(mandatory)*

<!--
  ACTION REQUIRED: Define measurable success criteria.
  These must be technology-agnostic and measurable.
-->

### Measurable Outcomes

- **SC-001**: Пользователь проходит установку и подключается менее чем за 5 минут (после заполнения конфигурации).
- **SC-002**: В 95% случаев проверка IP подтверждает маршрут через VPN с первой попытки при валидных параметрах.
- **SC-003**: Команды управления и статуса завершаются < 1 секунды при нормальной нагрузке WSL (доступная сеть, <80% CPU/RAM).
- **SC-004**: Деинсталляция удаляет 100% установленных компонент (юнит, конфиг, файлы), оставляя систему в исходном состоянии.
- **SC-005**: Команда `status` отвечает за < 500мс и возвращает все указанные поля (состояние, дата старта, ошибки, IP).
- **SC-006**: Команда `logs` с параметрами работает корректно: `--lines 10` выводит ровно 10 строк, `--level ERROR` показывает только ошибки.
- **SC-007**: В 100% случаев логи не содержат значений секретных переменных (автоматическая проверка по регулярным выражениям).
- **SC-008**: Установка с валидными параметрами завершается менее чем за 120 секунд при нормальной скорости сети (>1 Мбит/с).
- **SC-009**: Команда помощи `--help` для любого скрипта завершается менее чем за 200мс и выводит форматированный текст не длиннее 50 строк.
- **SC-010**: Система после полного удаления не содержит остатков: 0 файлов в `/usr/local/bin/xray*`, 0 юнитов `*xray*`, 0 конфигурационных файлов.
- **SC-011**: Повторная установка (идемпотентность) завершается за <10 секунд и не изменяет функционирующую систему.

## Clarifications

### Session 2025-11-09

*Полное решение UX чеклиста (52/52 пунктов):*

**Completeness & Clarity (CHK001-015):**

- Help text standards: FR-020-022 (синтаксис, примеры, форматирование)
- Error handling: FR-023-025 (коды, корректирующие действия, примеры)
- Installation behavior: FR-026-028 (идемпотентность vs --force)

**Consistency & Measurability (CHK016-025):**

- Timing requirements: SC-008-011 с конкретными ограничениями
- Error code taxonomy: FR-024 с измеримыми критериями
- Validation rules: FR-034-037 (UUID, переменные, порты)

**Scenarios & Edge Cases (CHK026-035):**

- Primary flows: FR-041 (установка, управление, удаление)
- Alternative flows: FR-042-043 (смена протокола, восстановление)
- Edge cases: FR-044-048 (конфликты портов, валидация Reality, повторное удаление)

**Non-Functional & Dependencies (CHK036-043):**

- UX standards: FR-052-056 (форматирование, логирование, отсутствие ANSI)
- System requirements: FR-049-051 (зависимости, systemd, сеть)

**Clarity & Traceability (CHK044-052):**

- Command disambiguation: FR-055 (status vs logs)
- Interactive exclusion: FR-056 (чистый CLI)
- Error handling: FR-057-060 (права доступ, файловые ошибки, схема ID)
- Full coverage: все 60 FR покрывают 52 UX чеклиста
