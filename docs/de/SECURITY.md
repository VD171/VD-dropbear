<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk. No invasive ADB exposure.
   Security policy.

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

> **Languages:** [English](../../SECURITY.md) · [العربية](../ar/SECURITY.md) · [Čeština](../cs/SECURITY.md) · Deutsch · [Español](../es/SECURITY.md) · [فارسی](../fa/SECURITY.md) · [Français](../fr/SECURITY.md) · [हिन्दी](../hi/SECURITY.md) · [Bahasa Indonesia](../in/SECURITY.md) · [Italiano](../it/SECURITY.md) · [日本語](../ja/SECURITY.md) · [한국어](../ko/SECURITY.md) · [Nederlands](../nl/SECURITY.md) · [Polski](../pl/SECURITY.md) · [Português](../pt/SECURITY.md) · [Русский](../ru/SECURITY.md) · [Svenska](../sv/SECURITY.md) · [ไทย](../th/SECURITY.md) · [Türkçe](../tr/SECURITY.md) · [Українська](../uk/SECURITY.md) · [Tiếng Việt](../vi/SECURITY.md) · [中文](../zh/SECURITY.md)

---

# Sicherheitsrichtlinie

## Das Eine, das man verstehen muss

VD Dropbear startet einen SSH-Server, und **jede Verbindung, die sich erfolgreich authentifiziert,
erhält eine Root-Shell**. Die Sicherheit deines Geräts entspricht daher der Sicherheit der
Konfiguration und der Zugangsdaten dieses Servers. Bitte:

- **Bevorzuge öffentliche Schlüssel gegenüber Passwörtern.** Die Passwortanmeldung ist standardmäßig aus.
- Wenn du ein Passwort verwenden musst, nimm ein starkes. Die WebUI erzwingt ein Minimum und
  speichert nur einen Hash.
- **Gib den Port nicht ins öffentliche Internet frei.** Binde an Loopback oder ein vertrauenswürdiges
  LAN, oder erreiche ihn über ein VPN / einen Tunnel.
- Verstehe den **BFU-Kompromiss**: Das Aktivieren von Start-vor-Entsperrung legt den Host-Schlüssel
  und die Zugangsdaten auf gerätverschlüsselten Speicher, lesbar bevor das Gerät entsperrt ist. Lass
  es aus, es sei denn, du brauchst SSH vor der Entsperrung.
- Lass die Weiterleitung aus, solange du sie nicht brauchst (sie ist standardmäßig aus).

## Was VD Dropbear zur Hilfe tut

- Ein neutraler, nichtssagender Versions-Banner, damit Netzwerkscanner den genauen Server und die
  Version nicht per Fingerprint erkennen können.
- Zugangsdaten standardmäßig auf mit Zugangsdaten verschlüsseltem Speicher (erst nach der
  Entsperrung entschlüsselt).
- Keine Telemetrie, keine eigenen Netzwerkaufrufe, keine Analytik. Es läuft vollständig auf deinem Gerät.

## Unterstützte Versionen

Sicherheitskorrekturen landen im neuesten Release. Die Server-Binärdatei folgt dem
Upstream-Dropbear; Upstream-Sicherheitsreleases werden neu gebaut und ausgeliefert, sobald die CI sie
aufgreift.

## Eine Schwachstelle melden

Bitte melde Sicherheitsprobleme privat, nicht in einem öffentlichen Issue:

- **E-Mail:** vd.priv8@pm.me
- **Telegram:** [@VD_Priv8](https://t.me/VD_Priv8)

Gib die Version, eine Beschreibung und (idealerweise) eine Reproduktion an. Du erhältst eine
Bestätigung, und wir stimmen mit dir eine Behebung und einen Zeitplan zur Offenlegung ab. Für
Schwachstellen in Dropbear selbst melde sie bitte auch beim Upstream unter
<https://matt.ucc.asn.au/dropbear/>.
