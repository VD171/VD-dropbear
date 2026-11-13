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

> **Languages:** [English](../CONFIGURATION.md) · [العربية](../ar/CONFIGURATION.md) · [Čeština](../cs/CONFIGURATION.md) · [Deutsch](../de/CONFIGURATION.md) · [Español](../es/CONFIGURATION.md) · [فارسی](../fa/CONFIGURATION.md) · [Français](../fr/CONFIGURATION.md) · [हिन्दी](../hi/CONFIGURATION.md) · [Bahasa Indonesia](../in/CONFIGURATION.md) · [Italiano](../it/CONFIGURATION.md) · [日本語](../ja/CONFIGURATION.md) · [한국어](../ko/CONFIGURATION.md) · [Nederlands](../nl/CONFIGURATION.md) · [Polski](../pl/CONFIGURATION.md) · [Português](../pt/CONFIGURATION.md) · [Русский](../ru/CONFIGURATION.md) · Svenska · [ไทย](../th/CONFIGURATION.md) · [Türkçe](../tr/CONFIGURATION.md) · [Українська](../uk/CONFIGURATION.md) · [Tiếng Việt](../vi/CONFIGURATION.md) · [中文](../zh/CONFIGURATION.md)

---

# Konfiguration

Inställningarna ligger i `/data/adb/vddropbear/config` (skapas från `module/common/config.default` vid
första uppstarten). **WebUI:n** redigerar den här filen åt dig; du kan också redigera den för hand. Den
läses in som skal, så använd `KEY=value` utan mellanslag runt `=`. Inställningar är inte hemliga och
ligger på device-encrypted lagring; hemligheter (värdnycklar, authorized keys, lösenordshashar) ligger
i hemlighetslagret, aldrig här.

Tillämpa ändringar genom att starta om daemonen (WebUI:ns **Save & restart** gör detta).

## Allmänt

| Key | Default | Meaning |
|-----|---------|---------|
| `ENABLED` | `1` | Starta daemonen vid uppstart. `0` inaktiverar den helt. |
| `START_IN_BFU` | `0` | `0`: starta först efter första upplåsningen (AFU); hemligheter stannar på credential-encrypted (CE) lagring. `1`: starta även före första upplåsningen (BFU); hemligheter flyttas till device-encrypted (DE) lagring, läsbar före upplåsning. |
| `PORT` | `2222` | Standardport att lyssna på (portar per bindning kan åsidosätta den i `LISTEN_ADDRESSES`). |

## Lyssning / bindningar (kombinerbara)

Vilken kombination som helst är tillåten; de valda bindningarna slås samman. Om du rensar allt binder
VD Dropbear loopback i stället för varje gränssnitt.

| Key | Default | Meaning |
|-----|---------|---------|
| `LISTEN_LOOPBACK` | `1` | Lyssna endast på `127.0.0.1` / `::1`. |
| `LISTEN_ALL` | `0` | Lyssna på varje gränssnitt (`0.0.0.0` / `::`); exponerar enheten. |
| `LISTEN_IPV4` | `1` | Inkludera IPv4-bindningar. |
| `LISTEN_IPV6` | `1` | Inkludera IPv6-bindningar. |
| `LISTEN_ADDRESSES` | `""` | Extra specifika bindningar, kommaseparerade: `addr` (använder `PORT`) eller `addr:port`, IPv4 eller IPv6. |

## Identitet

| Key | Default | Meaning |
|-----|---------|---------|
| `HIDE_IDENT` | `1` | Skicka en neutral SSH-identitetsbanner så att skannrar inte kan fingeravtrycka exakt server/version. |
| `IDENT_STRING` | `""` | En anpassad identitetssträng. Tom använder det neutrala inbyggda standardvärdet. |

## Autentisering

En inloggning körs som det konto du autentiserar dig som: **root** som standard, eller ett konto med lägre behörighet (`shell`, `system`). Nycklar är standard; lösenord är tillval.

| Key | Default | Meaning |
|-----|---------|---------|
| `PUBKEY_AUTH` | `1` | Tillåt inloggning med publik nyckel (läser de auktoriserade nycklarna i hemlighetslagret). |
| `PASSWORD_AUTH` | `0` | Tillåt inloggning med lösenord. När den är av startas daemonen med lösenordsautentisering inaktiverad. |
| `MAX_AUTH_TRIES` | `3` | Högsta antal autentiseringsförsök per anslutning. |

## Session / miljö

| Key | Default | Meaning |
|-----|---------|---------|
| `LOGIN_SHELL` | `""` | Skal för sessionen. Tom använder kontots standard. |
| `HOME_DIR` | `""` | `HOME` för sessionen. Tom använder modulens katalog. |
| `EXTRA_ENV` | `""` | Extra miljö, `K=V;K2=V2`. |
| `IDLE_TIMEOUT` | `0` | Koppla ner efter N sekunders inaktivitet. `0` inaktiverar. |
| `KEEPALIVE` | `0` | Skicka en keepalive var N:e sekund. `0` inaktiverar. |
| `RECEIVE_WINDOW` | `""` | Storlek på Dropbears mottagningsfönster. Tom använder standardvärdet. |

## Vidarebefordran (av som standard)

| Key | Default | Meaning |
|-----|---------|---------|
| `ALLOW_LOCAL_FORWARD` | `0` | Tillåt lokal (`-L`) portvidarebefordran. |
| `ALLOW_REMOTE_FORWARD` | `0` | Tillåt fjärr-(`-R`)-portvidarebefordran. |
| `GATEWAY_PORTS` | `0` | Låt vidarebefordrade fjärrportar binda till alla gränssnitt. |

## Värdnyckel

| Key | Default | Meaning |
|-----|---------|---------|
| `HOSTKEY_TYPE` | `ed25519` | Typ av värdnyckel: `ed25519`, `rsa` eller `ecdsa`. Genereras vid första starten till hemlighetslagret. |

## Hemlighetslagret

Konfigureras inte här, löses upp utifrån `START_IN_BFU`:

- **AFU (standard):** `/data/misc_ce/0/vddropbear/secret`: credential-encrypted, tillgänglig först
  efter att du låst upp enheten.
- **BFU:** `/data/adb/vddropbear/secret`: device-encrypted, läsbar före första upplåsningen.

Det innehåller värdnyckeln, `authorized_keys` och `passwd`-hashfilen. Se
[BUILDING.md](../BUILDING.md) för lösenordshashens format.
