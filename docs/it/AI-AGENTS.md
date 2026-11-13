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
   XDA thread     : https://xdaforums.com/t/VD-dropbear.4808524/
   Telegram       : @VD_Priv8 https://t.me/VD_Priv8
   Channel        : @Priv8_VD https://t.me/Priv8_VD
   Discord        : @VD.Priv8 https://discord.com/users/1296831918989639721
   E-mail         : vd.priv8@pm.me
  ======================================================================
-->

> **Languages:** [English](../AI-AGENTS.md) · [العربية](../ar/AI-AGENTS.md) · [Čeština](../cs/AI-AGENTS.md) · [Deutsch](../de/AI-AGENTS.md) · [Español](../es/AI-AGENTS.md) · [فارسی](../fa/AI-AGENTS.md) · [Français](../fr/AI-AGENTS.md) · [हिन्दी](../hi/AI-AGENTS.md) · [Bahasa Indonesia](../in/AI-AGENTS.md) · Italiano · [日本語](../ja/AI-AGENTS.md) · [한국어](../ko/AI-AGENTS.md) · [Nederlands](../nl/AI-AGENTS.md) · [Polski](../pl/AI-AGENTS.md) · [Português](../pt/AI-AGENTS.md) · [Русский](../ru/AI-AGENTS.md) · [Svenska](../sv/AI-AGENTS.md) · [ไทย](../th/AI-AGENTS.md) · [Türkçe](../tr/AI-AGENTS.md) · [Українська](../uk/AI-AGENTS.md) · [Tiếng Việt](../vi/AI-AGENTS.md) · [中文](../zh/AI-AGENTS.md)

---

# Agenti AI sul tuo dispositivo

Un endpoint SSH sempre attivo trasforma il tuo telefono in qualcosa che **un agente AI autonomo può
operare direttamente**. Qualsiasi agente in grado di pilotare una shell o una connessione SSH - Claude
Code, aider, uno script LLM-in-the-loop, la tua automazione personale - ottiene una vera sessione root
sul dispositivo, via rete, senza cavo USB e senza alcuno dei flag di debug di ADB che si espongono da
soli.

Questa pagina approfondisce l'idea introdotta nel README.

## Perché SSH, e non ADB, per gli agenti

ADB si annuncia da solo: `adb_enabled` e `development_settings_enabled` sono leggibili da chiunque, la
connessione viene registrata e non esiste alcun modo supportato per nascondere che il debug è (o era)
attivo. Un agente che lavora tramite ADB lascia quella traccia sul dispositivo, leggibile da qualsiasi
app o SDK antifrode. VD Dropbear è l'alternativa privata - un normale accesso SSH, con credenziali che
controlli tu e un banner che non rivela nulla.

## Cosa può fare un agente

Su un'unica connessione, un agente vede una normale shell in stile Linux e può:

- leggere e modificare file, cambiare impostazioni e gestire moduli, pacchetti e servizi;
- analizzare i log, estrarre artefatti ed eseguire diagnostica o analisi forensi su richiesta;
- spostare e sincronizzare file in entrambe le direzioni tramite `scp` / `sftp` / `rsync` - backup, migrazioni, provisioning;
- pilotare un'intera flotta di dispositivi con root da un unico punto, ciascuno raggiungibile con la propria chiave.

Poiché il progetto è costruito per essere **AI-friendly** - un file di configurazione documentato, un
esplicito [env contract](../../patches/README.md) di runtime, percorsi prevedibili e stato in testo
semplice - un agente può scoprire come usarlo senza tirare a indovinare.

## Farlo in sicurezza

Questo è root, quindi trattalo come root:

- assegna all'agente un **utente e una chiave dedicati**, non quelli personali;
- limita i bind alle reti di cui ti fidi - loopback o una VPN anziché l'Internet aperto
  (vedi [Configuration](CONFIGURATION.md));
- tieni disattivata l'autenticazione con password; una chiave è revocabile e non viene mai digitata;
- puoi revocare una chiave o fermare il daemon in qualsiasi momento dalla WebUI;
- ricorda che ogni connessione è una sessione root completa - concedi all'agente solo la portata di cui ha bisogno.

## Una configurazione minima

1. Genera una coppia di chiavi solo per l'agente.
2. Aggiungi la sua chiave pubblica nella WebUI (**Authorized keys**).
3. Fai il bind solo su loopback o sulla tua VPN, su una porta non predefinita.
4. Punta la configurazione SSH dell'agente al dispositivo e lascialo lavorare.
