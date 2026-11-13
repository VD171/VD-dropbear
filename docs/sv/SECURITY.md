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

> **Languages:** [English](../../SECURITY.md) · [العربية](../ar/SECURITY.md) · [Čeština](../cs/SECURITY.md) · [Deutsch](../de/SECURITY.md) · [Español](../es/SECURITY.md) · [فارسی](../fa/SECURITY.md) · [Français](../fr/SECURITY.md) · [हिन्दी](../hi/SECURITY.md) · [Bahasa Indonesia](../in/SECURITY.md) · [Italiano](../it/SECURITY.md) · [日本語](../ja/SECURITY.md) · [한국어](../ko/SECURITY.md) · [Nederlands](../nl/SECURITY.md) · [Polski](../pl/SECURITY.md) · [Português](../pt/SECURITY.md) · [Русский](../ru/SECURITY.md) · Svenska · [ไทย](../th/SECURITY.md) · [Türkçe](../tr/SECURITY.md) · [Українська](../uk/SECURITY.md) · [Tiếng Việt](../vi/SECURITY.md) · [中文](../zh/SECURITY.md)

---

# Säkerhetspolicy

## Det enda du behöver förstå

VD Dropbear startar en SSH-server, och **varje anslutning som autentiserar sig framgångsrikt får ett
root-skal**. Säkerheten för din enhet är därför lika med säkerheten för den här serverns konfiguration
och inloggningsuppgifter. Vänligen:

- **Föredra publika nycklar framför lösenord.** Lösenordsinloggning är av som standard.
- Om du måste använda ett lösenord, använd ett starkt. WebUI:n kräver en miniminivå och lagrar bara en hash.
- **Exponera inte porten mot det öppna internet.** Bind till loopback eller ett betrott LAN, eller nå
  den över ett VPN / en tunnel.
- Förstå **BFU-avvägningen**: att aktivera start före upplåsning lägger värdnyckeln och
  inloggningsuppgifterna på device-encrypted lagring, läsbar innan enheten låses upp. Lämna den av om
  du inte behöver SSH före upplåsning.
- Håll vidarebefordran av om du inte behöver den (den är av som standard).

## Vad VD Dropbear gör för att hjälpa

- En neutral, föga avslöjande versionsbanner så att nätverksskannrar inte kan fingeravtrycka exakt
  server och version.
- Inloggningsuppgifter på credential-encrypted lagring som standard (dekrypteras först efter att du låst upp).
- Ingen telemetri, inga egna nätverksanrop, ingen analys. Den körs helt på din enhet.

## Versioner som stöds

Säkerhetsfixar hamnar i den senaste utgåvan. Serverbinären följer upstream Dropbear;
säkerhetsutgåvor från upstream byggs om och levereras så snart CI:n plockar upp dem.

## Rapportera en sårbarhet

Rapportera säkerhetsproblem privat, inte i ett offentligt ärende:

- **E-post:** vd.priv8@pm.me
- **Telegram:** [@VD_Priv8](https://t.me/VD_Priv8)

Ange versionen, en beskrivning och (helst) ett sätt att återskapa. Du får en bekräftelse, och vi
samordnar en tidsplan för fix och offentliggörande med dig. För sårbarheter i Dropbear självt,
rapportera även till upstream på <https://matt.ucc.asn.au/dropbear/>.
