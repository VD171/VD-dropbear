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

> **Languages:** [English](../ARCHITECTURE.md) · [العربية](../ar/ARCHITECTURE.md) · [Čeština](../cs/ARCHITECTURE.md) · Deutsch · [Español](../es/ARCHITECTURE.md) · [فارسی](../fa/ARCHITECTURE.md) · [Français](../fr/ARCHITECTURE.md) · [हिन्दी](../hi/ARCHITECTURE.md) · [Bahasa Indonesia](../in/ARCHITECTURE.md) · [Italiano](../it/ARCHITECTURE.md) · [日本語](../ja/ARCHITECTURE.md) · [한국어](../ko/ARCHITECTURE.md) · [Nederlands](../nl/ARCHITECTURE.md) · [Polski](../pl/ARCHITECTURE.md) · [Português](../pt/ARCHITECTURE.md) · [Русский](../ru/ARCHITECTURE.md) · [Svenska](../sv/ARCHITECTURE.md) · [ไทย](../th/ARCHITECTURE.md) · [Türkçe](../tr/ARCHITECTURE.md) · [Українська](../uk/ARCHITECTURE.md) · [Tiếng Việt](../vi/ARCHITECTURE.md) · [中文](../zh/ARCHITECTURE.md)

---

# Architektur

VD Dropbear ist ein Modul für KernelSU / APatch / Magisk, das genau einen Dropbear-SSH-Daemon
betreibt, vollständig durch Konfiguration gesteuert. Nichts am SSH-Server ist fest auf ein Gerät
verdrahtet; alles Spezifische ist Laufzeitkonfiguration oder ein Geheimnis.

## Bestandteile

- `module/common/vddropbear.sh` - die Kernbibliothek: Konfiguration laden (mit sicheren eingebauten
  Standardwerten), den Geheimnisspeicher auflösen, einen Host-Schlüssel sicherstellen, den
  Argumentvektor für Dropbear bauen und eine einzelne Daemon-Instanz verwalten (Start / Stopp /
  Status / Neustart).
- `module/service.sh` - Einstiegspunkt beim Booten. Befolgt die BFU/AFU-Startrichtlinie; im
  AFU-Modus wartet er darauf, dass der mit Zugangsdaten verschlüsselte Speicher entsperrt wird, ohne
  den Bootvorgang aufzuhalten.
- `module/action.sh` - die **Action**-Schaltfläche des Managers: den Daemon (neu) starten. Er liest
  nie stdin und löst den Daemon in eine eigene Sitzung ab, sodass der Manager nicht hängen bleibt.
- `module/common/vddb-webui.sh` + `module/webroot/index.html` - das WebUI-Backend und die Seite.
- `patches/` - kleine, prüfbare Patches, die zur Buildzeit auf das Upstream-Dropbear angewendet werden.
- `scripts/build.sh`, `scripts/build-bundles.sh`, `.github/workflows/build.yml` - der Build.

## Daemon-Lebenszyklus (eine einzige Instanz)

`vddb_start` lädt die Konfiguration, stoppt jede laufende Instanz, stellt sicher, dass ein
Host-Schlüssel existiert, und startet dann einen Daemon. Die Binärdatei wird als `vddropbear`
ausgeliefert, sodass ihr Prozessname genau zu `pgrep -x` passt (Androids `mksh` kennt kein
`exec -a`). Sie wird mit `setsid` gestartet, damit sie sich von der Prozessgruppe des Aufrufers löst -
genau das verhindert, dass die Action des Managers blockiert.

## Der Geheimnisspeicher (CE vs. DE, BFU vs. AFU)

Einstellungen sind nicht geheim und liegen auf gerätverschlüsseltem Speicher
(`/data/adb/vddropbear`), der beim Booten lesbar ist. Geheimnisse - Host-Schlüssel,
`authorized_keys`, Passwort-Hashes - liegen standardmäßig auf **mit Zugangsdaten verschlüsseltem**
Speicher (`/data/misc_ce/0/vddropbear`), der erst nach der Authentifizierung des Nutzers entsperrt
wird. Das Einschalten von `START_IN_BFU` verschiebt die Geheimnisse auf gerätverschlüsselten
Speicher, damit der Daemon vor der ersten Entsperrung laufen kann, um den Preis, dass diese
Geheimnisse früher lesbar sind. Das Modul berechnet bei jeder Boot-Phase, welcher Speicher zu
verwenden ist.

## Der Patch-Satz

Der SSH-Server bleibt Upstream-Dropbear; unsere Änderungen sind einige wenige überprüfbare Patches
(siehe [patches/README.md](../../patches/README.md)):

- ein neutraler, zur Laufzeit konfigurierbarer Identitäts-Banner;
- `authorized_keys` wird aus einem per Umgebung gesetzten Pfad gelesen (damit die Schlüssel im
  Geheimnisspeicher liegen);
- Passwort-Authentifizierung gegen eine PBKDF2-Hash-Datei statt gegen das systemeigene
  `crypt()`/shadow, das Android fehlt (siehe [BUILDING.md](../BUILDING.md)).

## Die WebUI

Eine statische Seite in der WebUI des Managers (KernelSU / APatch / WebUI-X). Sie steuert
`module/common/vddb-webui.sh` über die `ksu.exec`-Brücke: Status, Start/Stopp/Neustart,
Konfiguration lesen/schreiben sowie Verwaltung von Schlüsseln und Passwortkonten. Alle Daten
überqueren die Brücke base64-codiert, sodass die Shell sie nie interpretiert; Passwort-Hashes werden
im Browser mit WebCrypto berechnet, sodass das Klartext-Passwort die Seite nie verlässt.
