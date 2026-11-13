<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk. No invasive ADB exposure.
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
   XDA thread     : https://xdaforums.com/t/VD-Dropbear.4808524/
   Telegram       : @VD_Priv8 https://t.me/VD_Priv8
   Channel        : @Priv8_VD https://t.me/Priv8_VD
   Discord        : @VD.Priv8 https://discord.com/users/1296831918989639721
   E-mail         : vd.priv8@pm.me
  ======================================================================
-->

> **Languages:** [English](../CONFIGURATION.md) · [العربية](../ar/CONFIGURATION.md) · [Čeština](../cs/CONFIGURATION.md) · [Deutsch](../de/CONFIGURATION.md) · [Español](../es/CONFIGURATION.md) · [فارسی](../fa/CONFIGURATION.md) · [Français](../fr/CONFIGURATION.md) · [हिन्दी](../hi/CONFIGURATION.md) · [Bahasa Indonesia](../in/CONFIGURATION.md) · [Italiano](../it/CONFIGURATION.md) · [日本語](../ja/CONFIGURATION.md) · [한국어](../ko/CONFIGURATION.md) · Nederlands · [Polski](../pl/CONFIGURATION.md) · [Português](../pt/CONFIGURATION.md) · [Русский](../ru/CONFIGURATION.md) · [Svenska](../sv/CONFIGURATION.md) · [ไทย](../th/CONFIGURATION.md) · [Türkçe](../tr/CONFIGURATION.md) · [Українська](../uk/CONFIGURATION.md) · [Tiếng Việt](../vi/CONFIGURATION.md) · [中文](../zh/CONFIGURATION.md)

---

# Configuratie

Instellingen staan in `/data/adb/vddropbear/config` (bij de eerste keer opstarten aangemaakt vanuit `module/common/config.default`). De **WebUI** bewerkt dit bestand voor je; je kunt het ook met de hand bewerken. Het wordt als shell ingelezen, dus gebruik `KEY=value` zonder spaties rond `=`. Instellingen zijn niet geheim en staan op device-encrypted opslag; geheimen (hostsleutels, authorized keys, wachtwoordhashes) staan in de geheimenopslag, nooit hier.

Pas wijzigingen toe door de daemon te herstarten (de **Save & restart** van de WebUI doet dit).

## Algemeen

| Key | Default | Betekenis |
|-----|---------|---------|
| `ENABLED` | `1` | Start de daemon bij het opstarten. `0` schakelt die volledig uit. |
| `START_IN_BFU` | `0` | `0`: start pas na de eerste ontgrendeling (AFU); geheimen blijven op credential-encrypted (CE) opslag. `1`: start ook vóór de eerste ontgrendeling (BFU); geheimen verhuizen naar device-encrypted (DE) opslag, leesbaar vóór ontgrendeling. |
| `PORT` | `2222` | Standaard luisterpoort (poorten per bind kunnen die overschrijven in `LISTEN_ADDRESSES`). |

## Luisteren / binds (combineerbaar)

Elke combinatie is toegestaan; de gekozen binds worden samengevoegd. Als je alles leegmaakt, bindt VD Dropbear aan loopback in plaats van aan elke interface.

| Key | Default | Betekenis |
|-----|---------|---------|
| `LISTEN_LOOPBACK` | `1` | Luister alleen op `127.0.0.1` / `::1`. |
| `LISTEN_ALL` | `0` | Luister op elke interface (`0.0.0.0` / `::`); stelt het toestel bloot. |
| `LISTEN_IPV4` | `1` | Neem IPv4-binds op. |
| `LISTEN_IPV6` | `1` | Neem IPv6-binds op. |
| `LISTEN_ADDRESSES` | `""` | Extra specifieke binds, door komma's gescheiden: `addr` (gebruikt `PORT`) of `addr:port`, IPv4 of IPv6. |

## Identiteit

| Key | Default | Betekenis |
|-----|---------|---------|
| `HIDE_IDENT` | `1` | Stuur een neutrale SSH-identiteitsbanner zodat scanners de exacte server/versie niet kunnen fingerprinten. |
| `IDENT_STRING` | `""` | Een eigen identiteitsstring. Leeg gebruikt de neutrale ingebouwde standaard. |

## Authenticatie

Een login draait als het account waarmee je je authenticeert: standaard **root**, of een account met minder rechten (`shell`, `system`). Sleutels zijn de standaard; wachtwoorden zijn opt-in.

| Key | Default | Betekenis |
|-----|---------|---------|
| `PUBKEY_AUTH` | `1` | Sta login met publieke sleutel toe (leest de authorized keys in de geheimenopslag). |
| `PASSWORD_AUTH` | `0` | Sta wachtwoordlogin toe. Als dit uit staat, wordt de daemon gestart met wachtwoordauthenticatie uitgeschakeld. |
| `MAX_AUTH_TRIES` | `3` | Maximaal aantal authenticatiepogingen per verbinding. |

## Sessie / omgeving

| Key | Default | Betekenis |
|-----|---------|---------|
| `LOGIN_SHELL` | `""` | Shell voor de sessie. Leeg gebruikt de standaard van het account. |
| `HOME_DIR` | `""` | `HOME` voor de sessie. Leeg gebruikt de modulemap. |
| `EXTRA_ENV` | `""` | Extra omgeving, `K=V;K2=V2`. |
| `IDLE_TIMEOUT` | `0` | Verbreek na N seconden inactiviteit. `0` schakelt dit uit. |
| `KEEPALIVE` | `0` | Stuur elke N seconden een keepalive. `0` schakelt dit uit. |
| `RECEIVE_WINDOW` | `""` | Grootte van het Dropbear-ontvangstvenster. Leeg gebruikt de standaard. |

## Forwarding (standaard uit)

| Key | Default | Betekenis |
|-----|---------|---------|
| `ALLOW_LOCAL_FORWARD` | `0` | Sta lokale (`-L`) port forwarding toe. |
| `ALLOW_REMOTE_FORWARD` | `0` | Sta externe (`-R`) port forwarding toe. |
| `GATEWAY_PORTS` | `0` | Laat geforwarde externe poorten aan alle interfaces binden. |

## Hostsleutel

| Key | Default | Betekenis |
|-----|---------|---------|
| `HOSTKEY_TYPE` | `ed25519` | Type hostsleutel: `ed25519`, `rsa` of `ecdsa`. Wordt bij de eerste start in de geheimenopslag gegenereerd. |

## De geheimenopslag

Hier niet geconfigureerd, afgeleid van `START_IN_BFU`:

- **AFU (standaard):** `/data/misc_ce/0/vddropbear/secret`: credential-encrypted, alleen beschikbaar nadat je het toestel ontgrendelt.
- **BFU:** `/data/adb/vddropbear/secret`: device-encrypted, leesbaar vóór de eerste ontgrendeling.

Die bevat de hostsleutel, `authorized_keys`, en het `passwd`-hashbestand. Zie [BUILDING.md](../BUILDING.md) voor het formaat van de wachtwoordhash.
