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
   XDA thread     : https://xdaforums.com/t/VD-dropbear.4808524/
   Telegram       : @VD_Priv8 https://t.me/VD_Priv8
   Channel        : @Priv8_VD https://t.me/Priv8_VD
   Discord        : @VD.Priv8 https://discord.com/users/1296831918989639721
   E-mail         : vd.priv8@pm.me
  ======================================================================
-->

> **Languages:** [English](../../SECURITY.md) · [العربية](../ar/SECURITY.md) · Čeština · [Deutsch](../de/SECURITY.md) · [Español](../es/SECURITY.md) · [فارسی](../fa/SECURITY.md) · [Français](../fr/SECURITY.md) · [हिन्दी](../hi/SECURITY.md) · [Bahasa Indonesia](../in/SECURITY.md) · [Italiano](../it/SECURITY.md) · [日本語](../ja/SECURITY.md) · [한국어](../ko/SECURITY.md) · [Nederlands](../nl/SECURITY.md) · [Polski](../pl/SECURITY.md) · [Português](../pt/SECURITY.md) · [Русский](../ru/SECURITY.md) · [Svenska](../sv/SECURITY.md) · [ไทย](../th/SECURITY.md) · [Türkçe](../tr/SECURITY.md) · [Українська](../uk/SECURITY.md) · [Tiếng Việt](../vi/SECURITY.md) · [中文](../zh/SECURITY.md)

---

# Zásady zabezpečení

## Jedna věc, kterou je třeba pochopit

VD Dropbear spouští server SSH a **každé spojení, které se úspěšně ověří, dostane root shell**.
Bezpečnost tvého zařízení se proto rovná bezpečnosti konfigurace a přihlašovacích údajů tohoto
serveru. Prosíme:

- **Upřednostňuj veřejné klíče před hesly.** Přihlášení heslem je ve výchozím stavu vypnuté.
- Pokud heslo použít musíš, zvol silné - WebUI vynucuje minimum a ukládá pouze otisk.
- **Nevystavuj port do veřejného internetu.** Naváž na loopback nebo důvěryhodnou LAN, nebo se k němu
  připojuj přes VPN / tunel.
- Pochop **kompromis BFU**: zapnutí spuštění před odemčením umístí hostitelský klíč a přihlašovací
  údaje na úložiště šifrované zařízením, čitelné dřív, než je zařízení odemčeno. Nech to vypnuté,
  pokud SSH před odemčením nepotřebuješ.
- Nech přesměrování vypnuté, dokud je nepotřebuješ (ve výchozím stavu je vypnuté).

## Čím VD Dropbear pomáhá

- Neutrální, málo vypovídající banner verze, aby síťové skenery nemohly přesně otiskovat server
  a verzi.
- Přihlašovací údaje ve výchozím nastavení na úložišti šifrovaném přihlašovacími údaji (dešifrují se
  až po odemčení).
- Žádná telemetrie, žádná vlastní síťová volání, žádná analytika. Běží výhradně na tvém zařízení.

## Podporované verze

Bezpečnostní opravy míří na nejnovější vydání. Binárka serveru sleduje upstreamový Dropbear;
upstreamová bezpečnostní vydání se znovu sestaví a dodají, jakmile je CI zachytí.

## Hlášení zranitelnosti

Bezpečnostní problémy prosím hlas soukromě, ne ve veřejném issue:

- **E-mail:** vd.priv8@pm.me
- **Telegram:** [@VD_Priv8](https://t.me/VD_Priv8)

Uveď verzi, popis a (ideálně) postup reprodukce. Dostaneš potvrzení o přijetí a domluvíme s tebou
opravu a časový plán zveřejnění. U zranitelností v samotném Dropbearu prosím nahlas také upstream na
<https://matt.ucc.asn.au/dropbear/>.
