<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk. No invasive ADB exposure.
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
   XDA thread     : https://xdaforums.com/t/VD-Dropbear.4808524/
   Telegram       : @VD_Priv8 https://t.me/VD_Priv8
   Channel        : @Priv8_VD https://t.me/Priv8_VD
   Discord        : @VD.Priv8 https://discord.com/users/1296831918989639721
   E-mail         : vd.priv8@pm.me
  ======================================================================
-->

> **Languages:** [English](../AI-AGENTS.md) · [العربية](../ar/AI-AGENTS.md) · [Čeština](../cs/AI-AGENTS.md) · [Deutsch](../de/AI-AGENTS.md) · Español · [فارسی](../fa/AI-AGENTS.md) · [Français](../fr/AI-AGENTS.md) · [हिन्दी](../hi/AI-AGENTS.md) · [Bahasa Indonesia](../in/AI-AGENTS.md) · [Italiano](../it/AI-AGENTS.md) · [日本語](../ja/AI-AGENTS.md) · [한국어](../ko/AI-AGENTS.md) · [Nederlands](../nl/AI-AGENTS.md) · [Polski](../pl/AI-AGENTS.md) · [Português](../pt/AI-AGENTS.md) · [Русский](../ru/AI-AGENTS.md) · [Svenska](../sv/AI-AGENTS.md) · [ไทย](../th/AI-AGENTS.md) · [Türkçe](../tr/AI-AGENTS.md) · [Українська](../uk/AI-AGENTS.md) · [Tiếng Việt](../vi/AI-AGENTS.md) · [中文](../zh/AI-AGENTS.md)

---

# Agentes de IA en tu dispositivo

Un punto de acceso SSH permanente convierte tu teléfono en algo que un **agente de IA autónomo puede
operar directamente**. Cualquier agente capaz de manejar una shell o una conexión SSH (Claude Code,
aider, un script con un LLM en el bucle, tu propia automatización) obtiene una sesión root real en el
dispositivo, a través de la red, sin cable USB y sin ninguno de los indicadores de depuración de ADB
que se delatan a sí mismos.

Esta página amplía la idea presentada en el README.

## Por qué SSH, y no ADB, para los agentes

ADB se delata: `adb_enabled` y `development_settings_enabled` son legibles por cualquiera, la conexión
queda registrada y no hay forma admitida de ocultar que la depuración está (o estuvo) activada. Un
agente que trabaja a través de ADB deja ese rastro en el dispositivo para que cualquier app o SDK
antifraude lo lea. VD Dropbear es la alternativa privada: un inicio de sesión SSH normal, con
credenciales que tú controlas y un banner que no revela nada.

## Qué puede hacer un agente

A través de una sola conexión, un agente ve una shell normal parecida a la de Linux y puede:

- leer y editar archivos, cambiar ajustes y gestionar módulos, paquetes y servicios;
- clasificar registros, extraer artefactos y ejecutar diagnósticos o análisis forenses cuando haga falta;
- mover y sincronizar archivos en ambos sentidos con `scp` / `sftp` / `rsync`: copias de seguridad, migraciones, aprovisionamiento;
- manejar toda una flota de dispositivos rooteados desde un único lugar, cada uno accesible con su propia clave.

Como el proyecto está diseñado para ser **compatible con la IA** (un archivo de configuración
documentado, un [contrato de entorno](../../patches/README.md) explícito en tiempo de ejecución, rutas
predecibles y estado en texto plano), un agente puede descubrir cómo usarlo sin conjeturas.

## Hacerlo de forma segura

Esto es root, así que trátalo como root:

- dale al agente su **propia credencial**, no la tuya personal, y apúntalo a una cuenta de menor privilegio (`shell`) si quieres limitar su alcance;
- limita los binds a redes en las que confíes: loopback o una VPN en lugar de la Internet abierta
  (consulta [Configuración](CONFIGURATION.md));
- mantén la autenticación por contraseña desactivada; una clave es revocable y nunca se teclea;
- puedes revocar una clave o detener el daemon en cualquier momento desde la WebUI;
- recuerda que una conexión por defecto es una sesión root completa: dale al agente solo el alcance que necesita.

## Una configuración mínima

1. Genera un par de claves solo para el agente.
2. Añade su clave pública en la WebUI (**Authorized keys**).
3. Haz el bind solo a loopback o a tu VPN, en un puerto no predeterminado.
4. Apunta la configuración SSH del agente al dispositivo y déjalo trabajar.
