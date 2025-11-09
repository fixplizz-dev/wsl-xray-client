# 🚀 Xray WSL Bootstrap

[![GitHub Stars](https://img.shields.io/github/stars/fixplizz-dev/xray-wsl-bootstrap?style=flat-square&logo=github&color=yellow)](https://github.com/fixplizz-dev/xray-wsl-bootstrap/stargazers)
[![GitHub Issues](https://img.shields.io/github/issues/fixplizz-dev/xray-wsl-bootstrap?style=flat-square&logo=github&color=red)](https://github.com/fixplizz-dev/xray-wsl-bootstrap/issues)
[![GitHub Discussions](https://img.shields.io/github/discussions/fixplizz-dev/xray-wsl-bootstrap?style=flat-square&logo=github&color=blue)](https://github.com/fixplizz-dev/xray-wsl-bootstrap/discussions)
[![Latest Release](https://img.shields.io/github/v/release/fixplizz-dev/xray-wsl-bootstrap?style=flat-square&logo=github&color=green)](https://github.com/fixplizz-dev/xray-wsl-bootstrap/releases)
[![License](https://img.shields.io/github/license/fixplizz-dev/xray-wsl-bootstrap?style=flat-square&color=blue)](LICENSE)

## Автоматическая установка и настройка Xray для WSL с systemd поддержкой

Простое решение для быстрого развертывания Xray VPN client в среде Windows Subsystem for Linux с полной интеграцией systemd.

## ✨ Возможности

- 🎯 **Одна команда** - полная установка за минуты
- 🔒 **Множественные протоколы** - VLESS, VMess, Trojan с TLS/XTLS/Reality
- 🛡️ **Безопасность по умолчанию** - автоматическая генерация UUID и сертификатов
- 📊 **Проверка подключения** - встроенная диагностика IP и DNS утечек
- 🌐 **Двуязычность** - поддержка русского и английского
- ⚡ **Systemd интеграция** - полное управление через systemctl
- 🧪 **Тестирование** - автоматические тесты с bats

## 🚀 Быстрый старт

### Предварительные требования

- Windows 10/11 с WSL2
- Ubuntu 22.04+ или совместимый дистрибутив
- Systemd поддержка в WSL
- Подключение к интернету

### Установка в одну команду

```bash
# Загружает репозиторий и создает .env файл
curl -fsSL https://raw.githubusercontent.com/fixplizz-dev/xray-wsl-bootstrap/main/bootstrap.sh | bash
```

Или клонируйте и запустите вручную:

```bash
git clone https://github.com/fixplizz-dev/xray-wsl-bootstrap.git
cd xray-wsl-bootstrap
cp .env.example .env
# Отредактируйте .env с вашими настройками сервера
nano .env
sudo ./scripts/install.sh
```

## ⚙️ Настройка

### 1. Создайте файл конфигурации

```bash
cp .env.example .env
nano .env
```

### 2. Основные параметры (.env)

```bash
# Основная конфигурация
XRAY_PROTOCOL="vless"                    # vless, vmess, trojan
XRAY_UUID="550e8400-e29b-41d4-a716-446655440000"
XRAY_PORT=443
XRAY_HOST="your.server.com"

# Безопасность (для VLESS/VMess с TLS)
XRAY_TLS="tls"                           # none, tls, xtls
XRAY_SNI="your.server.com"
XRAY_ALPN="h2,http/1.1"

# Расширенные настройки
XRAY_CLIENT_LANG="ru"                    # ru, en
XRAY_LOG_LEVEL="warn"                    # debug, info, warn, error
```

### 3. Генерация конфигурации

```bash
./scripts/generate-config.sh
```

### 4. Запуск службы

```bash
sudo systemctl enable --now xray-wsl
```

## 🔍 Проверка подключения

```bash
# Проверка статуса службы
sudo systemctl status xray-wsl

# Проверка IP и DNS утечек
./scripts/check-ip.sh

# Просмотр логов
sudo journalctl -u xray-wsl -f
```

## 📚 Примеры конфигураций

### VLESS + Reality (рекомендуется)

```bash
XRAY_PROTOCOL="vless"
XRAY_SECURITY="reality"
XRAY_REALITY_DEST="microsoft.com:443"
XRAY_REALITY_SERVER_NAMES="microsoft.com,www.microsoft.com"
XRAY_REALITY_SHORT_ID="6ba85179e30d4fc2"
XRAY_REALITY_PUBLIC_KEY="your-public-key"
XRAY_REALITY_PRIVATE_KEY="your-private-key"
```

### VMess + WebSocket + TLS

```bash
XRAY_PROTOCOL="vmess"
XRAY_NETWORK="ws"
XRAY_PATH="/vmessws"
XRAY_TLS="tls"
XRAY_SNI="your.cloudflare-domain.com"
```

### Trojan + gRPC

```bash
XRAY_PROTOCOL="trojan"
XRAY_NETWORK="grpc"
XRAY_GRPC_SERVICE="trojangrpc"
XRAY_TLS="tls"
```

## 🛠️ Управление

### Systemd команды

```bash
# Запуск
sudo systemctl start xray-wsl

# Остановка
sudo systemctl stop xray-wsl

# Перезапуск
sudo systemctl restart xray-wsl

# Включить автозапуск
sudo systemctl enable xray-wsl

# Отключить автозапуск
sudo systemctl disable xray-wsl

# Статус
sudo systemctl status xray-wsl
```

### Обновление конфигурации

```bash
# Обновите .env файл
nano .env

# Сгенерируйте новую конфигурацию
./scripts/generate-config.sh

# Перезапустите службу
sudo systemctl restart xray-wsl
```

## 🧪 Тестирование

```bash
# Установите bats (если не установлен)
sudo apt install bats

# Запустите все тесты
bats tests/

# Запустите конкретный тест
bats tests/install.bats
```

## 🔧 Диагностика

### Общие проблемы

**Служба не запускается:**

```bash
# Проверьте конфигурацию
./scripts/generate-config.sh --validate

# Проверьте логи
sudo journalctl -u xray-wsl --no-pager -l
```

**Нет подключения к интернету:**

```bash
# Проверьте статус
./scripts/check-ip.sh

# Проверьте правила iptables
sudo iptables -L -n
```

**Systemd не поддерживается:**

```bash
# Проверьте поддержку systemd в WSL
systemctl --version
```

## 📂 Структура проекта

```text
xray-wsl-bootstrap/
├── 📄 README.md              # Документация
├── ⚙️ .env.example          # Пример конфигурации
├── 📜 .version              # Версия проекта
├── scripts/                 # Исполняемые скрипты
│   ├── 🚀 install.sh        # Основной установщик
│   ├── ⚙️ generate-config.sh # Генератор конфигурации
│   └── 🔍 check-ip.sh       # Проверка подключения
├── lib/                     # Библиотеки
│   ├── 📚 common.sh         # Общие функции
│   └── ✅ validate.sh       # Валидация входных данных
├── configs/                 # Шаблоны конфигураций
│   └── 📋 xray.template.json
└── systemd/                 # Systemd интеграция
    └── 🔧 xray-wsl.service.template
```

## 🤝 Поддержка и обратная связь

### 📞 Получить помощь

- 🐛 [Создать issue](https://github.com/fixplizz-dev/xray-wsl-bootstrap/issues) - для багов и предложений
- 💬 [Обсуждения](https://github.com/fixplizz-dev/xray-wsl-bootstrap/discussions) - для вопросов и идей
- ⭐ [Поставить звезду](https://github.com/fixplizz-dev/xray-wsl-bootstrap) - если проект полезен
- 📖 [Wiki](https://github.com/fixplizz-dev/xray-wsl-bootstrap/wiki) - расширенная документация

## 🏷️ Версии и обновления

- **v0.1.0** (текущая) - MVP релиз с базовой функциональностью
  - ✅ Автоматическая установка Xray
  - ✅ Поддержка VLESS/VMess/Trojan
  - ✅ Systemd интеграция
  - ✅ IP проверка и диагностика

## 📄 Лицензия

Этот проект распространяется под лицензией MIT. См. файл [LICENSE](LICENSE) для подробностей.

## 🔗 Полезные ссылки

- [Xray официальная документация](https://xtls.github.io/)
- [WSL документация](https://docs.microsoft.com/en-us/windows/wsl/)
- [Systemd в WSL](https://devblogs.microsoft.com/commandline/systemd-support-is-now-available-in-wsl/)

---

---

⚡ **Сделано с ❤️ для WSL сообщества**