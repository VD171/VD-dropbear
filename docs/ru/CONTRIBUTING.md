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

> **Languages:** [English](../../CONTRIBUTING.md) · [العربية](../ar/CONTRIBUTING.md) · [Čeština](../cs/CONTRIBUTING.md) · [Deutsch](../de/CONTRIBUTING.md) · [Español](../es/CONTRIBUTING.md) · [فارسی](../fa/CONTRIBUTING.md) · [Français](../fr/CONTRIBUTING.md) · [हिन्दी](../hi/CONTRIBUTING.md) · [Bahasa Indonesia](../in/CONTRIBUTING.md) · [Italiano](../it/CONTRIBUTING.md) · [日本語](../ja/CONTRIBUTING.md) · [한국어](../ko/CONTRIBUTING.md) · [Nederlands](../nl/CONTRIBUTING.md) · [Polski](../pl/CONTRIBUTING.md) · [Português](../pt/CONTRIBUTING.md) · Русский · [Svenska](../sv/CONTRIBUTING.md) · [ไทย](../th/CONTRIBUTING.md) · [Türkçe](../tr/CONTRIBUTING.md) · [Українська](../uk/CONTRIBUTING.md) · [Tiếng Việt](../vi/CONTRIBUTING.md) · [中文](../zh/CONTRIBUTING.md)

---

# Участие в VD Dropbear

Спасибо за интерес. Это небольшой, чувствительный к безопасности проект (он раздаёт root), поэтому
изменения проверяются с учётом этого.

## Структура репозитория

```
module/     the installable KernelSU / APatch / Magisk module (scripts, WebUI, config, installer)
patches/    the patch set applied on top of upstream Dropbear (the only changes to the SSH server)
src/        where CI unpacks upstream Dropbear to build (not committed)
scripts/    build and maintenance helpers
.github/    CI workflows and issue/PR templates
docs/       documentation (mirrored to the wiki)
```

## Сборка

Бинарник собирается в CI из **апстрима [mkj/dropbear](https://github.com/mkj/dropbear)** плюс патчи в
`patches/`. Для локальной сборки вам нужен Android NDK:

```sh
scripts/build.sh            # fetches the tracked upstream, applies patches, builds arm64 + arm32
```

Набор патчей намеренно минимален и поддаётся аудиту: нейтральная/настраиваемая строка идентификации,
задаваемые конфигурацией пути к `authorized_keys` и файлу паролей, исправление `openpty` для Android и
конфигурация времени выполнения. Пожалуйста, делайте новые патчи небольшими, документированными и
обоснованными в PR.

## Pull request'ы

- Одно логическое изменение на PR; опишите мотивацию и влияние на безопасность.
- Придерживайтесь существующего стиля шелла (POSIX `sh` / Android `mksh`; без башизмов).
- В каждом файле есть короткий заголовок SPDX - сохраняйте его.
- Обновляйте [`CHANGELOG.md`](../../CHANGELOG.md) в разделе `[Unreleased]` при любом реальном, видимом пользователю изменении.
- Отправляя PR, вы соглашаетесь лицензировать свой вклад под лицензией проекта [Apache-2.0](../../LICENSE).

## Переводы

README и документация поддерживаются на многих языках (`README.<lang>.md`). Английский - источник
истины; переводы следуют за ним. Если вы улучшаете перевод или добавляете язык, сохраняйте структуру и
якоря разделов идентичными английской версии.

## Сообщения об ошибках и проблемах безопасности

Используйте шаблоны issue для ошибок и запросов функций. Для всего, что может скомпрометировать
устройство, следуйте [`SECURITY.md`](SECURITY.md) и сообщайте об этом в частном порядке, а не открывая
публичную issue.
