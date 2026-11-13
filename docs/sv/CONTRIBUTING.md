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

> **Languages:** [English](../../CONTRIBUTING.md) · [العربية](../ar/CONTRIBUTING.md) · [Čeština](../cs/CONTRIBUTING.md) · [Deutsch](../de/CONTRIBUTING.md) · [Español](../es/CONTRIBUTING.md) · [فارسی](../fa/CONTRIBUTING.md) · [Français](../fr/CONTRIBUTING.md) · [हिन्दी](../hi/CONTRIBUTING.md) · [Bahasa Indonesia](../in/CONTRIBUTING.md) · [Italiano](../it/CONTRIBUTING.md) · [日本語](../ja/CONTRIBUTING.md) · [한국어](../ko/CONTRIBUTING.md) · [Nederlands](../nl/CONTRIBUTING.md) · [Polski](../pl/CONTRIBUTING.md) · [Português](../pt/CONTRIBUTING.md) · [Русский](../ru/CONTRIBUTING.md) · Svenska · [ไทย](../th/CONTRIBUTING.md) · [Türkçe](../tr/CONTRIBUTING.md) · [Українська](../uk/CONTRIBUTING.md) · [Tiếng Việt](../vi/CONTRIBUTING.md) · [中文](../zh/CONTRIBUTING.md)

---

# Bidra till VD Dropbear

Tack för ditt intresse. Det här är ett litet, säkerhetskänsligt projekt (det delar ut root), så
ändringar granskas med det i åtanke.

## Förvarets struktur

```
module/     the installable KernelSU / APatch / Magisk module (scripts, WebUI, config, installer)
patches/    the patch set applied on top of upstream Dropbear (the only changes to the SSH server)
src/        where CI unpacks upstream Dropbear to build (not committed)
scripts/    build and maintenance helpers
.github/    CI workflows and issue/PR templates
docs/       documentation (mirrored to the wiki)
```

## Bygga

Binären produceras av CI från **upstream [mkj/dropbear](https://github.com/mkj/dropbear)** plus
patcharna i `patches/`. För att bygga lokalt behöver du Android NDK:

```sh
scripts/build.sh            # fetches the tracked upstream, applies patches, builds arm64 + arm32
```

Patchuppsättningen är avsiktligt minimal och granskningsbar: en neutral/konfigurerbar identitetssträng,
konfigurationsstyrda sökvägar för `authorized_keys` och lösenordsfilen, Androids `openpty`-fix och
körtidskonfiguration. Håll gärna nya patchar små, dokumenterade och motiverade i PR:en.

## Pull-förfrågningar

- En logisk ändring per PR; beskriv motivet och säkerhetspåverkan.
- Följ den befintliga skalstilen (POSIX `sh` / Android `mksh`; inga bashismer).
- Varje fil bär en kort SPDX-header - behåll den.
- Uppdatera [`CHANGELOG.md`](../../CHANGELOG.md) under `[Unreleased]` för varje verklig, användarsynlig ändring.
- Genom att skicka in en PR godkänner du att licensiera ditt bidrag under projektets [Apache-2.0](../../LICENSE)-licens.

## Översättningar

README och dokumentationen underhålls på många språk (`README.<lang>.md`). Engelska är källan till
sanningen; översättningar följer den. Om du förbättrar en översättning eller lägger till ett språk, håll
strukturen och sektionsankarna identiska med den engelska versionen.

## Rapportera buggar och säkerhetsproblem

Använd ärendemallarna för buggar och funktionsförfrågningar. För allt som kan äventyra en enhet, följ
[`SECURITY.md`](SECURITY.md) och rapportera privat i stället för att öppna ett offentligt ärende.
