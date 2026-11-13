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
   XDA thread     : https://xdaforums.com/t/VD-dropbear.4808524/
   Telegram       : @VD_Priv8 https://t.me/VD_Priv8
   Channel        : @Priv8_VD https://t.me/Priv8_VD
   Discord        : @VD.Priv8 https://discord.com/users/1296831918989639721
   E-mail         : vd.priv8@pm.me
  ======================================================================
-->

> **Languages:** [English](../../CONTRIBUTING.md) · [العربية](../ar/CONTRIBUTING.md) · [Čeština](../cs/CONTRIBUTING.md) · [Deutsch](../de/CONTRIBUTING.md) · [Español](../es/CONTRIBUTING.md) · [فارسی](../fa/CONTRIBUTING.md) · [Français](../fr/CONTRIBUTING.md) · [हिन्दी](../hi/CONTRIBUTING.md) · [Bahasa Indonesia](../in/CONTRIBUTING.md) · [Italiano](../it/CONTRIBUTING.md) · [日本語](../ja/CONTRIBUTING.md) · [한국어](../ko/CONTRIBUTING.md) · Nederlands · [Polski](../pl/CONTRIBUTING.md) · [Português](../pt/CONTRIBUTING.md) · [Русский](../ru/CONTRIBUTING.md) · [Svenska](../sv/CONTRIBUTING.md) · [ไทย](../th/CONTRIBUTING.md) · [Türkçe](../tr/CONTRIBUTING.md) · [Українська](../uk/CONTRIBUTING.md) · [Tiếng Việt](../vi/CONTRIBUTING.md) · [中文](../zh/CONTRIBUTING.md)

---

# Bijdragen aan VD Dropbear

Bedankt voor je interesse. Dit is een klein, beveiligingsgevoelig project (het deelt root uit), dus wijzigingen worden met dat in gedachten beoordeeld.

## Indeling van de repository

```
module/     the installable KernelSU / APatch / Magisk module (scripts, WebUI, config, installer)
patches/    the patch set applied on top of upstream Dropbear (the only changes to the SSH server)
src/        where CI unpacks upstream Dropbear to build (not committed)
scripts/    build and maintenance helpers
.github/    CI workflows and issue/PR templates
docs/       documentation (mirrored to the wiki)
```

## Bouwen

De binary wordt door CI geproduceerd vanuit **upstream [mkj/dropbear](https://github.com/mkj/dropbear)** plus de patches in `patches/`. Om lokaal te bouwen heb je de Android NDK nodig:

```sh
scripts/build.sh            # fetches the tracked upstream, applies patches, builds arm64 + arm32
```

De patchset is bewust minimaal en controleerbaar: een neutrale/configureerbare identiteitsstring, configuratiegestuurde paden voor `authorized_keys` en het wachtwoordbestand, de Android-`openpty`-fix, en runtimeconfiguratie. Houd nieuwe patches klein, gedocumenteerd, en in de PR onderbouwd.

## Pull requests

- Eén logische wijziging per PR; beschrijf de motivatie en de beveiligingsimpact.
- Sluit aan bij de bestaande shellstijl (POSIX `sh` / Android `mksh`; geen bashisms).
- Elk bestand draagt een korte SPDX-header - houd die.
- Werk [`CHANGELOG.md`](../../CHANGELOG.md) bij onder `[Unreleased]` voor elke echte, voor gebruikers zichtbare wijziging.
- Door een PR in te dienen ga je ermee akkoord je bijdrage te licentiëren onder de [Apache-2.0](../../LICENSE)-licentie van het project.

## Vertalingen

De README en documentatie worden in veel talen onderhouden (`README.<lang>.md`). Engels is de bron van waarheid; vertalingen volgen die. Als je een vertaling verbetert of een taal toevoegt, houd dan de structuur en de sectieankers identiek aan de Engelse versie.

## Bugs en beveiligingsproblemen melden

Gebruik de issue-templates voor bugs en functieverzoeken. Voor alles wat een toestel in gevaar kan brengen, volg [`SECURITY.md`](SECURITY.md) en meld het privé in plaats van een openbare issue te openen.
