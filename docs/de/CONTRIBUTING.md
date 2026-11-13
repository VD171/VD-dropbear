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

> **Languages:** [English](../../CONTRIBUTING.md) · [العربية](../ar/CONTRIBUTING.md) · [Čeština](../cs/CONTRIBUTING.md) · Deutsch · [Español](../es/CONTRIBUTING.md) · [فارسی](../fa/CONTRIBUTING.md) · [Français](../fr/CONTRIBUTING.md) · [हिन्दी](../hi/CONTRIBUTING.md) · [Bahasa Indonesia](../in/CONTRIBUTING.md) · [Italiano](../it/CONTRIBUTING.md) · [日本語](../ja/CONTRIBUTING.md) · [한국어](../ko/CONTRIBUTING.md) · [Nederlands](../nl/CONTRIBUTING.md) · [Polski](../pl/CONTRIBUTING.md) · [Português](../pt/CONTRIBUTING.md) · [Русский](../ru/CONTRIBUTING.md) · [Svenska](../sv/CONTRIBUTING.md) · [ไทย](../th/CONTRIBUTING.md) · [Türkçe](../tr/CONTRIBUTING.md) · [Українська](../uk/CONTRIBUTING.md) · [Tiếng Việt](../vi/CONTRIBUTING.md) · [中文](../zh/CONTRIBUTING.md)

---

# Zu VD Dropbear beitragen

Danke für dein Interesse. Dies ist ein kleines, sicherheitssensibles Projekt (es vergibt Root), daher
werden Änderungen mit diesem Hintergrund geprüft.

## Aufbau des Repositorys

```
module/     the installable KernelSU / APatch / Magisk module (scripts, WebUI, config, installer)
patches/    the patch set applied on top of upstream Dropbear (the only changes to the SSH server)
src/        where CI unpacks upstream Dropbear to build (not committed)
scripts/    build and maintenance helpers
.github/    CI workflows and issue/PR templates
docs/       documentation (mirrored to the wiki)
```

## Bauen

Die Binärdatei wird von der CI aus dem **Upstream-[mkj/dropbear](https://github.com/mkj/dropbear)**
plus den Patches in `patches/` erzeugt. Zum lokalen Bauen brauchst du das Android NDK:

```sh
scripts/build.sh            # fetches the tracked upstream, applies patches, builds arm64 + arm32
```

Der Patch-Satz ist bewusst minimal und prüfbar: eine neutrale/konfigurierbare
Identitätszeichenfolge, konfigurationsgesteuerte Pfade für `authorized_keys` und die Passwortdatei,
der Android-`openpty`-Fix und Laufzeitkonfiguration. Bitte halte neue Patches klein, dokumentiert und
im PR begründet.

## Pull Requests

- Eine logische Änderung pro PR; beschreibe die Motivation und die Sicherheitsauswirkung.
- Halte dich an den bestehenden Shell-Stil (POSIX `sh` / Android `mksh`; keine Bashismen).
- Jede Datei trägt einen kurzen SPDX-Header - behalte ihn bei.
- Aktualisiere [`CHANGELOG.md`](../../CHANGELOG.md) unter `[Unreleased]` bei jeder echten, für Nutzer sichtbaren Änderung.
- Mit dem Einreichen eines PR stimmst du zu, deinen Beitrag unter der [Apache-2.0](../../LICENSE)-Lizenz des Projekts zu lizenzieren.

## Übersetzungen

README und Dokumentation werden in vielen Sprachen gepflegt (`README.<lang>.md`). Englisch ist die
maßgebliche Quelle; Übersetzungen folgen ihr. Wenn du eine Übersetzung verbesserst oder eine Sprache
hinzufügst, halte Struktur und Abschnittsanker identisch zur englischen Version.

## Fehler und Sicherheitsprobleme melden

Nutze für Fehler und Funktionswünsche die Issue-Vorlagen. Für alles, was ein Gerät gefährden könnte,
folge [`SECURITY.md`](SECURITY.md) und melde es privat, statt ein öffentliches Issue zu öffnen.
