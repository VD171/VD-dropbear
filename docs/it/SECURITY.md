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

> **Languages:** [English](../../SECURITY.md) · [العربية](../ar/SECURITY.md) · [Čeština](../cs/SECURITY.md) · [Deutsch](../de/SECURITY.md) · [Español](../es/SECURITY.md) · [فارسی](../fa/SECURITY.md) · [Français](../fr/SECURITY.md) · [हिन्दी](../hi/SECURITY.md) · [Bahasa Indonesia](../in/SECURITY.md) · Italiano · [日本語](../ja/SECURITY.md) · [한국어](../ko/SECURITY.md) · [Nederlands](../nl/SECURITY.md) · [Polski](../pl/SECURITY.md) · [Português](../pt/SECURITY.md) · [Русский](../ru/SECURITY.md) · [Svenska](../sv/SECURITY.md) · [ไทย](../th/SECURITY.md) · [Türkçe](../tr/SECURITY.md) · [Українська](../uk/SECURITY.md) · [Tiếng Việt](../vi/SECURITY.md) · [中文](../zh/SECURITY.md)

---

# Politica di Sicurezza

## L'unica cosa da capire

VD Dropbear avvia un server SSH, e **ogni connessione che si autentica con successo riceve una shell
root**. La sicurezza del tuo dispositivo equivale quindi alla sicurezza della configurazione e delle
credenziali di questo server. Per favore:

- **Preferisci le chiavi pubbliche alle password.** L'accesso con password è disattivato per impostazione predefinita.
- Se devi usare una password, usane una forte. La WebUI impone un minimo e memorizza solo un hash.
- **Non esporre la porta all'Internet pubblico.** Fai il bind su loopback o su una LAN fidata, oppure
  raggiungila tramite VPN / tunnel.
- Comprendi il **compromesso BFU**: abilitare l'avvio prima dello sblocco colloca la host key e le
  credenziali sullo storage device-encrypted, leggibili prima che il dispositivo venga sbloccato.
  Lascialo disattivato a meno che tu non abbia bisogno di SSH prima dello sblocco.
- Tieni il forwarding disattivato a meno che non ti serva (è disattivato per impostazione predefinita).

## Cosa fa VD Dropbear per aiutare

- Un banner di versione neutro e privo di informazioni, così che gli scanner di rete non possano
  riconoscere server e versione esatti.
- Credenziali sullo storage credential-encrypted per impostazione predefinita (decrittate solo dopo lo sblocco).
- Nessuna telemetria, nessuna chiamata di rete propria, nessuna analisi. Funziona interamente sul tuo dispositivo.

## Versioni supportate

Le correzioni di sicurezza arrivano nell'ultima release. Il binario del server segue Dropbear upstream;
le release di sicurezza upstream vengono ricompilate e distribuite non appena la CI le recepisce.

## Segnalare una vulnerabilità

Segnala i problemi di sicurezza in privato, non in una issue pubblica:

- **E-mail:** vd.priv8@pm.me
- **Telegram:** [@VD_Priv8](https://t.me/VD_Priv8)

Includi la versione, una descrizione e (idealmente) una riproduzione. Riceverai un riscontro e
coordineremo con te una tempistica di correzione e divulgazione. Per le vulnerabilità in Dropbear
stesso, segnala anche a monte su <https://matt.ucc.asn.au/dropbear/>.
