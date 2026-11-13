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

> **Languages:** [English](../../CONTRIBUTING.md) · [العربية](../ar/CONTRIBUTING.md) · Čeština · [Deutsch](../de/CONTRIBUTING.md) · [Español](../es/CONTRIBUTING.md) · [فارسی](../fa/CONTRIBUTING.md) · [Français](../fr/CONTRIBUTING.md) · [हिन्दी](../hi/CONTRIBUTING.md) · [Bahasa Indonesia](../in/CONTRIBUTING.md) · [Italiano](../it/CONTRIBUTING.md) · [日本語](../ja/CONTRIBUTING.md) · [한국어](../ko/CONTRIBUTING.md) · [Nederlands](../nl/CONTRIBUTING.md) · [Polski](../pl/CONTRIBUTING.md) · [Português](../pt/CONTRIBUTING.md) · [Русский](../ru/CONTRIBUTING.md) · [Svenska](../sv/CONTRIBUTING.md) · [ไทย](../th/CONTRIBUTING.md) · [Türkçe](../tr/CONTRIBUTING.md) · [Українська](../uk/CONTRIBUTING.md) · [Tiếng Việt](../vi/CONTRIBUTING.md) · [中文](../zh/CONTRIBUTING.md)

---

# Přispívání do VD Dropbear

Díky za tvůj zájem. Tohle je malý projekt citlivý na bezpečnost (rozdává root), takže se změny
posuzují s ohledem na to.

## Rozvržení repozitáře

```
module/     the installable KernelSU / APatch / Magisk module (scripts, WebUI, config, installer)
patches/    the patch set applied on top of upstream Dropbear (the only changes to the SSH server)
src/        where CI unpacks upstream Dropbear to build (not committed)
scripts/    build and maintenance helpers
.github/    CI workflows and issue/PR templates
docs/       documentation (mirrored to the wiki)
```

## Sestavení

Binárku produkuje CI z **upstreamového [mkj/dropbear](https://github.com/mkj/dropbear)** plus záplat
v `patches/`. Pro lokální sestavení potřebuješ Android NDK:

```sh
scripts/build.sh            # fetches the tracked upstream, applies patches, builds arm64 + arm32
```

Sada záplat je záměrně minimální a auditovatelná: neutrální/konfigurovatelný identifikační řetězec,
konfigurací řízené cesty pro `authorized_keys` a soubor s heslem, oprava `openpty` pro Android
a běhová konfigurace. Nové záplaty prosím udržuj malé, zdokumentované a v PR zdůvodněné.

## Pull requesty

- Jedna logická změna na jeden PR; popiš motivaci a bezpečnostní dopad.
- Drž se stávajícího stylu shellu (POSIX `sh` / Android `mksh`; žádné bashismy).
- Každý soubor nese krátkou hlavičku SPDX - zachovej ji.
- Aktualizuj [`CHANGELOG.md`](../../CHANGELOG.md) pod `[Unreleased]` u každé reálné změny viditelné pro uživatele.
- Odesláním PR souhlasíš s licencováním svého příspěvku pod licencí projektu [Apache-2.0](../../LICENSE).

## Překlady

README a dokumentace se udržují v mnoha jazycích (`README.<lang>.md`). Zdrojem pravdy je angličtina;
překlady ji následují. Pokud vylepšíš překlad nebo přidáš jazyk, zachovej strukturu a kotvy sekcí
shodné s anglickou verzí.

## Hlášení chyb a bezpečnostních problémů

Pro chyby a žádosti o funkce použij šablony issue. U čehokoli, co by mohlo ohrozit zařízení, se řiď
souborem [`SECURITY.md`](SECURITY.md) a nahlas to soukromě místo otevření veřejného issue.
