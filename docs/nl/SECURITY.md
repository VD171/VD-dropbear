<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk - no invasive ADB exposure.
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

> **Languages:** [English](../../SECURITY.md) · [العربية](../ar/SECURITY.md) · [Čeština](../cs/SECURITY.md) · [Deutsch](../de/SECURITY.md) · [Español](../es/SECURITY.md) · [فارسی](../fa/SECURITY.md) · [Français](../fr/SECURITY.md) · [हिन्दी](../hi/SECURITY.md) · [Bahasa Indonesia](../in/SECURITY.md) · [Italiano](../it/SECURITY.md) · [日本語](../ja/SECURITY.md) · [한국어](../ko/SECURITY.md) · Nederlands · [Polski](../pl/SECURITY.md) · [Português](../pt/SECURITY.md) · [Русский](../ru/SECURITY.md) · [Svenska](../sv/SECURITY.md) · [ไทย](../th/SECURITY.md) · [Türkçe](../tr/SECURITY.md) · [Українська](../uk/SECURITY.md) · [Tiếng Việt](../vi/SECURITY.md) · [中文](../zh/SECURITY.md)

---

# Beveiligingsbeleid

## Het enige dat je moet begrijpen

VD Dropbear start een SSH-server, en **elke verbinding die zich met succes authenticeert, krijgt een root-shell**. De beveiliging van je toestel is daarom gelijk aan de beveiliging van de configuratie en inloggegevens van deze server. Daarom:

- **Geef de voorkeur aan publieke sleutels boven wachtwoorden.** Wachtwoordlogin staat standaard uit.
- Als je toch een wachtwoord moet gebruiken, kies dan een sterk wachtwoord - de WebUI dwingt een minimum af en slaat alleen een hash op.
- **Stel de poort niet bloot aan het openbare internet.** Bind aan loopback of een vertrouwd LAN, of bereik die via een VPN / tunnel.
- Begrijp de **BFU-afweging**: starten-voor-ontgrendeling inschakelen plaatst de hostsleutel en inloggegevens op device-encrypted opslag, leesbaar voordat het toestel ontgrendeld is. Laat het uit tenzij je SSH vóór ontgrendeling nodig hebt.
- Houd forwarding uit tenzij je het nodig hebt (het staat standaard uit).

## Wat VD Dropbear doet om te helpen

- Een neutrale, nietszeggende versiebanner zodat netwerkscanners de exacte server en versie niet kunnen fingerprinten.
- Inloggegevens standaard op credential-encrypted opslag (pas ontsleuteld nadat je ontgrendelt).
- Geen telemetrie, geen eigen netwerkverkeer, geen analytics. Het draait volledig op je toestel.

## Ondersteunde versies

Beveiligingsfixes landen op de nieuwste release. De serverbinary volgt upstream Dropbear; upstream beveiligingsreleases worden herbouwd en uitgeleverd zodra de CI ze oppikt.

## Een kwetsbaarheid melden

Meld beveiligingsproblemen privé, niet in een openbare issue:

- **E-mail:** vd.priv8@pm.me
- **Telegram:** [@VD_Priv8](https://t.me/VD_Priv8)

Vermeld de versie, een beschrijving, en (idealiter) een reproductie. Je krijgt een ontvangstbevestiging, en we stemmen een fix en een openbaarmakingstijdlijn met je af. Voor kwetsbaarheden in Dropbear zelf, meld die ook upstream op <https://matt.ucc.asn.au/dropbear/>.
