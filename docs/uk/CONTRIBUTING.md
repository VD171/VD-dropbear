<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk - no invasive ADB exposure.
   Contributing guide.

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

> **Languages:** [English](../../CONTRIBUTING.md) · [العربية](../ar/CONTRIBUTING.md) · [Čeština](../cs/CONTRIBUTING.md) · [Deutsch](../de/CONTRIBUTING.md) · [Español](../es/CONTRIBUTING.md) · [فارسی](../fa/CONTRIBUTING.md) · [Français](../fr/CONTRIBUTING.md) · [हिन्दी](../hi/CONTRIBUTING.md) · [Bahasa Indonesia](../in/CONTRIBUTING.md) · [Italiano](../it/CONTRIBUTING.md) · [日本語](../ja/CONTRIBUTING.md) · [한국어](../ko/CONTRIBUTING.md) · [Nederlands](../nl/CONTRIBUTING.md) · [Polski](../pl/CONTRIBUTING.md) · [Português](../pt/CONTRIBUTING.md) · [Русский](../ru/CONTRIBUTING.md) · [Svenska](../sv/CONTRIBUTING.md) · [ไทย](../th/CONTRIBUTING.md) · [Türkçe](../tr/CONTRIBUTING.md) · Українська · [Tiếng Việt](../vi/CONTRIBUTING.md) · [中文](../zh/CONTRIBUTING.md)

---

# Внесок у VD Dropbear

Дякуємо за інтерес. Це невеликий проєкт, чутливий до безпеки (він надає root), тож зміни переглядаються
з огляду на це.

## Структура репозиторію

```
module/     the installable KernelSU / APatch / Magisk module (scripts, WebUI, config, installer)
patches/    the patch set applied on top of upstream Dropbear (the only changes to the SSH server)
src/        where CI unpacks upstream Dropbear to build (not committed)
scripts/    build and maintenance helpers
.github/    CI workflows and issue/PR templates
docs/       documentation (mirrored to the wiki)
```

## Збирання

Бінарний файл створюється CI з **upstream [mkj/dropbear](https://github.com/mkj/dropbear)** плюс патчі
з `patches/`. Для локального збирання вам потрібен Android NDK:

```sh
scripts/build.sh            # fetches the tracked upstream, applies patches, builds arm64 + arm32
```

Набір патчів навмисно мінімальний і придатний для аудиту: нейтральний/налаштовуваний рядок
ідентичності, шляхи, керовані конфігурацією, для `authorized_keys` і файлу паролів, виправлення
`openpty` для Android та конфігурація середовища виконання. Будь ласка, тримайте нові патчі невеликими,
задокументованими й обґрунтованими в PR.

## Pull requests

- Одна логічна зміна на PR; опишіть мотивацію та вплив на безпеку.
- Дотримуйтеся наявного стилю оболонки (POSIX `sh` / Android `mksh`; без bashisms).
- Кожен файл містить короткий SPDX-заголовок - зберігайте його.
- Оновлюйте [`CHANGELOG.md`](../../CHANGELOG.md) у розділі `[Unreleased]` для будь-якої реальної
  зміни, видимої користувачу.
- Надсилаючи PR, ви погоджуєтеся ліцензувати свій внесок за ліцензією проєкту
  [Apache-2.0](../../LICENSE).

## Переклади

README та документація підтримуються багатьма мовами (`README.<lang>.md`). Англійська - джерело істини;
переклади слідують за нею. Якщо ви покращуєте переклад або додаєте мову, зберігайте структуру та якорі
розділів ідентичними англійській версії.

## Повідомлення про помилки та проблеми безпеки

Використовуйте шаблони issue для помилок і запитів на функції. Для всього, що може скомпрометувати
пристрій, дотримуйтеся [`SECURITY.md`](SECURITY.md) і повідомляйте приватно замість відкриття публічної
issue.
