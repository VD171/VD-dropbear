<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk. No invasive ADB exposure.
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
   XDA thread     : https://xdaforums.com/t/VD-Dropbear.4808524/
   Telegram       : @VD_Priv8 https://t.me/VD_Priv8
   Channel        : @Priv8_VD https://t.me/Priv8_VD
   Discord        : @VD.Priv8 https://discord.com/users/1296831918989639721
   E-mail         : vd.priv8@pm.me
  ======================================================================
-->

> **Languages:** [English](../ARCHITECTURE.md) · [العربية](../ar/ARCHITECTURE.md) · [Čeština](../cs/ARCHITECTURE.md) · [Deutsch](../de/ARCHITECTURE.md) · Español · [فارسی](../fa/ARCHITECTURE.md) · [Français](../fr/ARCHITECTURE.md) · [हिन्दी](../hi/ARCHITECTURE.md) · [Bahasa Indonesia](../in/ARCHITECTURE.md) · [Italiano](../it/ARCHITECTURE.md) · [日本語](../ja/ARCHITECTURE.md) · [한국어](../ko/ARCHITECTURE.md) · [Nederlands](../nl/ARCHITECTURE.md) · [Polski](../pl/ARCHITECTURE.md) · [Português](../pt/ARCHITECTURE.md) · [Русский](../ru/ARCHITECTURE.md) · [Svenska](../sv/ARCHITECTURE.md) · [ไทย](../th/ARCHITECTURE.md) · [Türkçe](../tr/ARCHITECTURE.md) · [Українська](../uk/ARCHITECTURE.md) · [Tiếng Việt](../vi/ARCHITECTURE.md) · [中文](../zh/ARCHITECTURE.md)

---

# Arquitectura

VD Dropbear es un módulo de KernelSU / APatch / Magisk que ejecuta exactamente un daemon SSH Dropbear,
gobernado por completo mediante configuración. Nada del servidor SSH está fijado en el código para un
dispositivo concreto; todo lo específico es configuración en tiempo de ejecución o un secreto.

## Piezas

- `module/common/vddropbear.sh`, la biblioteca central: carga la configuración (con valores por
  defecto integrados y seguros), resuelve el almacén de secretos, garantiza una host key, construye el
  vector de argumentos de Dropbear y gestiona una única instancia del daemon (start / stop / status /
  restart).
- `module/service.sh`: punto de entrada en el arranque. Respeta la política de inicio BFU/AFU; en modo
  AFU espera a que se desbloquee el almacenamiento cifrado por credenciales sin bloquear el arranque.
- `module/action.sh`, el botón **Action** del gestor: (re)lanza el daemon. Nunca lee stdin y separa el
  daemon en su propia sesión, de modo que el gestor no se queda colgado.
- `module/common/vddb-webui.sh` + `module/webroot/index.html`: el backend y la página de la WebUI.
- `patches/`: parches pequeños y auditables aplicados a Dropbear upstream en tiempo de compilación.
- `scripts/build.sh`, `scripts/build-bundles.sh`, `.github/workflows/build.yml`: la compilación.

## Ciclo de vida del daemon (una sola instancia)

`vddb_start` carga la configuración, detiene cualquier instancia en marcha, garantiza que exista una
host key y luego lanza un único daemon. El binario se distribuye como `vddropbear`, de modo que su
nombre de proceso coincide exactamente con `pgrep -x` (el `mksh` de Android no tiene `exec -a`). Se
lanza con `setsid` para que se separe del grupo de procesos de quien lo invoca: eso es lo que evita
que el botón Action del gestor se bloquee.

## El almacén de secretos (CE vs DE, BFU vs AFU)

Los ajustes no son secretos y residen en almacenamiento cifrado por dispositivo
(`/data/adb/vddropbear`), legible en el arranque. Los secretos (host key, `authorized_keys`, hashes de
contraseñas) residen por defecto en almacenamiento **cifrado por credenciales**
(`/data/misc_ce/0/vddropbear`), que solo se desbloquea tras autenticarse el usuario. Activar
`START_IN_BFU` mueve los secretos al almacenamiento cifrado por dispositivo para que el daemon pueda
ejecutarse antes del primer desbloqueo, a costa de que esos secretos sean legibles antes. El módulo
calcula qué almacén usar en cada etapa del arranque.

## El conjunto de parches

El servidor SSH se mantiene como Dropbear upstream; nuestros cambios son unos pocos parches revisables
(consulta [patches/README.md](../../patches/README.md)):

- un banner de identidad neutro y configurable en tiempo de ejecución;
- `authorized_keys` leído desde una ruta fijada por el entorno (para que las claves vivan en el almacén
  de secretos);
- autenticación por contraseña contra un archivo de hash PBKDF2 en lugar de la función `crypt()`/shadow
  del sistema, de la que Android carece (consulta [BUILDING.md](../BUILDING.md)).

## La WebUI

Una página estática en la WebUI del gestor (KernelSU / APatch / WebUI-X). Gobierna
`module/common/vddb-webui.sh` a través del puente `ksu.exec`: estado, start/stop/restart, lectura y
escritura de la configuración, y gestión de claves y cuentas con contraseña. Todos los datos cruzan el
puente codificados en base64, de modo que la shell nunca los interpreta; los hashes de contraseña se
calculan en el navegador con WebCrypto, así que la contraseña en texto claro nunca sale de la página.
