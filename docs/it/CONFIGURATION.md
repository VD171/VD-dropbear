<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk - no invasive ADB exposure.
   Configuration reference.

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

> **Languages:** [English](../CONFIGURATION.md) · [العربية](../ar/CONFIGURATION.md) · [Čeština](../cs/CONFIGURATION.md) · [Deutsch](../de/CONFIGURATION.md) · [Español](../es/CONFIGURATION.md) · [فارسی](../fa/CONFIGURATION.md) · [Français](../fr/CONFIGURATION.md) · [हिन्दी](../hi/CONFIGURATION.md) · [Bahasa Indonesia](../in/CONFIGURATION.md) · Italiano · [日本語](../ja/CONFIGURATION.md) · [한국어](../ko/CONFIGURATION.md) · [Nederlands](../nl/CONFIGURATION.md) · [Polski](../pl/CONFIGURATION.md) · [Português](../pt/CONFIGURATION.md) · [Русский](../ru/CONFIGURATION.md) · [Svenska](../sv/CONFIGURATION.md) · [ไทย](../th/CONFIGURATION.md) · [Türkçe](../tr/CONFIGURATION.md) · [Українська](../uk/CONFIGURATION.md) · [Tiếng Việt](../vi/CONFIGURATION.md) · [中文](../zh/CONFIGURATION.md)

---

# Configurazione

Le impostazioni risiedono in `/data/adb/vddropbear/config` (inizializzate da
`module/common/config.default` al primo avvio). La **WebUI** modifica questo file al posto tuo; puoi
anche modificarlo a mano. Viene caricato come shell, quindi usa `KEY=value` senza spazi attorno a `=`.
Le impostazioni non sono secret e risiedono sullo storage device-encrypted; i secret (host key,
authorized keys, hash delle password) risiedono nel secret store, mai qui.

Applica le modifiche riavviando il daemon (il **Save & restart** della WebUI fa questo).

## Generale

| Key | Default | Significato |
|-----|---------|---------|
| `ENABLED` | `1` | Avvia il daemon all'avvio. `0` lo disabilita del tutto. |
| `START_IN_BFU` | `0` | `0`: avvia solo dopo il primo sblocco (AFU); i secret restano sullo storage credential-encrypted (CE). `1`: avvia anche prima del primo sblocco (BFU); i secret passano allo storage device-encrypted (DE), leggibili prima dello sblocco. |
| `PORT` | `2222` | Porta di ascolto predefinita (le porte per-bind possono sovrascriverla in `LISTEN_ADDRESSES`). |

## Ascolto / bind (componibili)

È ammessa qualsiasi combinazione; i bind selezionati vengono uniti. Se cancelli tutto, VD Dropbear fa
il bind su loopback anziché su ogni interfaccia.

| Key | Default | Significato |
|-----|---------|---------|
| `LISTEN_LOOPBACK` | `1` | Ascolta solo su `127.0.0.1` / `::1`. |
| `LISTEN_ALL` | `0` | Ascolta su ogni interfaccia (`0.0.0.0` / `::`) - espone il dispositivo. |
| `LISTEN_IPV4` | `1` | Includi i bind IPv4. |
| `LISTEN_IPV6` | `1` | Includi i bind IPv6. |
| `LISTEN_ADDRESSES` | `""` | Bind specifici aggiuntivi, separati da virgola: `addr` (usa `PORT`) o `addr:port`, IPv4 o IPv6. |

## Identità

| Key | Default | Significato |
|-----|---------|---------|
| `HIDE_IDENT` | `1` | Invia un banner d'identità SSH neutro così che gli scanner non possano riconoscere server/versione esatti. |
| `IDENT_STRING` | `""` | Una stringa d'identità personalizzata. Vuota usa il default neutro incorporato. |

## Autenticazione

Ogni accesso autenticato è **root**. Le chiavi sono il default; le password sono opzionali.

| Key | Default | Significato |
|-----|---------|---------|
| `PUBKEY_AUTH` | `1` | Consenti l'accesso con chiave pubblica (legge le authorized keys nel secret store). |
| `PASSWORD_AUTH` | `0` | Consenti l'accesso con password. Quando è disattivato, il daemon viene avviato con l'autenticazione password disabilitata. |
| `MAX_AUTH_TRIES` | `3` | Numero massimo di tentativi di autenticazione per connessione. |
| `LOGIN_USER` | `root` | L'account con cui accedere. Deve essere uno che il sistema riconosce (di solito `root`). |

## Sessione / environment

| Key | Default | Significato |
|-----|---------|---------|
| `LOGIN_SHELL` | `""` | Shell per la sessione. Vuota usa il default dell'account. |
| `HOME_DIR` | `""` | `HOME` per la sessione. Vuota usa la directory del modulo. |
| `EXTRA_ENV` | `""` | Environment aggiuntivo, `K=V;K2=V2`. |
| `IDLE_TIMEOUT` | `0` | Disconnetti dopo N secondi di inattività. `0` disabilita. |
| `KEEPALIVE` | `0` | Invia un keepalive ogni N secondi. `0` disabilita. |
| `RECEIVE_WINDOW` | `""` | Dimensione della receive window di Dropbear. Vuota usa il default. |

## Forwarding (disattivato per impostazione predefinita)

| Key | Default | Significato |
|-----|---------|---------|
| `ALLOW_LOCAL_FORWARD` | `0` | Consenti il port forwarding locale (`-L`). |
| `ALLOW_REMOTE_FORWARD` | `0` | Consenti il port forwarding remoto (`-R`). |
| `GATEWAY_PORTS` | `0` | Consenti alle porte remote inoltrate di fare il bind su tutte le interfacce. |

## Host key

| Key | Default | Significato |
|-----|---------|---------|
| `HOSTKEY_TYPE` | `ed25519` | Tipo di host key: `ed25519`, `rsa` o `ecdsa`. Generata al primo avvio nel secret store. |

## Il secret store

Non configurato qui - risolto da `START_IN_BFU`:

- **AFU (default):** `/data/misc_ce/0/vddropbear/secret` - credential-encrypted, disponibile solo dopo
  che sblocchi il dispositivo.
- **BFU:** `/data/adb/vddropbear/secret` - device-encrypted, leggibile prima del primo sblocco.

Contiene la host key, `authorized_keys` e il file di hash `passwd`. Vedi
[BUILDING.md](../BUILDING.md) per il formato dell'hash delle password.
