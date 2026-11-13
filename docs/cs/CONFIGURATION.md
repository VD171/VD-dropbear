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

> **Languages:** [English](../CONFIGURATION.md) · [العربية](../ar/CONFIGURATION.md) · Čeština · [Deutsch](../de/CONFIGURATION.md) · [Español](../es/CONFIGURATION.md) · [فارسی](../fa/CONFIGURATION.md) · [Français](../fr/CONFIGURATION.md) · [हिन्दी](../hi/CONFIGURATION.md) · [Bahasa Indonesia](../in/CONFIGURATION.md) · [Italiano](../it/CONFIGURATION.md) · [日本語](../ja/CONFIGURATION.md) · [한국어](../ko/CONFIGURATION.md) · [Nederlands](../nl/CONFIGURATION.md) · [Polski](../pl/CONFIGURATION.md) · [Português](../pt/CONFIGURATION.md) · [Русский](../ru/CONFIGURATION.md) · [Svenska](../sv/CONFIGURATION.md) · [ไทย](../th/CONFIGURATION.md) · [Türkçe](../tr/CONFIGURATION.md) · [Українська](../uk/CONFIGURATION.md) · [Tiếng Việt](../vi/CONFIGURATION.md) · [中文](../zh/CONFIGURATION.md)

---

# Konfigurace

Nastavení jsou v `/data/adb/vddropbear/config` (při prvním startu naplněna z
`module/common/config.default`). **WebUI** tento soubor upravuje za tebe; můžeš jej upravit i ručně.
Načítá se jako shell, takže používej `KEY=value` bez mezer kolem `=`. Nastavení nejsou tajná a leží na
úložišti šifrovaném zařízením; tajemství (hostitelské klíče, autorizované klíče, otisky hesel) leží
v úložišti tajemství, nikdy ne tady.

Změny uplatníš restartem démona (dělá to tlačítko **Save & restart** ve WebUI).

## Obecné

| Klíč | Výchozí | Význam |
|-----|---------|---------|
| `ENABLED` | `1` | Spustit démona při startu. `0` jej zcela vypne. |
| `START_IN_BFU` | `0` | `0`: spustit až po prvním odemčení (AFU); tajemství zůstanou na úložišti šifrovaném přihlašovacími údaji (CE). `1`: spustit i před prvním odemčením (BFU); tajemství se přesunou na úložiště šifrované zařízením (DE), čitelné před odemčením. |
| `PORT` | `2222` | Výchozí port pro naslouchání (porty jednotlivých vazeb jej mohou přepsat v `LISTEN_ADDRESSES`). |

## Naslouchání / vazby (skládatelné)

Povolena je libovolná kombinace; vybrané vazby se sloučí. Pokud vše vymažeš, VD Dropbear naváže
loopback místo každého rozhraní.

| Klíč | Výchozí | Význam |
|-----|---------|---------|
| `LISTEN_LOOPBACK` | `1` | Naslouchat jen na `127.0.0.1` / `::1`. |
| `LISTEN_ALL` | `0` | Naslouchat na každém rozhraní (`0.0.0.0` / `::`); vystaví zařízení. |
| `LISTEN_IPV4` | `1` | Zahrnout vazby IPv4. |
| `LISTEN_IPV6` | `1` | Zahrnout vazby IPv6. |
| `LISTEN_ADDRESSES` | `""` | Další konkrétní vazby oddělené čárkami: `addr` (použije `PORT`) nebo `addr:port`, IPv4 nebo IPv6. |

## Identita

| Klíč | Výchozí | Význam |
|-----|---------|---------|
| `HIDE_IDENT` | `1` | Posílat neutrální identifikační banner SSH, aby skenery nemohly přesně otiskovat server/verzi. |
| `IDENT_STRING` | `""` | Vlastní identifikační řetězec. Prázdná hodnota použije neutrální vestavěný výchozí. |

## Ověřování

Každé ověřené přihlášení je **root**. Klíče jsou výchozí; hesla jsou volitelná.

| Klíč | Výchozí | Význam |
|-----|---------|---------|
| `PUBKEY_AUTH` | `1` | Povolit přihlášení veřejným klíčem (čte autorizované klíče v úložišti tajemství). |
| `PASSWORD_AUTH` | `0` | Povolit přihlášení heslem. Když je vypnuto, démon se spouští s vypnutým ověřováním heslem. |
| `MAX_AUTH_TRIES` | `3` | Maximální počet pokusů o ověření na jedno spojení. |

## Relace / prostředí

| Klíč | Výchozí | Význam |
|-----|---------|---------|
| `LOGIN_SHELL` | `""` | Shell pro relaci. Prázdná hodnota použije výchozí účtu. |
| `HOME_DIR` | `""` | `HOME` pro relaci. Prázdná hodnota použije adresář modulu. |
| `EXTRA_ENV` | `""` | Další prostředí, `K=V;K2=V2`. |
| `IDLE_TIMEOUT` | `0` | Odpojit po N sekundách nečinnosti. `0` vypíná. |
| `KEEPALIVE` | `0` | Posílat keepalive každých N sekund. `0` vypíná. |
| `RECEIVE_WINDOW` | `""` | Velikost přijímacího okna Dropbearu. Prázdná hodnota použije výchozí. |

## Přesměrování (ve výchozím stavu vypnuto)

| Klíč | Výchozí | Význam |
|-----|---------|---------|
| `ALLOW_LOCAL_FORWARD` | `0` | Povolit místní (`-L`) přesměrování portů. |
| `ALLOW_REMOTE_FORWARD` | `0` | Povolit vzdálené (`-R`) přesměrování portů. |
| `GATEWAY_PORTS` | `0` | Umožnit přesměrovaným vzdáleným portům navázat na všechna rozhraní. |

## Hostitelský klíč

| Klíč | Výchozí | Význam |
|-----|---------|---------|
| `HOSTKEY_TYPE` | `ed25519` | Typ hostitelského klíče: `ed25519`, `rsa` nebo `ecdsa`. Vygeneruje se při prvním spuštění do úložiště tajemství. |

## Úložiště tajemství

Nekonfiguruje se zde, určuje se z `START_IN_BFU`:

- **AFU (výchozí):** `/data/misc_ce/0/vddropbear/secret`: šifrováno přihlašovacími údaji, dostupné
  až po odemčení zařízení.
- **BFU:** `/data/adb/vddropbear/secret`: šifrováno zařízením, čitelné před prvním odemčením.

Obsahuje hostitelský klíč, `authorized_keys` a soubor otisků `passwd`. Formát otisku hesla viz
[BUILDING.md](../BUILDING.md).
