<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk - no invasive ADB exposure.
   Architecture.

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

> **Languages:** [English](../ARCHITECTURE.md) · [العربية](../ar/ARCHITECTURE.md) · [Čeština](../cs/ARCHITECTURE.md) · [Deutsch](../de/ARCHITECTURE.md) · [Español](../es/ARCHITECTURE.md) · [فارسی](../fa/ARCHITECTURE.md) · [Français](../fr/ARCHITECTURE.md) · [हिन्दी](../hi/ARCHITECTURE.md) · [Bahasa Indonesia](../in/ARCHITECTURE.md) · [Italiano](../it/ARCHITECTURE.md) · [日本語](../ja/ARCHITECTURE.md) · [한국어](../ko/ARCHITECTURE.md) · [Nederlands](../nl/ARCHITECTURE.md) · [Polski](../pl/ARCHITECTURE.md) · [Português](../pt/ARCHITECTURE.md) · [Русский](../ru/ARCHITECTURE.md) · [Svenska](../sv/ARCHITECTURE.md) · [ไทย](../th/ARCHITECTURE.md) · [Türkçe](../tr/ARCHITECTURE.md) · Українська · [Tiếng Việt](../vi/ARCHITECTURE.md) · [中文](../zh/ARCHITECTURE.md)

---

# Архітектура

VD Dropbear - це модуль KernelSU / APatch / Magisk, що запускає рівно один демон Dropbear SSH,
керований цілком через конфігурацію. У SSH-сервері немає нічого жорстко прив'язаного до одного
пристрою; усе специфічне - це конфігурація середовища виконання або секрет.

## Складові

- `module/common/vddropbear.sh` - основна бібліотека: завантаження конфігурації (з безпечними
  вбудованими значеннями за замовчуванням), визначення сховища секретів, забезпечення host key,
  побудова вектора аргументів Dropbear та керування єдиним екземпляром демона
  (start / stop / status / restart).
- `module/service.sh` - вхід під час завантаження. Дотримується політики запуску BFU/AFU; у режимі AFU
  чекає на розблокування credential-encrypted сховища, не затримуючи завантаження.
- `module/action.sh` - кнопка **Action** у менеджері: (пере)запуск демона. Вона ніколи не читає stdin
  і від'єднує демон у власну сесію, тож менеджер не зависає.
- `module/common/vddb-webui.sh` + `module/webroot/index.html` - бекенд і сторінка WebUI.
- `patches/` - невеликі, придатні для аудиту патчі, що застосовуються до upstream-версії Dropbear під
  час збирання.
- `scripts/build.sh`, `scripts/build-bundles.sh`, `.github/workflows/build.yml` - збирання.

## Життєвий цикл демона (єдиний екземпляр)

`vddb_start` завантажує конфігурацію, зупиняє будь-який запущений екземпляр, переконується в наявності
host key, а потім породжує один демон. Бінарний файл постачається як `vddropbear`, тож його ім'я
процесу точно відповідає `pgrep -x` (в Android `mksh` немає `exec -a`). Його запускають із `setsid`,
тож він від'єднується від групи процесів ініціатора - саме це не дає Action менеджера блокуватися.

## Сховище секретів (CE проти DE, BFU проти AFU)

Налаштування не є секретними й зберігаються в device-encrypted сховищі (`/data/adb/vddropbear`),
доступному під час завантаження. Секрети - host key, `authorized_keys`, хеші паролів - за замовчуванням
зберігаються в **credential-encrypted** сховищі (`/data/misc_ce/0/vddropbear`), яке розблоковується
лише після автентифікації користувача. Увімкнення `START_IN_BFU` переносить секрети в device-encrypted
сховище, щоб демон міг працювати до першого розблокування, ціною того, що ці секрети стають доступними
раніше. Модуль обчислює, яке сховище використати, на кожному етапі завантаження.

## Набір патчів

SSH-сервер лишається upstream-версією Dropbear; наші зміни - це кілька придатних для перегляду патчів
(див. [patches/README.md](../../patches/README.md)):

- нейтральний, налаштовуваний у середовищі виконання банер ідентичності;
- `authorized_keys` читаються зі шляху, заданого через середовище (тож ключі зберігаються у сховищі
  секретів);
- автентифікація за паролем проти файлу хешів PBKDF2 замість системного `crypt()`/shadow, якого в
  Android немає (див. [BUILDING.md](../BUILDING.md)).

## WebUI

Статична сторінка в WebUI менеджера (KernelSU / APatch / WebUI-X). Вона керує
`module/common/vddb-webui.sh` через міст `ksu.exec`: статус, start/stop/restart, читання/запис
конфігурації та керування ключами й обліковими записами з паролями. Усі дані проходять через міст у
base64-кодуванні, тож оболонка їх ніколи не інтерпретує; хеші паролів обчислюються у браузері за
допомогою WebCrypto, тож відкритий пароль ніколи не залишає сторінку.
