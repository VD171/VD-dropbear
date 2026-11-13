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

> **Languages:** [English](../../SECURITY.md) · [العربية](../ar/SECURITY.md) · [Čeština](../cs/SECURITY.md) · [Deutsch](../de/SECURITY.md) · Español · [فارسی](../fa/SECURITY.md) · [Français](../fr/SECURITY.md) · [हिन्दी](../hi/SECURITY.md) · [Bahasa Indonesia](../in/SECURITY.md) · [Italiano](../it/SECURITY.md) · [日本語](../ja/SECURITY.md) · [한국어](../ko/SECURITY.md) · [Nederlands](../nl/SECURITY.md) · [Polski](../pl/SECURITY.md) · [Português](../pt/SECURITY.md) · [Русский](../ru/SECURITY.md) · [Svenska](../sv/SECURITY.md) · [ไทย](../th/SECURITY.md) · [Türkçe](../tr/SECURITY.md) · [Українська](../uk/SECURITY.md) · [Tiếng Việt](../vi/SECURITY.md) · [中文](../zh/SECURITY.md)

---

# Política de seguridad

## Lo único que hay que entender

VD Dropbear inicia un servidor SSH, y **cada conexión que se autentica con éxito recibe una shell
root**. Por tanto, la seguridad de tu dispositivo equivale a la seguridad de la configuración y las
credenciales de este servidor. Por favor:

- **Prefiere las claves públicas a las contraseñas.** El inicio de sesión por contraseña está desactivado
  por defecto.
- Si debes usar una contraseña, usa una fuerte. La WebUI exige un mínimo y solo almacena un hash.
- **No expongas el puerto a la Internet pública.** Haz el bind a loopback o a una LAN de confianza, o
  llega a él a través de una VPN / túnel.
- Comprende el **compromiso del modo BFU**: activar el inicio antes del desbloqueo coloca la host key y
  las credenciales en almacenamiento cifrado por dispositivo, legible antes de desbloquear el
  dispositivo. Déjalo desactivado salvo que necesites SSH antes del desbloqueo.
- Mantén el reenvío desactivado salvo que lo necesites (está desactivado por defecto).

## Qué hace VD Dropbear para ayudar

- Un banner de versión neutro y poco informativo para que los escáneres de red no puedan identificar el
  servidor y la versión exactos.
- Credenciales en almacenamiento cifrado por credenciales por defecto (descifrado solo después de que
  desbloquees).
- Sin telemetría, sin llamadas de red propias, sin analíticas. Se ejecuta por completo en tu dispositivo.

## Versiones compatibles

Las correcciones de seguridad llegan a la última versión. El binario del servidor sigue a Dropbear
upstream; las versiones de seguridad de upstream se recompilan y se distribuyen en cuanto la CI las
recoge.

## Reportar una vulnerabilidad

Por favor, reporta los problemas de seguridad de forma privada, no en una incidencia pública:

- **Correo electrónico:** vd.priv8@pm.me
- **Telegram:** [@VD_Priv8](https://t.me/VD_Priv8)

Incluye la versión, una descripción y (a ser posible) una forma de reproducirlo. Recibirás un acuse de
recibo, y coordinaremos contigo un arreglo y un calendario de divulgación. Para vulnerabilidades en
Dropbear mismo, repórtalas también a upstream en <https://matt.ucc.asn.au/dropbear/>.
