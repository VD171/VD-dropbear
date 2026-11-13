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

> **Languages:** [English](../AI-AGENTS.md) · [العربية](../ar/AI-AGENTS.md) · [Čeština](../cs/AI-AGENTS.md) · [Deutsch](../de/AI-AGENTS.md) · [Español](../es/AI-AGENTS.md) · [فارسی](../fa/AI-AGENTS.md) · [Français](../fr/AI-AGENTS.md) · [हिन्दी](../hi/AI-AGENTS.md) · [Bahasa Indonesia](../in/AI-AGENTS.md) · [Italiano](../it/AI-AGENTS.md) · [日本語](../ja/AI-AGENTS.md) · [한국어](../ko/AI-AGENTS.md) · [Nederlands](../nl/AI-AGENTS.md) · [Polski](../pl/AI-AGENTS.md) · [Português](../pt/AI-AGENTS.md) · [Русский](../ru/AI-AGENTS.md) · Svenska · [ไทย](../th/AI-AGENTS.md) · [Türkçe](../tr/AI-AGENTS.md) · [Українська](../uk/AI-AGENTS.md) · [Tiếng Việt](../vi/AI-AGENTS.md) · [中文](../zh/AI-AGENTS.md)

---

# AI-agenter på din enhet

En ständigt aktiv SSH-slutpunkt gör din telefon till något som en **autonom AI-agent kan styra
direkt**. Vilken agent som helst som kan köra ett skal eller en SSH-anslutning - Claude Code, aider,
ett LLM-i-loopen-skript, din egen automatisering - får en riktig root-session på enheten, över
nätverket, utan USB-kabel och utan någon av ADB:s självavslöjande felsökningsflaggor.

Den här sidan bygger vidare på idén som introduceras i README.

## Varför SSH, inte ADB, för agenter

ADB tillkännager sig självt: `adb_enabled` och `development_settings_enabled` är läsbara för alla,
anslutningen loggas, och det finns inget stödt sätt att dölja att felsökning är (eller har varit) på.
En agent som arbetar över ADB lämnar det spåret på enheten för vilken app eller anti-bedrägeri-SDK som
helst att läsa. VD Dropbear är det privata alternativet - en vanlig SSH-inloggning, med
inloggningsuppgifter du styr och en banner som inte avslöjar något.

## Vad en agent kan göra

Över en enda anslutning ser en agent ett vanligt Linux-liknande skal och kan:

- läsa och redigera filer, ändra inställningar och hantera moduler, paket och tjänster;
- sortera loggar, hämta artefakter och köra diagnostik eller forensik på begäran;
- flytta och synkronisera filer åt båda hållen över `scp` / `sftp` / `rsync` - säkerhetskopior, migreringar, provisionering;
- styra en hel flotta av root-enheter från ett ställe, var och en nåbar med sin egen nyckel.

Eftersom projektet är byggt för att vara **AI-vänligt** - en dokumenterad konfigurationsfil, ett
uttryckligt [env-kontrakt](../../patches/README.md) vid körning, förutsägbara sökvägar och status i
klartext - kan en agent lista ut hur den ska användas utan gissningar.

## Att göra det säkert

Det här är root, så behandla det som root:

- ge agenten en **dedikerad användare och nyckel**, inte din personliga;
- begränsa bindningarna till nätverk du litar på - loopback eller ett VPN snarare än det öppna
  internet (se [Konfiguration](CONFIGURATION.md));
- håll lösenordsautentisering avstängd; en nyckel går att återkalla och skrivs aldrig in;
- du kan återkalla en nyckel eller stoppa daemonen när som helst från WebUI;
- kom ihåg att varje anslutning är en fullständig root-session - ge agenten bara den räckvidd den behöver.

## En minimal uppsättning

1. Generera ett nyckelpar enbart för agenten.
2. Lägg till dess publika nyckel i WebUI (**Authorized keys**).
3. Bind endast till loopback eller ditt VPN, på en icke-standardport.
4. Rikta agentens SSH-konfiguration mot enheten och låt den arbeta.
