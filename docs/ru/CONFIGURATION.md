<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk. No invasive ADB exposure.
   Configuration reference.

   Copyright (C) 2026  VD171
   SPDX-License-Identifier: Apache-2.0

   Licensed under the Apache License, Version 2.0; you may obtain a copy at
   http://www.apache.org/licenses/LICENSE-2.0

   Site           : https://vd171.ru
   Site           : https://vd.priv8.ru
   Source         : https://github.com/VD171/VD-dropbear
   GitHub         : @VD171 https://github.com/VD171
   XDA-Developers : @VD171 https://xdaforums.com/m/vd171.4699873/
   XDA thread     : https://xdaforums.com/t/VD-Dropbear.4808524/
   Telegram       : @VD_Priv8 https://t.me/VD_Priv8
   Channel        : @Priv8_VD https://t.me/Priv8_VD
   Discord        : @VD.Priv8 https://discord.com/users/1296831918989639721
   E-mail         : vd.priv8@pm.me
  ======================================================================
-->

> **Languages:** [English](../CONFIGURATION.md) · [العربية](../ar/CONFIGURATION.md) · [Čeština](../cs/CONFIGURATION.md) · [Deutsch](../de/CONFIGURATION.md) · [Español](../es/CONFIGURATION.md) · [فارسی](../fa/CONFIGURATION.md) · [Français](../fr/CONFIGURATION.md) · [हिन्दी](../hi/CONFIGURATION.md) · [Bahasa Indonesia](../in/CONFIGURATION.md) · [Italiano](../it/CONFIGURATION.md) · [日本語](../ja/CONFIGURATION.md) · [한국어](../ko/CONFIGURATION.md) · [Nederlands](../nl/CONFIGURATION.md) · [Polski](../pl/CONFIGURATION.md) · [Português](../pt/CONFIGURATION.md) · Русский · [Svenska](../sv/CONFIGURATION.md) · [ไทย](../th/CONFIGURATION.md) · [Türkçe](../tr/CONFIGURATION.md) · [Українська](../uk/CONFIGURATION.md) · [Tiếng Việt](../vi/CONFIGURATION.md) · [中文](../zh/CONFIGURATION.md)

---

# Конфигурация

Настройки находятся в `/data/adb/vddropbear/config` (при первой загрузке создаются из
`module/common/config.default`). **WebUI** редактирует этот файл за вас; вы также можете править его
вручную. Он подключается как shell, поэтому используйте `KEY=value` без пробелов вокруг `=`. Настройки
не являются секретом и находятся в хранилище, зашифрованном на уровне устройства; секреты (ключи хоста,
авторизованные ключи, хеши паролей) находятся в хранилище секретов, но не здесь.

Примените изменения, перезапустив демон (это делает кнопка **Save & restart** в WebUI).

## Общие

| Key | Default | Meaning |
|-----|---------|---------|
| `ENABLED` | `1` | Запускать демон при загрузке. `0` полностью его отключает. |
| `START_IN_BFU` | `0` | `0`: запуск только после первой разблокировки (AFU); секреты остаются в хранилище, зашифрованном учётными данными (CE). `1`: запуск также до первой разблокировки (BFU); секреты перемещаются в хранилище, зашифрованное на уровне устройства (DE), читаемое до разблокировки. |
| `PORT` | `2222` | Порт прослушивания по умолчанию (порты для отдельных привязок могут переопределять его в `LISTEN_ADDRESSES`). |

## Прослушивание / привязки (компонуемые)

Допустима любая комбинация; выбранные привязки объединяются. Если вы очистите всё, VD Dropbear
привяжется к loopback, а не ко всем интерфейсам.

| Key | Default | Meaning |
|-----|---------|---------|
| `LISTEN_LOOPBACK` | `1` | Слушать только на `127.0.0.1` / `::1`. |
| `LISTEN_ALL` | `0` | Слушать на каждом интерфейсе (`0.0.0.0` / `::`); открывает устройство. |
| `LISTEN_IPV4` | `1` | Включить привязки IPv4. |
| `LISTEN_IPV6` | `1` | Включить привязки IPv6. |
| `LISTEN_ADDRESSES` | `""` | Дополнительные конкретные привязки через запятую: `addr` (использует `PORT`) или `addr:port`, IPv4 или IPv6. |

## Идентификация

| Key | Default | Meaning |
|-----|---------|---------|
| `HIDE_IDENT` | `1` | Отправлять нейтральный баннер идентификации SSH, чтобы сканеры не могли определить точный сервер/версию. |
| `IDENT_STRING` | `""` | Пользовательская строка идентификации. Пустое значение использует нейтральное встроенное по умолчанию. |

## Аутентификация

Вход выполняется под той учётной записью, под которой вы проходите аутентификацию: по умолчанию **root** либо учётная запись с меньшими привилегиями (`shell`, `system`). Ключи используются по умолчанию; пароли включаются по желанию.

| Key | Default | Meaning |
|-----|---------|---------|
| `PUBKEY_AUTH` | `1` | Разрешить вход по публичному ключу (читает авторизованные ключи в хранилище секретов). |
| `PASSWORD_AUTH` | `0` | Разрешить вход по паролю. Когда выключено, демон запускается с отключённой аутентификацией по паролю. |
| `MAX_AUTH_TRIES` | `3` | Максимальное число попыток аутентификации на одно соединение. |

## Сессия / окружение

| Key | Default | Meaning |
|-----|---------|---------|
| `LOGIN_SHELL` | `""` | Шелл для сессии. Пустое значение использует шелл по умолчанию для учётной записи. |
| `HOME_DIR` | `""` | `HOME` для сессии. Пустое значение использует каталог модуля. |
| `EXTRA_ENV` | `""` | Дополнительное окружение, `K=V;K2=V2`. |
| `IDLE_TIMEOUT` | `0` | Отключать после N секунд простоя. `0` отключает. |
| `KEEPALIVE` | `0` | Отправлять keepalive каждые N секунд. `0` отключает. |
| `RECEIVE_WINDOW` | `""` | Размер окна приёма Dropbear. Пустое значение использует значение по умолчанию. |

## Проброс (по умолчанию выключен)

| Key | Default | Meaning |
|-----|---------|---------|
| `ALLOW_LOCAL_FORWARD` | `0` | Разрешить локальный (`-L`) проброс портов. |
| `ALLOW_REMOTE_FORWARD` | `0` | Разрешить удалённый (`-R`) проброс портов. |
| `GATEWAY_PORTS` | `0` | Позволять проброшенным удалённым портам привязываться ко всем интерфейсам. |

## Ключ хоста

| Key | Default | Meaning |
|-----|---------|---------|
| `HOSTKEY_TYPE` | `ed25519` | Тип ключа хоста: `ed25519`, `rsa` или `ecdsa`. Генерируется при первом запуске в хранилище секретов. |

## Хранилище секретов

Здесь не настраивается, определяется из `START_IN_BFU`:

- **AFU (по умолчанию):** `/data/misc_ce/0/vddropbear/secret`: зашифровано учётными данными,
  доступно только после того, как вы разблокируете устройство.
- **BFU:** `/data/adb/vddropbear/secret`: зашифровано на уровне устройства, читаемо до первой разблокировки.

Оно хранит ключ хоста, `authorized_keys` и файл хешей `passwd`. См.
[BUILDING.md](../BUILDING.md) для формата хеша пароля.
