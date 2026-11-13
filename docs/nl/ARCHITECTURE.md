<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk. No invasive ADB exposure.
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

> **Languages:** [English](../ARCHITECTURE.md) · [العربية](../ar/ARCHITECTURE.md) · [Čeština](../cs/ARCHITECTURE.md) · [Deutsch](../de/ARCHITECTURE.md) · [Español](../es/ARCHITECTURE.md) · [فارسی](../fa/ARCHITECTURE.md) · [Français](../fr/ARCHITECTURE.md) · [हिन्दी](../hi/ARCHITECTURE.md) · [Bahasa Indonesia](../in/ARCHITECTURE.md) · [Italiano](../it/ARCHITECTURE.md) · [日本語](../ja/ARCHITECTURE.md) · [한국어](../ko/ARCHITECTURE.md) · Nederlands · [Polski](../pl/ARCHITECTURE.md) · [Português](../pt/ARCHITECTURE.md) · [Русский](../ru/ARCHITECTURE.md) · [Svenska](../sv/ARCHITECTURE.md) · [ไทย](../th/ARCHITECTURE.md) · [Türkçe](../tr/ARCHITECTURE.md) · [Українська](../uk/ARCHITECTURE.md) · [Tiếng Việt](../vi/ARCHITECTURE.md) · [中文](../zh/ARCHITECTURE.md)

---

# Architectuur

VD Dropbear is een KernelSU / APatch / Magisk-module die precies één Dropbear SSH-daemon draait, volledig aangestuurd door configuratie. Niets aan de SSH-server is hardcoded op één toestel; alles wat specifiek is, is runtimeconfiguratie of een geheim.

## Onderdelen

- `module/common/vddropbear.sh`: de kernbibliotheek: config laden (met veilige ingebouwde standaardwaarden), de geheimenopslag bepalen, een hostsleutel verzekeren, de Dropbear-argumentvector opbouwen, en één enkele daemon-instantie beheren (start / stop / status / restart).
- `module/service.sh`: opstartingang. Respecteert het BFU/AFU-startbeleid; in AFU-modus wacht die op het ontgrendelen van credential-encrypted opslag zonder het opstarten op te houden.
- `module/action.sh`: de **Action**-knop van de manager: de daemon (opnieuw) starten. Die leest nooit stdin en maakt de daemon los in zijn eigen sessie, zodat de manager niet blijft hangen.
- `module/common/vddb-webui.sh` + `module/webroot/index.html`: de WebUI-backend en de pagina.
- `patches/`: kleine, controleerbare patches die bij het bouwen op upstream Dropbear worden toegepast.
- `scripts/build.sh`, `scripts/build-bundles.sh`, `.github/workflows/build.yml`: de build.

## Levenscyclus van de daemon (één instantie)

`vddb_start` laadt de config, stopt een eventueel draaiende instantie, verzekert dat er een hostsleutel bestaat, en start dan één daemon. De binary wordt geleverd als `vddropbear`, zodat de procesnaam precies overeenkomt met `pgrep -x` (Android `mksh` heeft geen `exec -a`). Die wordt gestart met `setsid`, zodat die loskomt van de procesgroep van de aanroeper: dat is wat de Action van de manager niet laat blokkeren.

## De geheimenopslag (CE versus DE, BFU versus AFU)

Instellingen zijn niet geheim en staan op device-encrypted opslag (`/data/adb/vddropbear`), leesbaar bij het opstarten. Geheimen (hostsleutel, `authorized_keys`, wachtwoordhashes) staan standaard op **credential-encrypted** opslag (`/data/misc_ce/0/vddropbear`), die pas ontgrendelt nadat de gebruiker zich heeft geauthenticeerd. Door `START_IN_BFU` aan te zetten verplaatsen de geheimen naar device-encrypted opslag, zodat de daemon kan draaien vóór de eerste ontgrendeling, ten koste van het feit dat die geheimen eerder leesbaar zijn. De module berekent bij elke opstartfase welke opslag te gebruiken.

## De patchset

De SSH-server blijft upstream Dropbear; onze wijzigingen zijn een paar controleerbare patches (zie [patches/README.md](../../patches/README.md)):

- een neutrale, tijdens runtime configureerbare identiteitsbanner;
- `authorized_keys` die wordt gelezen vanuit een via de omgeving ingesteld pad (zodat sleutels in de geheimenopslag staan);
- wachtwoordauthenticatie tegen een PBKDF2-hashbestand in plaats van de systeem-`crypt()`/shadow, die Android niet heeft (zie [BUILDING.md](../BUILDING.md)).

## De WebUI

Een statische pagina in de WebUI van de manager (KernelSU / APatch / WebUI-X). Die stuurt `module/common/vddb-webui.sh` aan via de `ksu.exec`-brug: status, start/stop/restart, config lezen/schrijven, en beheer van sleutels en wachtwoordaccounts. Alle data gaat base64-gecodeerd over de brug, zodat de shell die nooit interpreteert; wachtwoordhashes worden in de browser berekend met WebCrypto, zodat het wachtwoord in platte tekst de pagina nooit verlaat.
