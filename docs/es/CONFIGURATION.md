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
   XDA thread     : https://xdaforums.com/t/VD-Dropbear.4808524/
   Telegram       : @VD_Priv8 https://t.me/VD_Priv8
   Channel        : @Priv8_VD https://t.me/Priv8_VD
   Discord        : @VD.Priv8 https://discord.com/users/1296831918989639721
   E-mail         : vd.priv8@pm.me
  ======================================================================
-->

> **Languages:** [English](../CONFIGURATION.md) · [العربية](../ar/CONFIGURATION.md) · [Čeština](../cs/CONFIGURATION.md) · [Deutsch](../de/CONFIGURATION.md) · Español · [فارسی](../fa/CONFIGURATION.md) · [Français](../fr/CONFIGURATION.md) · [हिन्दी](../hi/CONFIGURATION.md) · [Bahasa Indonesia](../in/CONFIGURATION.md) · [Italiano](../it/CONFIGURATION.md) · [日本語](../ja/CONFIGURATION.md) · [한국어](../ko/CONFIGURATION.md) · [Nederlands](../nl/CONFIGURATION.md) · [Polski](../pl/CONFIGURATION.md) · [Português](../pt/CONFIGURATION.md) · [Русский](../ru/CONFIGURATION.md) · [Svenska](../sv/CONFIGURATION.md) · [ไทย](../th/CONFIGURATION.md) · [Türkçe](../tr/CONFIGURATION.md) · [Українська](../uk/CONFIGURATION.md) · [Tiếng Việt](../vi/CONFIGURATION.md) · [中文](../zh/CONFIGURATION.md)

---

# Configuración

Los ajustes residen en `/data/adb/vddropbear/config` (sembrados desde `module/common/config.default` en
el primer arranque). La **WebUI** edita este archivo por ti; también puedes editarlo a mano. Se carga
como shell, así que usa `KEY=value` sin espacios alrededor del `=`. Los ajustes no son secretos y
residen en almacenamiento cifrado por dispositivo; los secretos (host keys, claves autorizadas, hashes
de contraseñas) residen en el almacén de secretos, nunca aquí.

Aplica los cambios reiniciando el daemon (el **Save & restart** de la WebUI hace esto).

## General

| Key | Default | Significado |
|-----|---------|---------|
| `ENABLED` | `1` | Inicia el daemon en el arranque. `0` lo deshabilita por completo. |
| `START_IN_BFU` | `0` | `0`: inicia solo tras el primer desbloqueo (AFU); los secretos permanecen en almacenamiento cifrado por credenciales (CE). `1`: inicia también antes del primer desbloqueo (BFU); los secretos se mueven a almacenamiento cifrado por dispositivo (DE), legible antes del desbloqueo. |
| `PORT` | `2222` | Puerto de escucha por defecto (los puertos por bind pueden anularlo en `LISTEN_ADDRESSES`). |

## Escucha / binds (combinables)

Se permite cualquier combinación; los binds seleccionados se fusionan. Si lo borras todo, VD Dropbear
hace el bind a loopback en lugar de a todas las interfaces.

| Key | Default | Significado |
|-----|---------|---------|
| `LISTEN_LOOPBACK` | `1` | Escucha solo en `127.0.0.1` / `::1`. |
| `LISTEN_ALL` | `0` | Escucha en todas las interfaces (`0.0.0.0` / `::`) - expone el dispositivo. |
| `LISTEN_IPV4` | `1` | Incluye binds IPv4. |
| `LISTEN_IPV6` | `1` | Incluye binds IPv6. |
| `LISTEN_ADDRESSES` | `""` | Binds específicos adicionales, separados por comas: `addr` (usa `PORT`) o `addr:port`, IPv4 o IPv6. |

## Identidad

| Key | Default | Significado |
|-----|---------|---------|
| `HIDE_IDENT` | `1` | Envía un banner de identidad SSH neutro para que los escáneres no puedan identificar el servidor/versión exactos. |
| `IDENT_STRING` | `""` | Una cadena de identidad personalizada. Si está vacía, usa el valor neutro integrado por defecto. |

## Autenticación

Todo inicio de sesión autenticado es **root**. Las claves son lo predeterminado; las contraseñas son
opcionales.

| Key | Default | Significado |
|-----|---------|---------|
| `PUBKEY_AUTH` | `1` | Permite el inicio de sesión por clave pública (lee las claves autorizadas del almacén de secretos). |
| `PASSWORD_AUTH` | `0` | Permite el inicio de sesión por contraseña. Cuando está desactivado, el daemon se inicia con la autenticación por contraseña deshabilitada. |
| `MAX_AUTH_TRIES` | `3` | Número máximo de intentos de autenticación por conexión. |

## Sesión / entorno

| Key | Default | Significado |
|-----|---------|---------|
| `LOGIN_SHELL` | `""` | Shell para la sesión. Si está vacía, usa la de la cuenta por defecto. |
| `HOME_DIR` | `""` | `HOME` para la sesión. Si está vacío, usa el directorio del módulo. |
| `EXTRA_ENV` | `""` | Entorno adicional, `K=V;K2=V2`. |
| `IDLE_TIMEOUT` | `0` | Desconecta tras N segundos de inactividad. `0` lo deshabilita. |
| `KEEPALIVE` | `0` | Envía un keepalive cada N segundos. `0` lo deshabilita. |
| `RECEIVE_WINDOW` | `""` | Tamaño de la ventana de recepción de Dropbear. Si está vacío, usa el valor por defecto. |

## Reenvío (desactivado por defecto)

| Key | Default | Significado |
|-----|---------|---------|
| `ALLOW_LOCAL_FORWARD` | `0` | Permite el reenvío de puertos local (`-L`). |
| `ALLOW_REMOTE_FORWARD` | `0` | Permite el reenvío de puertos remoto (`-R`). |
| `GATEWAY_PORTS` | `0` | Deja que los puertos remotos reenviados hagan bind a todas las interfaces. |

## Host key

| Key | Default | Significado |
|-----|---------|---------|
| `HOSTKEY_TYPE` | `ed25519` | Tipo de host key: `ed25519`, `rsa` o `ecdsa`. Se genera en el primer inicio dentro del almacén de secretos. |

## El almacén de secretos

No se configura aquí - se resuelve a partir de `START_IN_BFU`:

- **AFU (por defecto):** `/data/misc_ce/0/vddropbear/secret` - cifrado por credenciales, disponible solo
  después de que desbloquees el dispositivo.
- **BFU:** `/data/adb/vddropbear/secret` - cifrado por dispositivo, legible antes del primer desbloqueo.

Contiene la host key, `authorized_keys` y el archivo de hashes `passwd`. Consulta
[BUILDING.md](../BUILDING.md) para el formato del hash de contraseña.
