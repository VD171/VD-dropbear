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

> **Languages:** [English](../AI-AGENTS.md) · [العربية](../ar/AI-AGENTS.md) · [Čeština](../cs/AI-AGENTS.md) · [Deutsch](../de/AI-AGENTS.md) · [Español](../es/AI-AGENTS.md) · [فارسی](../fa/AI-AGENTS.md) · [Français](../fr/AI-AGENTS.md) · [हिन्दी](../hi/AI-AGENTS.md) · [Bahasa Indonesia](../in/AI-AGENTS.md) · [Italiano](../it/AI-AGENTS.md) · [日本語](../ja/AI-AGENTS.md) · [한국어](../ko/AI-AGENTS.md) · Nederlands · [Polski](../pl/AI-AGENTS.md) · [Português](../pt/AI-AGENTS.md) · [Русский](../ru/AI-AGENTS.md) · [Svenska](../sv/AI-AGENTS.md) · [ไทย](../th/AI-AGENTS.md) · [Türkçe](../tr/AI-AGENTS.md) · [Українська](../uk/AI-AGENTS.md) · [Tiếng Việt](../vi/AI-AGENTS.md) · [中文](../zh/AI-AGENTS.md)

---

# AI-agents op je toestel

Een permanent draaiend SSH-eindpunt maakt van je telefoon iets wat een **autonome AI-agent rechtstreeks kan bedienen**. Elke agent die een shell of een SSH-verbinding kan aansturen - Claude Code, aider, een script met een LLM in de lus, je eigen automatisering - krijgt een echte root-sessie op het toestel, via het netwerk, zonder USB-kabel en zonder de zelfonthullende debugvlaggen van ADB.

Deze pagina werkt het idee uit dat in de README is geïntroduceerd.

## Waarom SSH en niet ADB voor agents

ADB kondigt zichzelf aan: `adb_enabled` en `development_settings_enabled` zijn door iedereen leesbaar, de verbinding wordt gelogd, en er is geen ondersteunde manier om te verbergen dat debuggen aan staat (of aan heeft gestaan). Een agent die over ADB werkt, laat dat spoor op het toestel achter voor elke app of antifraude-SDK om te lezen. VD Dropbear is het private alternatief - een gewone SSH-login, met inloggegevens die jij beheert en een banner die niets prijsgeeft.

## Wat een agent kan doen

Over één verbinding ziet een agent een normale Linux-achtige shell en kan die:

- bestanden lezen en bewerken, instellingen omzetten, en modules, pakketten en services beheren;
- logs uitpluizen, artefacten ophalen, en op aanvraag diagnoses of forensisch onderzoek uitvoeren;
- bestanden beide kanten op verplaatsen en synchroniseren via `scp` / `sftp` / `rsync` - back-ups, migraties, provisioning;
- een hele vloot van geroote toestellen vanaf één plek aansturen, elk bereikbaar met een eigen sleutel.

Omdat het project **AI-vriendelijk** is gebouwd - een gedocumenteerd configuratiebestand, een expliciet runtime [env contract](../../patches/README.md), voorspelbare paden en status in platte tekst - kan een agent zonder giswerk ontdekken hoe die het moet gebruiken.

## Het veilig doen

Dit is root, dus behandel het als root:

- geef de agent een **eigen gebruiker en sleutel**, niet die van jou;
- beperk de binds tot netwerken die je vertrouwt - loopback of een VPN in plaats van het open internet (zie [Configuration](CONFIGURATION.md));
- houd wachtwoordauthenticatie uit; een sleutel is intrekbaar en wordt nooit ingetypt;
- je kunt op elk moment een sleutel intrekken of de daemon stoppen vanuit de WebUI;
- onthoud dat elke verbinding een volledige root-sessie is - geef de agent alleen de reikwijdte die die nodig heeft.

## Een minimale opzet

1. Genereer een sleutelpaar speciaal voor de agent.
2. Voeg de publieke sleutel ervan toe in de WebUI (**Authorized keys**).
3. Bind alleen aan loopback of je VPN, op een niet-standaardpoort.
4. Richt de SSH-config van de agent op het toestel en laat die aan het werk gaan.
