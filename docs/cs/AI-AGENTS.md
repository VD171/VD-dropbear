<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk. No invasive ADB exposure.
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

> **Languages:** [English](../AI-AGENTS.md) · [العربية](../ar/AI-AGENTS.md) · Čeština · [Deutsch](../de/AI-AGENTS.md) · [Español](../es/AI-AGENTS.md) · [فارسی](../fa/AI-AGENTS.md) · [Français](../fr/AI-AGENTS.md) · [हिन्दी](../hi/AI-AGENTS.md) · [Bahasa Indonesia](../in/AI-AGENTS.md) · [Italiano](../it/AI-AGENTS.md) · [日本語](../ja/AI-AGENTS.md) · [한국어](../ko/AI-AGENTS.md) · [Nederlands](../nl/AI-AGENTS.md) · [Polski](../pl/AI-AGENTS.md) · [Português](../pt/AI-AGENTS.md) · [Русский](../ru/AI-AGENTS.md) · [Svenska](../sv/AI-AGENTS.md) · [ไทย](../th/AI-AGENTS.md) · [Türkçe](../tr/AI-AGENTS.md) · [Українська](../uk/AI-AGENTS.md) · [Tiếng Việt](../vi/AI-AGENTS.md) · [中文](../zh/AI-AGENTS.md)

---

# Agenti umělé inteligence na tvém zařízení

Trvale běžící koncový bod SSH promění tvůj telefon v něco, co **může autonomní agent umělé
inteligence ovládat přímo**. Každý agent, který umí řídit shell nebo spojení SSH (Claude Code,
aider, skript s jazykovým modelem ve smyčce, tvoje vlastní automatizace) získá na zařízení
skutečnou root relaci, přes síť, bez USB kabelu a bez ladicích příznaků ADB, které samy sebe
prozrazují.

Tato stránka rozvíjí myšlenku představenou v souboru README.

## Proč pro agenty SSH, a ne ADB

ADB se samo ohlašuje: hodnoty `adb_enabled` a `development_settings_enabled` jsou čitelné pro
kohokoli, spojení se zaznamenává a neexistuje podporovaný způsob, jak skrýt, že je (nebo bylo) ladění
zapnuté. Agent pracující přes ADB zanechává na zařízení tuto stopu, kterou si může přečíst jakákoli
aplikace nebo antipodvodové SDK. VD Dropbear je soukromá alternativa: běžné přihlášení přes SSH
s přihlašovacími údaji, které ovládáš ty, a s bannerem, jenž nic neprozradí.

## Co agent dokáže

Přes jediné spojení vidí agent běžný shell podobný Linuxu a může:

- číst a upravovat soubory, přepínat nastavení a spravovat moduly, balíčky a služby;
- třídit logy, stahovat artefakty a na vyžádání spouštět diagnostiku nebo forenzní analýzu;
- přesouvat a synchronizovat soubory oběma směry přes `scp` / `sftp` / `rsync`: zálohy, migrace, provisioning;
- řídit celou flotilu rootnutých zařízení z jednoho místa, každé dosažitelné vlastním klíčem.

Protože je projekt navržen tak, aby byl **přívětivý k umělé inteligenci** (zdokumentovaný
konfigurační soubor, explicitní [kontrakt běhového prostředí](../../patches/README.md), předvídatelné
cesty a stav v prostém textu), může agent zjistit, jak jej používat, bez hádání.

## Jak na to bezpečně

Tohle je root, tak s tím zacházej jako s rootem:

- dej agentovi **vlastní přihlašovací údaj**, ne ten svůj osobní, a nasměruj ho na účet s nižšími oprávněními (`shell`), pokud chceš omezit jeho dosah;
- omez vazby na sítě, kterým důvěřuješ: loopback nebo VPN místo otevřeného internetu
  (viz [Konfigurace](CONFIGURATION.md));
- nech ověřování heslem vypnuté; klíč lze odvolat a nikdy se nepíše;
- klíč můžeš kdykoli odvolat nebo démona zastavit z WebUI;
- pamatuj, že výchozí spojení je plná root relace: dej agentovi jen takový dosah, jaký potřebuje.

## Minimální nastavení

1. Vygeneruj pár klíčů jen pro agenta.
2. Přidej jeho veřejný klíč ve WebUI (**Authorized keys**).
3. Nastav vazbu jen na loopback nebo svou VPN, na jiném než výchozím portu.
4. Nasměruj konfiguraci SSH agenta na zařízení a nech ho pracovat.
