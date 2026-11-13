<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk - no invasive ADB exposure.
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

> **Languages:** [English](../CONFIGURATION.md) · [العربية](../ar/CONFIGURATION.md) · [Čeština](../cs/CONFIGURATION.md) · [Deutsch](../de/CONFIGURATION.md) · [Español](../es/CONFIGURATION.md) · [فارسی](../fa/CONFIGURATION.md) · [Français](../fr/CONFIGURATION.md) · [हिन्दी](../hi/CONFIGURATION.md) · [Bahasa Indonesia](../in/CONFIGURATION.md) · [Italiano](../it/CONFIGURATION.md) · [日本語](../ja/CONFIGURATION.md) · [한국어](../ko/CONFIGURATION.md) · [Nederlands](../nl/CONFIGURATION.md) · [Polski](../pl/CONFIGURATION.md) · [Português](../pt/CONFIGURATION.md) · [Русский](../ru/CONFIGURATION.md) · [Svenska](../sv/CONFIGURATION.md) · [ไทย](../th/CONFIGURATION.md) · [Türkçe](../tr/CONFIGURATION.md) · Українська · [Tiếng Việt](../vi/CONFIGURATION.md) · [中文](../zh/CONFIGURATION.md)

---

# Конфігурація

Налаштування зберігаються у `/data/adb/vddropbear/config` (початково заповнюються з
`module/common/config.default` під час першого завантаження). **WebUI** редагує цей файл за вас; ви
також можете редагувати його вручну. Він підключається як shell, тож використовуйте `KEY=value` без
пробілів навколо `=`. Налаштування не є секретними й зберігаються в device-encrypted сховищі; секрети
(host keys, authorized keys, хеші паролів) зберігаються у сховищі секретів, ніколи тут.

Застосовуйте зміни перезапуском демона (це робить **Save & restart** у WebUI).

## Загальні

| Key | Default | Meaning |
|-----|---------|---------|
| `ENABLED` | `1` | Запускати демон під час завантаження. `0` повністю вимикає його. |
| `START_IN_BFU` | `0` | `0`: запуск лише після першого розблокування (AFU); секрети лишаються в credential-encrypted (CE) сховищі. `1`: запуск також до першого розблокування (BFU); секрети переходять у device-encrypted (DE) сховище, доступне до розблокування. |
| `PORT` | `2222` | Порт прослуховування за замовчуванням (окремі порти для прив'язок можуть перевизначати його в `LISTEN_ADDRESSES`). |

## Прослуховування / прив'язки (комбіновані)

Дозволена будь-яка комбінація; обрані прив'язки об'єднуються. Якщо очистити все, VD Dropbear
прив'язується до loopback, а не до кожного інтерфейсу.

| Key | Default | Meaning |
|-----|---------|---------|
| `LISTEN_LOOPBACK` | `1` | Прослуховувати лише `127.0.0.1` / `::1`. |
| `LISTEN_ALL` | `0` | Прослуховувати на кожному інтерфейсі (`0.0.0.0` / `::`) - відкриває пристрій. |
| `LISTEN_IPV4` | `1` | Включати IPv4-прив'язки. |
| `LISTEN_IPV6` | `1` | Включати IPv6-прив'язки. |
| `LISTEN_ADDRESSES` | `""` | Додаткові конкретні прив'язки через кому: `addr` (використовує `PORT`) або `addr:port`, IPv4 чи IPv6. |

## Ідентичність

| Key | Default | Meaning |
|-----|---------|---------|
| `HIDE_IDENT` | `1` | Надсилати нейтральний банер ідентичності SSH, щоб сканери не могли визначити точний сервер/версію. |
| `IDENT_STRING` | `""` | Користувацький рядок ідентичності. Порожнє значення використовує нейтральне вбудоване за замовчуванням. |

## Автентифікація

Кожен автентифікований вхід - це **root**. Ключі - це варіант за замовчуванням; паролі вмикаються за
бажанням.

| Key | Default | Meaning |
|-----|---------|---------|
| `PUBKEY_AUTH` | `1` | Дозволити вхід за публічним ключем (читає authorized keys у сховищі секретів). |
| `PASSWORD_AUTH` | `0` | Дозволити вхід за паролем. Коли вимкнено, демон запускається з вимкненою автентифікацією за паролем. |
| `MAX_AUTH_TRIES` | `3` | Максимальна кількість спроб автентифікації на одне з'єднання. |

## Сесія / середовище

| Key | Default | Meaning |
|-----|---------|---------|
| `LOGIN_SHELL` | `""` | Оболонка для сесії. Порожнє значення використовує за замовчуванням для облікового запису. |
| `HOME_DIR` | `""` | `HOME` для сесії. Порожнє значення використовує каталог модуля. |
| `EXTRA_ENV` | `""` | Додаткове середовище, `K=V;K2=V2`. |
| `IDLE_TIMEOUT` | `0` | Від'єднувати після N секунд бездіяльності. `0` вимикає. |
| `KEEPALIVE` | `0` | Надсилати keepalive кожні N секунд. `0` вимикає. |
| `RECEIVE_WINDOW` | `""` | Розмір вікна прийому Dropbear. Порожнє значення використовує за замовчуванням. |

## Переадресація (вимкнено за замовчуванням)

| Key | Default | Meaning |
|-----|---------|---------|
| `ALLOW_LOCAL_FORWARD` | `0` | Дозволити локальну (`-L`) переадресацію портів. |
| `ALLOW_REMOTE_FORWARD` | `0` | Дозволити віддалену (`-R`) переадресацію портів. |
| `GATEWAY_PORTS` | `0` | Дозволити переадресованим віддаленим портам прив'язуватися до всіх інтерфейсів. |

## Host key

| Key | Default | Meaning |
|-----|---------|---------|
| `HOSTKEY_TYPE` | `ed25519` | Тип host key: `ed25519`, `rsa` чи `ecdsa`. Генерується під час першого запуску у сховищі секретів. |

## Сховище секретів

Не налаштовується тут - визначається з `START_IN_BFU`:

- **AFU (за замовчуванням):** `/data/misc_ce/0/vddropbear/secret` - credential-encrypted, доступне лише
  після того, як ви розблокуєте пристрій.
- **BFU:** `/data/adb/vddropbear/secret` - device-encrypted, доступне до першого розблокування.

Воно містить host key, `authorized_keys` та файл хешів `passwd`. Формат хешу пароля див. у
[BUILDING.md](../BUILDING.md).
