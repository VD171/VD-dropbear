<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk - no invasive ADB exposure.
   AI agents on your device.

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

> **Languages:** [English](../AI-AGENTS.md) · [العربية](../ar/AI-AGENTS.md) · [Čeština](../cs/AI-AGENTS.md) · Deutsch · [Español](../es/AI-AGENTS.md) · [فارسی](../fa/AI-AGENTS.md) · [Français](../fr/AI-AGENTS.md) · [हिन्दी](../hi/AI-AGENTS.md) · [Bahasa Indonesia](../in/AI-AGENTS.md) · [Italiano](../it/AI-AGENTS.md) · [日本語](../ja/AI-AGENTS.md) · [한국어](../ko/AI-AGENTS.md) · [Nederlands](../nl/AI-AGENTS.md) · [Polski](../pl/AI-AGENTS.md) · [Português](../pt/AI-AGENTS.md) · [Русский](../ru/AI-AGENTS.md) · [Svenska](../sv/AI-AGENTS.md) · [ไทย](../th/AI-AGENTS.md) · [Türkçe](../tr/AI-AGENTS.md) · [Українська](../uk/AI-AGENTS.md) · [Tiếng Việt](../vi/AI-AGENTS.md) · [中文](../zh/AI-AGENTS.md)

---

# KI-Agenten auf deinem Gerät

Ein ständig laufender SSH-Endpunkt macht dein Telefon zu etwas, das ein **autonomer KI-Agent direkt
bedienen kann**. Jeder Agent, der eine Shell oder eine SSH-Verbindung steuern kann - Claude Code,
aider, ein Skript mit einem LLM in der Schleife, deine eigene Automatisierung - erhält eine echte
Root-Sitzung auf dem Gerät, über das Netzwerk, ohne USB-Kabel und ohne die sich selbst verratenden
Debug-Flags von ADB.

Diese Seite vertieft die Idee, die in der README vorgestellt wird.

## Warum SSH statt ADB für Agenten

ADB macht sich bemerkbar: `adb_enabled` und `development_settings_enabled` sind für alle lesbar, die
Verbindung wird protokolliert, und es gibt keinen unterstützten Weg, zu verbergen, dass Debugging
aktiv ist (oder war). Ein Agent, der über ADB arbeitet, hinterlässt diese Spur auf dem Gerät, die
jede App oder jedes Anti-Betrugs-SDK auslesen kann. VD Dropbear ist die private Alternative - eine
normale SSH-Anmeldung, mit Zugangsdaten, die du kontrollierst, und einem Banner, das nichts verrät.

## Was ein Agent tun kann

Über eine einzige Verbindung sieht ein Agent eine normale Linux-artige Shell und kann:

- Dateien lesen und bearbeiten, Einstellungen umschalten sowie Module, Pakete und Dienste verwalten;
- Logs sichten, Artefakte abrufen und bei Bedarf Diagnosen oder Forensik ausführen;
- Dateien in beide Richtungen über `scp` / `sftp` / `rsync` verschieben und synchronisieren - Backups, Migrationen, Provisionierung;
- eine ganze Flotte gerooteter Geräte von einem Ort aus steuern, jedes über seinen eigenen Schlüssel erreichbar.

Weil das Projekt darauf ausgelegt ist, **KI-freundlich** zu sein - eine dokumentierte
Konfigurationsdatei, ein expliziter [Env-Vertrag](../../patches/README.md) zur Laufzeit,
vorhersehbare Pfade und Status im Klartext - kann ein Agent ohne Raten herausfinden, wie er es
benutzt.

## Sicher vorgehen

Das ist Root, also behandle es wie Root:

- gib dem Agenten einen **eigenen Benutzer und Schlüssel**, nicht deinen persönlichen;
- beschränke die Bindungen auf Netzwerke, denen du vertraust - Loopback oder ein VPN statt des
  offenen Internets (siehe [Konfiguration](CONFIGURATION.md));
- lass die Passwort-Authentifizierung aus; ein Schlüssel ist widerrufbar und wird nie eingetippt;
- du kannst einen Schlüssel jederzeit widerrufen oder den Daemon über die WebUI stoppen;
- denk daran, dass jede Verbindung eine vollständige Root-Sitzung ist - gib dem Agenten nur die Reichweite, die er braucht.

## Eine minimale Einrichtung

1. Erzeuge ein Schlüsselpaar nur für den Agenten.
2. Füge seinen öffentlichen Schlüssel in der WebUI hinzu (**Authorized keys**).
3. Binde nur an Loopback oder dein VPN, auf einem nicht standardmäßigen Port.
4. Richte die SSH-Konfiguration des Agenten auf das Gerät und lass ihn arbeiten.
