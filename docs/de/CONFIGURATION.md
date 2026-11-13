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

> **Languages:** [English](../CONFIGURATION.md) · [العربية](../ar/CONFIGURATION.md) · [Čeština](../cs/CONFIGURATION.md) · Deutsch · [Español](../es/CONFIGURATION.md) · [فارسی](../fa/CONFIGURATION.md) · [Français](../fr/CONFIGURATION.md) · [हिन्दी](../hi/CONFIGURATION.md) · [Bahasa Indonesia](../in/CONFIGURATION.md) · [Italiano](../it/CONFIGURATION.md) · [日本語](../ja/CONFIGURATION.md) · [한국어](../ko/CONFIGURATION.md) · [Nederlands](../nl/CONFIGURATION.md) · [Polski](../pl/CONFIGURATION.md) · [Português](../pt/CONFIGURATION.md) · [Русский](../ru/CONFIGURATION.md) · [Svenska](../sv/CONFIGURATION.md) · [ไทย](../th/CONFIGURATION.md) · [Türkçe](../tr/CONFIGURATION.md) · [Українська](../uk/CONFIGURATION.md) · [Tiếng Việt](../vi/CONFIGURATION.md) · [中文](../zh/CONFIGURATION.md)

---

# Konfiguration

Einstellungen liegen in `/data/adb/vddropbear/config` (beim ersten Booten aus
`module/common/config.default` befüllt). Die **WebUI** bearbeitet diese Datei für dich; du kannst sie
auch von Hand bearbeiten. Sie wird als Shell eingelesen, verwende also `KEY=value` ohne Leerzeichen um
`=`. Einstellungen sind nicht geheim und liegen auf gerätverschlüsseltem Speicher; Geheimnisse
(Host-Schlüssel, autorisierte Schlüssel, Passwort-Hashes) liegen im Geheimnisspeicher, nie hier.

Änderungen werden durch einen Neustart des Daemons wirksam (das **Save & restart** der WebUI erledigt
das).

## Allgemein

| Schlüssel | Standard | Bedeutung |
|-----|---------|---------|
| `ENABLED` | `1` | Den Daemon beim Booten starten. `0` deaktiviert ihn vollständig. |
| `START_IN_BFU` | `0` | `0`: erst nach der ersten Entsperrung starten (AFU); Geheimnisse bleiben auf mit Zugangsdaten verschlüsseltem (CE) Speicher. `1`: auch vor der ersten Entsperrung starten (BFU); Geheimnisse wandern auf gerätverschlüsselten (DE) Speicher, lesbar vor der Entsperrung. |
| `PORT` | `2222` | Standard-Lauschport (Ports einzelner Bindungen können ihn in `LISTEN_ADDRESSES` überschreiben). |

## Lauschen / Bindungen (kombinierbar)

Jede Kombination ist erlaubt; die ausgewählten Bindungen werden zusammengeführt. Wenn du alles
leerst, bindet VD Dropbear an Loopback statt an jede Schnittstelle.

| Schlüssel | Standard | Bedeutung |
|-----|---------|---------|
| `LISTEN_LOOPBACK` | `1` | Nur auf `127.0.0.1` / `::1` lauschen. |
| `LISTEN_ALL` | `0` | Auf jeder Schnittstelle lauschen (`0.0.0.0` / `::`) - macht das Gerät angreifbar. |
| `LISTEN_IPV4` | `1` | IPv4-Bindungen einbeziehen. |
| `LISTEN_IPV6` | `1` | IPv6-Bindungen einbeziehen. |
| `LISTEN_ADDRESSES` | `""` | Zusätzliche konkrete Bindungen, durch Kommas getrennt: `addr` (nutzt `PORT`) oder `addr:port`, IPv4 oder IPv6. |

## Identität

| Schlüssel | Standard | Bedeutung |
|-----|---------|---------|
| `HIDE_IDENT` | `1` | Einen neutralen SSH-Identitäts-Banner senden, damit Scanner Server/Version nicht genau per Fingerprint erkennen können. |
| `IDENT_STRING` | `""` | Eine benutzerdefinierte Identitätszeichenfolge. Leer nutzt den neutralen eingebauten Standard. |

## Authentifizierung

Jede authentifizierte Anmeldung ist **root**. Schlüssel sind der Standard; Passwörter sind optional.

| Schlüssel | Standard | Bedeutung |
|-----|---------|---------|
| `PUBKEY_AUTH` | `1` | Anmeldung per öffentlichem Schlüssel erlauben (liest die autorisierten Schlüssel im Geheimnisspeicher). |
| `PASSWORD_AUTH` | `0` | Anmeldung per Passwort erlauben. Wenn aus, wird der Daemon mit deaktivierter Passwort-Authentifizierung gestartet. |
| `MAX_AUTH_TRIES` | `3` | Maximale Anzahl an Authentifizierungsversuchen pro Verbindung. |

## Sitzung / Umgebung

| Schlüssel | Standard | Bedeutung |
|-----|---------|---------|
| `LOGIN_SHELL` | `""` | Shell für die Sitzung. Leer nutzt den Standard des Kontos. |
| `HOME_DIR` | `""` | `HOME` für die Sitzung. Leer nutzt das Modulverzeichnis. |
| `EXTRA_ENV` | `""` | Zusätzliche Umgebung, `K=V;K2=V2`. |
| `IDLE_TIMEOUT` | `0` | Nach N Leerlaufsekunden trennen. `0` deaktiviert. |
| `KEEPALIVE` | `0` | Alle N Sekunden ein Keepalive senden. `0` deaktiviert. |
| `RECEIVE_WINDOW` | `""` | Größe des Dropbear-Empfangsfensters. Leer nutzt den Standard. |

## Weiterleitung (standardmäßig aus)

| Schlüssel | Standard | Bedeutung |
|-----|---------|---------|
| `ALLOW_LOCAL_FORWARD` | `0` | Lokale (`-L`) Portweiterleitung erlauben. |
| `ALLOW_REMOTE_FORWARD` | `0` | Entfernte (`-R`) Portweiterleitung erlauben. |
| `GATEWAY_PORTS` | `0` | Weitergeleiteten entfernten Ports erlauben, an alle Schnittstellen zu binden. |

## Host-Schlüssel

| Schlüssel | Standard | Bedeutung |
|-----|---------|---------|
| `HOSTKEY_TYPE` | `ed25519` | Host-Schlüsseltyp: `ed25519`, `rsa` oder `ecdsa`. Wird beim ersten Start in den Geheimnisspeicher erzeugt. |

## Der Geheimnisspeicher

Wird nicht hier konfiguriert - wird aus `START_IN_BFU` abgeleitet:

- **AFU (Standard):** `/data/misc_ce/0/vddropbear/secret` - mit Zugangsdaten verschlüsselt, erst
  verfügbar, nachdem du das Gerät entsperrt hast.
- **BFU:** `/data/adb/vddropbear/secret` - gerätverschlüsselt, lesbar vor der ersten Entsperrung.

Er enthält den Host-Schlüssel, `authorized_keys` und die `passwd`-Hash-Datei. Zum Format des
Passwort-Hashes siehe [BUILDING.md](../BUILDING.md).
