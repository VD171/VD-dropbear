<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk - no invasive ADB exposure.

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

<p align="center">
  <img src="module/webroot/assets/logo-wordmark.svg" alt="VD Dropbear" width="540">
</p>

# VD Dropbear

<p>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-Apache--2.0-1a7f37" alt="License"></a>
  <img src="https://img.shields.io/badge/KernelSU-%E2%9C%94-635bff" alt="KernelSU">
  <img src="https://img.shields.io/badge/APatch-%E2%9C%94-ff7043" alt="APatch">
  <img src="https://img.shields.io/badge/Magisk-%E2%9C%94-00af9c" alt="Magisk">
  <a href="https://github.com/VD171/VD-dropbear/stargazers"><img src="https://img.shields.io/github/stars/VD171/VD-dropbear?color=d29922" alt="Stars"></a>
  <a href="https://github.com/VD171/VD-dropbear/releases"><img src="https://img.shields.io/github/v/release/VD171/VD-dropbear?color=1a7f37" alt="Release"></a>
</p>

**Ein eigenständiger, voll konfigurierbarer SSH-Server auf Basis von [Dropbear](https://matt.ucc.asn.au/dropbear/)**,
verpackt als Modul für KernelSU / APatch / Magisk. Er startet von allein und hängt von keinem anderen Modul ab.

> ⚠️ **Jede Verbindung, die sich authentifiziert, erhält eine ROOT-Shell.** Behandle das wie die
> Schlüssel zum Gerät: Bevorzuge öffentliche Schlüssel gegenüber Passwörtern und halte den Port vom
> öffentlichen Internet fern.

Languages: English · [العربية](README.ar.md) · [Čeština](README.cs.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [فارسی](README.fa.md) · [Français](README.fr.md) · [हिन्दी](README.hi.md) · [Bahasa](README.in.md) · [Italiano](README.it.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Nederlands](README.nl.md) · [Polski](README.pl.md) · [Português](README.pt.md) · [Русский](README.ru.md) · [Svenska](README.sv.md) · [ไทย](README.th.md) · [Türkçe](README.tr.md) · [Українська](README.uk.md) · [Tiếng Việt](README.vi.md) · [中文](README.zh.md)

## Warum

Androids eingebauter Weg, eine Shell auf dem eigenen Telefon zu bekommen, ist ADB (USB-Debugging),
und es einzuschalten ist invasiv und verrät dich selbst. `adb_enabled` und
`development_settings_enabled` sind von jedem lesbare Einstellungen - jede App, jedes SDK oder jede
Betrugs- bzw. RASP-Bibliothek kann sie auslesen, die Verbindung wird protokolliert, und es gibt keinen
unterstützten Weg zu verbergen, dass ADB aktiviert ist oder je war. Diese Preisgabe verfolgt dich
sogar auf einem werkseitigen, nicht gerooteten Telefon: Um eine Shell zu bekommen, musst du es
ankündigen.

VD Dropbear ist die private Alternative. Auf einem gerooteten Gerät gibt es dir einen echten
SSH-Server - Root-Shell, SFTP und rsync über das Netzwerk - ohne verräterisches `adb_enabled`, ohne
USB-Debugging-Flag, mit einem Versionsbanner, das nichts preisgibt, und mit Anmeldedaten, die du
kontrollierst. Dein Zugang bleibt deiner, statt eines global lesbaren „Ich werde debuggt"-Flags, das
alles auf dem Gerät auslesen kann.

## Funktionen

- **Ein Daemon, immer.** Er startet beim Booten und über die Schaltfläche **Action** des Managers, und
  du kannst ihn jederzeit über die WebUI **starten / stoppen / neu starten**; nie mehr als eine
  Instanz.
- **Alles ist konfigurierbar** über die WebUI (oder `/data/adb/vddropbear/config`):
  - Port sowie Bindung an loopback / alle / IPv4 / IPv6 / bestimmte Adressen
  - **Start vor der ersten Entsperrung (BFU) oder erst danach (AFU)** - ein einziger Schalter
  - Authentifizierung per Public Key und/oder Passwort, maximale Anzahl Authentifizierungsversuche
  - Login-Benutzer, Shell, `HOME`, zusätzliche Umgebung
  - Leerlauf-Timeout, Keepalive, Empfangsfenster
  - lokale / entfernte Portweiterleitung und Gateway-Ports (standardmäßig alle **aus**)
  - Typ des Host-Schlüssels (ed25519 / rsa / ecdsa)
- **Verstecktes Versionsbanner.** Das SSH-Protokoll verlangt *ein* Banner, es lässt sich also nicht
  entfernen, aber VD Dropbear ersetzt es durch ein nichtssagendes, damit Scanner den genauen Server
  oder die genaue Version nicht per Fingerprint bestimmen und keine auf diese Version gemünzten
  Angriffe darauf richten können.
- **Geheimnisse sinnvoll gespeichert** (siehe [Sicherheitsmodell](#security-model)).
- **Bring deine eigenen Anmeldedaten mit.** Füge Sätze aus `user + key` und `user + password` hinzu;
  die WebUI erzwingt eine Mindest-Passwortstärke und speichert ein Passwort nie im Klartext.
- **Dateiübertragung und Synchronisierung eingebaut.** Das Paket liefert `sftp-server`, `scp` und
  `rsync` mit, sodass SFTP, sshfs, GUI-Clients und Backups alle über dieselbe Verbindung laufen.
- **Jedes Gerät und jeder Emulator.** `arm64-v8a`, `armeabi-v7a`, `x86`, `x86_64`.

## KI-Agenten auf deinem Gerät

Ein dauerhafter SSH-Endpunkt verwandelt dein Telefon in etwas, das ein **autonomer KI-Agent direkt
bedienen kann**. Jeder Agent, der eine Shell oder eine SSH-Verbindung steuern kann - Claude Code,
aider, ein Skript mit LLM in der Schleife, deine eigene Automatisierung - bekommt eine echte
Root-Sitzung auf dem Gerät, über das Netzwerk, ohne USB-Kabel und ohne eines der verräterischen
Debug-Flags von ADB. Der Agent sieht eine normale, Linux-ähnliche Shell und kann:

- Dateien lesen und bearbeiten, Einstellungen umschalten sowie Module, Pakete und Dienste verwalten;
- Logs sichten, Artefakte abrufen und auf Abruf Diagnosen oder Forensik ausführen;
- Dateien in beide Richtungen über `scp` / `sftp` / `rsync` verschieben und synchronisieren, für Backups, Migrationen oder Provisionierung;
- eine ganze Flotte gerooteter Geräte von einem Ort aus steuern, jedes über seinen eigenen Schlüssel erreichbar.

Weil das Projekt **KI-freundlich** aufgebaut ist - eine dokumentierte Konfigurationsdatei, ein
expliziter [Umgebungs-Vertrag](patches/README.md) zur Laufzeit, vorhersehbare Pfade und Status im
Klartext - kann ein Agent ohne Rätselraten herausfinden, wie er es benutzt.

> **Das ist Root, also behandle es wie Root.** Jede authentifizierte Verbindung landet als Root (siehe
> Warnung unten). Wenn du einem Agenten Zugang gibst, gib ihm einen **eigenen Benutzer und Schlüssel**,
> beschränke die Bindungen auf Netzwerke, denen du vertraust (loopback oder ein VPN statt des offenen
> Internets), lass die Passwort-Authentifizierung aus und denke daran, dass du einen Schlüssel jederzeit
> widerrufen oder den Daemon über die WebUI stoppen kannst.

## Installation

Flashe die Modul-Zip im KernelSU-, APatch- oder Magisk-Manager (oder über die Kommandozeile mit
`ksud module install` / `apd module install`), öffne die **WebUI** des Moduls, um den Port zu setzen
und deine Schlüssel hinzuzufügen, und starte dann neu (oder drücke **Action**, um ihn jetzt zu
starten).

## Sicherheitsmodell

### Wo Geheimnisse liegen: BFU vs. AFU

`/data/adb` ist **geräteverschlüsselter (DE)** Speicher: Er wird entschlüsselt, *bevor* der Nutzer das
Telefon entsperrt (Before First Unlock), alles dort ist also vor der Entsperrung lesbar.
`/data/misc_ce` ist **anmeldedatenverschlüsselt (CE)**: Android hält ihn verschlüsselt, bis der Nutzer
entsperrt (After First Unlock).

- **AFU-Modus (Standard, `START_IN_BFU=0`):** Der Daemon wartet auf die Entsperrung und liest seinen
  Host-Schlüssel, `authorized_keys` und die Passwort-Hashes aus dem CE-Speicher. Maximaler Schutz; SSH
  funktioniert erst, nachdem das Gerät seit dem Booten einmal entsperrt wurde.
- **BFU-Modus (`START_IN_BFU=1`):** Der Daemon startet vor der Entsperrung, damit du dich früh per SSH
  einwählen kannst (zum Beispiel, um das Gerät aus der Ferne zu entsperren). Seine Geheimnisse liegen
  dann im DE-Speicher und sind vor der Entsperrung lesbar - ein bewusster und dokumentierter
  Kompromiss. Aktiviere ihn nur, wenn du SSH vor der Entsperrung brauchst.

Wir fügen bewusst **keine** eigene Verschlüsselung über CE hinzu: Es ist bereits mit den Anmeldedaten
des Nutzers verschlüsselt, und eine weitere Chiffre darüberzulegen bräuchte einen Schlüssel, der
irgendwo liegen muss (im DE-Speicher wäre er offengelegt; ihn aus den Anmeldedaten des Nutzers
abzuleiten implementiert nur CE erneut). Das würde ein falsches Sicherheitsgefühl bringen, keinen
echten Schutz.

### Passwörter

Die Passwort-Anmeldung ist **standardmäßig aus**, weil jede Anmeldung Root ist und Schlüssel weit
sicherer sind. Wenn du doch ein Passwort setzt, erzwingt die WebUI eine Mindeststärke und speichert nur
einen Hash, nie Klartext.

## Build

Die Server-Binärdatei wird per CI aus dem **Upstream [mkj/dropbear](https://github.com/mkj/dropbear)**
gebaut, mit einem kleinen, prüfbaren Patch-Satz (siehe [`patches/`](patches/)): einer
neutralen/konfigurierbaren Identitätszeichenfolge, konfigurationsgesteuerten Pfaden für
`authorized_keys` und die Passwortdatei sowie dem Android-`openpty`-Fix für interaktive PTYs. Ein
geplanter Workflow verfolgt den Upstream und baut neu, sodass das Modul aktuell bleibt. Siehe
[`.github/workflows/`](.github/workflows/) und [`CONTRIBUTING.md`](CONTRIBUTING.md).

## Dokumentation

<!-- vd-docs -->
Die vollständige Dokumentation liegt im [Wiki](https://github.com/VD171/VD-dropbear/wiki) und unter
[`docs/`](docs/).
<!-- /vd-docs -->

## Siehe auch

Verwandte Projekte desselben Autors:

- **[VDInfos](https://github.com/VD171/VD-Infos)**: ein Methoden-Debugger fürs Gerät, der jeden Punkt über jede Methode liest, die ihn lesen kann, und sie nebeneinander vergleicht.
- **[VDGoogle](https://github.com/VD171/VD-Google)**: deine Google-Dienste (RCS, Wallet, Play-Integrity-Attestierungen), auf deinem Gerät und ohne Internet gelesen.
- **[VDBackup](https://github.com/VD171/VD-Backup)**: vollständiges Backup und Wiederherstellen von Apps und Daten als Root, komplett über eine WebUI gesteuert.
- **[COPG-VD](https://github.com/VD171/COPG-VD)**: ein globaler Spoofer für Geräte-Fingerprint und Build.

## Kontakte

* https://vd171.ru
* https://vd.priv8.ru
* **Telegram:** @VD_Priv8 https://t.me/VD_Priv8
* **Channel:** @Priv8_VD https://t.me/Priv8_VD
* **Discord:** @VD.Priv8 https://discord.com/users/1296831918989639721
* **E-mail:** vd.priv8@pm.me
* **XDA-Developers:** @VD171 https://xdaforums.com/m/vd171.4699873/
* **XDA thread:** _(Platzhalter - wird bei der ersten öffentlichen Veröffentlichung ergänzt)_
* **GitHub:** @VD171 https://github.com/VD171

## Lizenz

Der eigene Code von VD Dropbear steht unter **Apache-2.0** - siehe [LICENSE](LICENSE). Das Modul bündelt
außerdem Binärdateien von Drittanbietern - [Dropbear](https://matt.ucc.asn.au/dropbear/) (MIT-artig),
OpenSSHs `sftp-server` und `scp` (BSD) und `rsync` (GPL-3.0) - jede unter ihrer eigenen Lizenz; siehe
[THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md), einschließlich der Art, wie wir für rsync die GPL
einhalten. Unser Apache-2.0-Code ist davon unberührt (die GPL-Binärdatei ist lediglich aggregiert, nicht
gelinkt).

## Marken

VD Dropbear ist ein unabhängiges, inoffizielles Projekt, weder mit Dritten verbunden noch von ihnen
unterstützt. „Android" ist eine Marke von Google LLC; „SSH" ist eine eingetragene Marke von SSH
Communications Security. VD Dropbear läuft vollständig auf deinem Gerät.

## Tags

`SSH` `Dropbear` `KernelSU` `Magisk` `APatch` `root` `sshd` `remote-access` `openssh-alternative` `Android` `BFU` `VD-dropbear`
