<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk - no invasive ADB exposure.
   User guide.

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

> **Languages:** [English](../USER-GUIDE.md) · [العربية](../ar/USER-GUIDE.md) · [Čeština](../cs/USER-GUIDE.md) · [Deutsch](../de/USER-GUIDE.md) · [Español](../es/USER-GUIDE.md) · [فارسی](../fa/USER-GUIDE.md) · [Français](../fr/USER-GUIDE.md) · [हिन्दी](../hi/USER-GUIDE.md) · [Bahasa Indonesia](../in/USER-GUIDE.md) · [Italiano](../it/USER-GUIDE.md) · [日本語](../ja/USER-GUIDE.md) · [한국어](../ko/USER-GUIDE.md) · Nederlands · [Polski](../pl/USER-GUIDE.md) · [Português](../pt/USER-GUIDE.md) · [Русский](../ru/USER-GUIDE.md) · [Svenska](../sv/USER-GUIDE.md) · [ไทย](../th/USER-GUIDE.md) · [Türkçe](../tr/USER-GUIDE.md) · [Українська](../uk/USER-GUIDE.md) · [Tiếng Việt](../vi/USER-GUIDE.md) · [中文](../zh/USER-GUIDE.md)

---

# Gebruikershandleiding

VD Dropbear geeft je geroote toestel een private SSH-server. Deze handleiding neemt je mee van installatie tot een werkende verbinding, inclusief bestandsoverdracht en de before-first-unlock (BFU) modus.

> **Elke geauthenticeerde verbinding krijgt een root-shell.** Geef de voorkeur aan sleutels boven wachtwoorden, bind alleen aan netwerken die je vertrouwt, en stel de poort nooit zonder reden bloot aan het open internet.

## 1. Installeren

Flash de module-zip in de **KernelSU**-, **APatch**- of **Magisk**-manager (of vanuit een shell met `ksud module install` / `apd module install`), en open dan de **WebUI** van de module.

## 2. Een sleutel toevoegen (aanbevolen)

Plak in de WebUI, onder **Authorized keys**, je publieke sleutel (`ssh-ed25519 AAAA... you@host`) en druk op **Add key**. Sleutels zijn de standaard en de veiligste manier naar binnen.

Om op je computer een sleutel te genereren, als je er nog geen hebt:

```sh
ssh-keygen -t ed25519 -C "you@host"
cat ~/.ssh/id_ed25519.pub     # paste this into the WebUI
```

## 3. Of stel een wachtwoord in

Wachtwoordlogin staat standaard uit (elke login is root, dus sleutels verdienen de voorkeur). Om het aan te zetten, zet **Password login** aan in de instellingen, en stel dan onder **Password accounts** een wachtwoord in voor de logingebruiker. De hash wordt in je browser berekend met PBKDF2; het wachtwoord zelf verlaat de pagina nooit.

## 4. Kies een poort en waar te luisteren

Stel onder **Settings** de **Port** in en kies de binds. Standaard luistert VD Dropbear alleen op **loopback**; om het vanaf je LAN of een VPN te bereiken, schakel de interfaces in die je wilt. Vermijd **Listen on all interfaces** tenzij je de blootstelling begrijpt.

Druk op **Save & restart** om toe te passen, en dan op **Start** als het nog niet draait.

## 5. Verbinden

```sh
ssh -p 2222 root@<device-ip>
sftp -P 2222 root@<device-ip>
scp -P 2222 file root@<device-ip>:/sdcard/
rsync -e 'ssh -p 2222' -av ./dir/ root@<device-ip>:/sdcard/dir/
```

`sftp-server`, `scp` en `rsync` zijn meegeleverd, zodat SFTP, `sshfs`, GUI-clients en back-ups allemaal over dezelfde verbinding werken.

## 6. Before first unlock (BFU)

Standaard start de daemon pas **nadat** je het toestel één keer ontgrendelt (AFU), omdat de geheimen op credential-encrypted opslag staan. Als je SSH **voor** de eerste ontgrendeling nodig hebt - bijvoorbeeld om een toestel na een herstart op afstand te ontgrendelen - zet dan **Start before first unlock (BFU)** aan. De geheimen verhuizen dan naar device-encrypted opslag, die leesbaar is vóór ontgrendeling: een bewuste, gedocumenteerde afweging. Zie [Security model](#) in de README.

## 7. De daemon besturen

- **WebUI:** Start / Stop / Restart, en live status (draait, PID, poort, modus, vingerafdruk van de hostsleutel).
- **Action-knop van de manager:** (her)start de daemon.
- Die start ook automatisch bij het opstarten (tenzij je het uitschakelt).

## Problemen oplossen

- **Het start niet.** Controleer `/data/adb/vddropbear/state/daemon.log`. Zorg dat **Enabled** aan staat en dat er een hostsleutel gegenereerd kon worden.
- **Sleutel geweigerd.** Bevestig dat de regel met de publieke sleutel exact is zoals je client die aanbiedt, en dat de logingebruiker er een is die het systeem herkent (meestal `root`).
- **Kan niet verbinden vanaf een andere machine.** Je bent waarschijnlijk nog alleen aan loopback gebonden - schakel de interface in die je nodig hebt en herstart.
- **SFTP/scp mislukt maar de shell werkt.** Zorg dat de meegeleverde `sftp-server` voor jouw ABI is uitgeleverd; de WebUI-status toont de gedetecteerde ABI.
