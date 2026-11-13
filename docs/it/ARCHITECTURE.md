<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk - no invasive ADB exposure.
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
   XDA thread     : https://xdaforums.com/t/VD-dropbear.4808524/
   Telegram       : @VD_Priv8 https://t.me/VD_Priv8
   Channel        : @Priv8_VD https://t.me/Priv8_VD
   Discord        : @VD.Priv8 https://discord.com/users/1296831918989639721
   E-mail         : vd.priv8@pm.me
  ======================================================================
-->

> **Languages:** [English](../ARCHITECTURE.md) · [العربية](../ar/ARCHITECTURE.md) · [Čeština](../cs/ARCHITECTURE.md) · [Deutsch](../de/ARCHITECTURE.md) · [Español](../es/ARCHITECTURE.md) · [فارسی](../fa/ARCHITECTURE.md) · [Français](../fr/ARCHITECTURE.md) · [हिन्दी](../hi/ARCHITECTURE.md) · [Bahasa Indonesia](../in/ARCHITECTURE.md) · Italiano · [日本語](../ja/ARCHITECTURE.md) · [한국어](../ko/ARCHITECTURE.md) · [Nederlands](../nl/ARCHITECTURE.md) · [Polski](../pl/ARCHITECTURE.md) · [Português](../pt/ARCHITECTURE.md) · [Русский](../ru/ARCHITECTURE.md) · [Svenska](../sv/ARCHITECTURE.md) · [ไทย](../th/ARCHITECTURE.md) · [Türkçe](../tr/ARCHITECTURE.md) · [Українська](../uk/ARCHITECTURE.md) · [Tiếng Việt](../vi/ARCHITECTURE.md) · [中文](../zh/ARCHITECTURE.md)

---

# Architettura

VD Dropbear è un modulo KernelSU / APatch / Magisk che esegue esattamente un daemon SSH Dropbear,
guidato interamente dalla configurazione. Nulla del server SSH è cablato a un singolo dispositivo;
tutto ciò che è specifico è configurazione di runtime o un secret.

## Componenti

- `module/common/vddropbear.sh` - la libreria centrale: carica la configurazione (con default
  incorporati sicuri), risolve il secret store, garantisce una host key, costruisce il vettore di
  argomenti di Dropbear e gestisce una singola istanza del daemon (start / stop / status / restart).
- `module/service.sh` - punto d'ingresso all'avvio. Rispetta la politica di avvio BFU/AFU; in modalità
  AFU attende che lo storage credential-encrypted si sblocchi senza bloccare l'avvio.
- `module/action.sh` - il pulsante **Action** del manager: (ri)avvia il daemon. Non legge mai lo stdin
  e distacca il daemon nella sua sessione, così il manager non si blocca.
- `module/common/vddb-webui.sh` + `module/webroot/index.html` - il backend e la pagina della WebUI.
- `patches/` - piccole patch verificabili applicate a Dropbear upstream in fase di build.
- `scripts/build.sh`, `scripts/build-bundles.sh`, `.github/workflows/build.yml` - la build.

## Ciclo di vita del daemon (istanza singola)

`vddb_start` carica la configurazione, ferma ogni istanza in esecuzione, garantisce che esista una host
key, poi avvia un daemon. Il binario è distribuito come `vddropbear`, così il suo nome di processo
corrisponde esattamente a `pgrep -x` (il `mksh` di Android non ha `exec -a`). Viene avviato con `setsid`
così da distaccarsi dal gruppo di processi del chiamante - è questo che impedisce all'Action del manager
di bloccarsi.

## Il secret store (CE vs DE, BFU vs AFU)

Le impostazioni non sono secret e risiedono sullo storage device-encrypted (`/data/adb/vddropbear`),
leggibile all'avvio. I secret - host key, `authorized_keys`, hash delle password - risiedono per
impostazione predefinita sullo storage **credential-encrypted** (`/data/misc_ce/0/vddropbear`), che si
sblocca solo dopo l'autenticazione dell'utente. Attivare `START_IN_BFU` sposta i secret sullo storage
device-encrypted così che il daemon possa avviarsi prima del primo sblocco, al prezzo di rendere quei
secret leggibili prima. Il modulo calcola quale store usare a ogni fase dell'avvio.

## L'insieme di patch

Il server SSH resta Dropbear upstream; le nostre modifiche sono poche patch verificabili (vedi
[patches/README.md](../../patches/README.md)):

- un banner d'identità neutro, configurabile a runtime;
- `authorized_keys` letto da un percorso impostato tramite environment (così le chiavi vivono nel secret store);
- autenticazione con password contro un file di hash PBKDF2 anziché il `crypt()`/shadow di sistema, che
  Android non ha (vedi [BUILDING.md](../BUILDING.md)).

## La WebUI

Una pagina statica nella WebUI del manager (KernelSU / APatch / WebUI-X). Guida
`module/common/vddb-webui.sh` attraverso il bridge `ksu.exec`: stato, start/stop/restart, lettura/scrittura
della configurazione e gestione di chiavi e account password. Tutti i dati attraversano il bridge
codificati in base64, così la shell non li interpreta mai; gli hash delle password sono calcolati nel
browser con WebCrypto, così la password in chiaro non lascia mai la pagina.
