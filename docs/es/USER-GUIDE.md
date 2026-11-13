<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk - no invasive ADB exposure.
   User guide.

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

> **Languages:** [English](../USER-GUIDE.md) · [العربية](../ar/USER-GUIDE.md) · [Čeština](../cs/USER-GUIDE.md) · [Deutsch](../de/USER-GUIDE.md) · Español · [فارسی](../fa/USER-GUIDE.md) · [Français](../fr/USER-GUIDE.md) · [हिन्दी](../hi/USER-GUIDE.md) · [Bahasa Indonesia](../in/USER-GUIDE.md) · [Italiano](../it/USER-GUIDE.md) · [日本語](../ja/USER-GUIDE.md) · [한국어](../ko/USER-GUIDE.md) · [Nederlands](../nl/USER-GUIDE.md) · [Polski](../pl/USER-GUIDE.md) · [Português](../pt/USER-GUIDE.md) · [Русский](../ru/USER-GUIDE.md) · [Svenska](../sv/USER-GUIDE.md) · [ไทย](../th/USER-GUIDE.md) · [Türkçe](../tr/USER-GUIDE.md) · [Українська](../uk/USER-GUIDE.md) · [Tiếng Việt](../vi/USER-GUIDE.md) · [中文](../zh/USER-GUIDE.md)

---

# Guía del usuario

VD Dropbear le da a tu dispositivo rooteado un servidor SSH privado. Esta guía te lleva desde la
instalación hasta una conexión en funcionamiento, incluida la transferencia de archivos y el modo antes
del primer desbloqueo (BFU).

> **Cada conexión autenticada obtiene una shell root.** Prefiere las claves a las contraseñas, haz el
> bind solo a redes en las que confíes y nunca expongas el puerto a la Internet abierta sin un motivo.

## 1. Instalar

Flashea el zip del módulo en el gestor de **KernelSU**, **APatch** o **Magisk** (o desde una shell con
`ksud module install` / `apd module install`), luego abre la **WebUI** del módulo.

## 2. Añadir una clave (recomendado)

En la WebUI, bajo **Authorized keys**, pega tu clave pública (`ssh-ed25519 AAAA... you@host`) y pulsa
**Add key**. Las claves son lo predeterminado y la forma más segura de entrar.

Para generar una clave en tu ordenador, si no tienes una:

```sh
ssh-keygen -t ed25519 -C "you@host"
cat ~/.ssh/id_ed25519.pub     # paste this into the WebUI
```

## 3. O establecer una contraseña

El inicio de sesión por contraseña está desactivado por defecto (cada inicio de sesión es root, así que
se prefieren las claves). Para activarlo, enciende **Password login** en los ajustes, luego bajo
**Password accounts** establece una contraseña para el usuario de inicio de sesión. El hash se calcula
en tu navegador con PBKDF2; la contraseña en sí nunca sale de la página.

## 4. Elegir un puerto y dónde escuchar

Bajo **Settings**, establece el **Port** y elige los binds. Por defecto VD Dropbear escucha solo en
**loopback**; para llegar a él desde tu LAN o una VPN, habilita las interfaces que quieras. Evita
**Listen on all interfaces** salvo que entiendas la exposición que supone.

Pulsa **Save & restart** para aplicar, luego **Start** si no está ya en marcha.

## 5. Conectar

```sh
ssh -p 2222 root@<device-ip>
sftp -P 2222 root@<device-ip>
scp -P 2222 file root@<device-ip>:/sdcard/
rsync -e 'ssh -p 2222' -av ./dir/ root@<device-ip>:/sdcard/dir/
```

`sftp-server`, `scp` y `rsync` vienen incluidos, así que SFTP, `sshfs`, los clientes gráficos y las
copias de seguridad funcionan todos sobre la misma conexión.

## 6. Antes del primer desbloqueo (BFU)

Por defecto el daemon se inicia solo **después** de que desbloquees el dispositivo una vez (AFU), porque
sus secretos residen en almacenamiento cifrado por credenciales. Si necesitas SSH **antes** del primer
desbloqueo - por ejemplo, para desbloquear un dispositivo de forma remota tras un reinicio - activa
**Start before first unlock (BFU)**. Los secretos se mueven entonces a almacenamiento cifrado por
dispositivo, que es legible antes del desbloqueo: un compromiso deliberado y documentado. Consulta
[Modelo de seguridad](#) en el README.

## 7. Controlar el daemon

- **WebUI:** Start / Stop / Restart, y estado en vivo (en ejecución, PID, puerto, modo, huella de la host
  key).
- **Botón Action del gestor:** (re)lanza el daemon.
- También se inicia automáticamente en el arranque (salvo que lo deshabilites).

## Resolución de problemas

- **No arranca.** Revisa `/data/adb/vddropbear/state/daemon.log`. Asegúrate de que **Enabled** esté
  activado y de que se haya podido generar una host key.
- **Clave rechazada.** Confirma que la línea de la clave pública es exactamente la que ofrece tu cliente,
  y que el usuario de inicio de sesión es uno que el sistema resuelva (normalmente `root`).
- **No puedo conectar desde otra máquina.** Probablemente sigues con el bind solo a loopback - habilita
  la interfaz que necesites y reinicia.
- **SFTP/scp falla pero la shell funciona.** Asegúrate de que el `sftp-server` incluido se distribuyó
  para tu ABI; el estado de la WebUI muestra la ABI detectada.
