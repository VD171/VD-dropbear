<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk. No invasive ADB exposure.

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

<p align="center">
  <img src="module/webroot/assets/logo-wordmark.svg" alt="VD Dropbear" width="540">
</p>

# VD Dropbear

<p>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-Apache--2.0-1a7f37" alt="License"></a>
  <img src="https://img.shields.io/badge/KernelSU-%E2%9C%94-635bff" alt="KernelSU">
  <img src="https://img.shields.io/badge/APatch-%E2%9C%94-ff7043" alt="APatch">
  <img src="https://img.shields.io/badge/Magisk-%E2%9C%94-00af9c" alt="Magisk">
  <a href="https://github.com/VD171/VD-dropbear/stargazers"><img src="https://img.shields.io/github/stars/VD171/VD-dropbear?color=d29922" alt="Stars"></a>
  <a href="https://github.com/VD171/VD-dropbear/releases"><img src="https://img.shields.io/github/v/release/VD171/VD-dropbear?color=1a7f37" alt="Release"></a>
</p>

**Un servidor SSH [Dropbear](https://matt.ucc.asn.au/dropbear/) independiente y totalmente configurable**,
empaquetado como módulo de KernelSU / APatch / Magisk. Se inicia por sí solo y no depende de ningún otro módulo.

> ⚠️ **Toda conexión que se autentica obtiene una shell ROOT.** Trátala como las llaves del
> dispositivo: prioriza las claves públicas sobre las contraseñas y mantén el puerto fuera de la
> Internet pública.

Languages: English · [العربية](README.ar.md) · [Čeština](README.cs.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [فارسی](README.fa.md) · [Français](README.fr.md) · [हिन्दी](README.hi.md) · [Bahasa](README.in.md) · [Italiano](README.it.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Nederlands](README.nl.md) · [Polski](README.pl.md) · [Português](README.pt.md) · [Русский](README.ru.md) · [Svenska](README.sv.md) · [ไทย](README.th.md) · [Türkçe](README.tr.md) · [Українська](README.uk.md) · [Tiếng Việt](README.vi.md) · [中文](README.zh.md)

## Por qué

La forma que Android trae de serie para obtener una shell en tu propio teléfono es ADB (depuración
por USB), y activarla es invasivo y te delata a ti mismo. `adb_enabled` y
`development_settings_enabled` son ajustes legibles por cualquiera: cualquier app, SDK o biblioteca
antifraude / RASP puede leerlos, la conexión queda registrada y no hay forma admitida de ocultar que
ADB está, o estuvo alguna vez, activado. La exposición te sigue incluso en un teléfono de fábrica y sin
root: para conseguir una shell, tienes que anunciarlo.

VD Dropbear es la alternativa privada. En un dispositivo con root te da un servidor SSH de verdad:
shell de root, SFTP y rsync por la red, sin el delator `adb_enabled`, sin la bandera de depuración por
USB, con un banner de versión que no revela nada y con credenciales que tú controlas. Tu acceso sigue
siendo tuyo, en lugar de una bandera de "me están depurando" legible globalmente que cualquier cosa en
el dispositivo puede leer.

## Características

- **Un demonio, siempre.** Arranca en el inicio y desde el botón **Action** del gestor, y puedes
  **iniciarlo / detenerlo / reiniciarlo** desde la WebUI en cualquier momento; nunca más de una
  instancia.
- **Todo es configurable** desde la WebUI (o `/data/adb/vddropbear/config`):
  - puerto, y enlace a loopback / todos / IPv4 / IPv6 / direcciones concretas
  - **iniciar antes del primer desbloqueo (BFU) o solo después (AFU)**, un único interruptor
  - autenticación por clave pública y/o contraseña, intentos máximos de autenticación
  - usuario de inicio de sesión, shell, `HOME`, entorno adicional
  - tiempo de inactividad, keepalive, ventana de recepción
  - reenvío de puertos local / remoto y gateway ports (todo **desactivado** por defecto)
  - tipo de clave de host (ed25519 / rsa / ecdsa)
- **Banner de versión oculto.** El protocolo SSH exige *un* banner, así que no se puede eliminar, pero
  VD Dropbear lo sustituye por uno sin información para que los escáneres no puedan identificar con
  exactitud el servidor ni la versión y dirigirle ataques conocidos para esa versión.
- **Secretos guardados con criterio** (consulta [Modelo de seguridad](#security-model)).
- **Trae tus propias credenciales.** Añade conjuntos de `user + key` y `user + password`; la WebUI
  exige una fortaleza mínima de contraseña y nunca guarda una contraseña en texto plano.
- **Transferencia y sincronización de archivos integradas.** El paquete incluye `sftp-server`, `scp` y
  `rsync`, de modo que SFTP, sshfs, los clientes gráficos y las copias de seguridad funcionan todos por
  la misma conexión.
- **Todo dispositivo y emulador.** `arm64-v8a`, `armeabi-v7a`, `x86`, `x86_64`.

## Agentes de IA en tu dispositivo

Un punto de acceso SSH permanente convierte tu teléfono en algo que un **agente de IA autónomo puede
operar directamente**. Cualquier agente capaz de manejar una shell o una conexión SSH (Claude Code,
aider, un script con un LLM en el bucle, tu propia automatización) obtiene una sesión de root real en
el dispositivo, por la red, sin cable USB y sin ninguna de las banderas de depuración delatoras de ADB.
El agente ve una shell normal, al estilo de Linux, y puede:

- leer y editar archivos, cambiar ajustes y gestionar módulos, paquetes y servicios;
- clasificar registros, extraer artefactos y ejecutar diagnósticos o análisis forense cuando haga falta;
- mover y sincronizar archivos en ambos sentidos por `scp` / `sftp` / `rsync`, para copias de seguridad, migraciones o aprovisionamiento;
- gobernar toda una flota de dispositivos con root desde un solo lugar, cada uno accesible por su propia clave.

Como el proyecto está construido para ser **compatible con la IA** (un archivo de configuración
documentado, un [contrato de entorno](patches/README.md) explícito en tiempo de ejecución, rutas
predecibles y estado en texto plano), un agente puede descubrir cómo usarlo sin adivinar.

> **Esto es root, así que trátalo como root.** Toda conexión autenticada entra como root (consulta la
> advertencia de abajo). Cuando entregues el acceso a un agente, dale un **usuario y una clave
> dedicados**, acota los enlaces a las redes en las que confías (loopback o una VPN en vez de la
> internet abierta), mantén la autenticación por contraseña desactivada y recuerda que puedes revocar
> una clave o detener el demonio en cualquier momento desde la WebUI.

## Instalación

Flashea el zip del módulo en el gestor de KernelSU, APatch o Magisk (o desde la línea de comandos con
`ksud module install` / `apd module install`), abre la **WebUI** del módulo para fijar el puerto y
añadir tus claves, y luego reinicia (o pulsa **Action** para iniciarlo ahora).

## Modelo de seguridad

### Dónde viven los secretos: BFU vs AFU

`/data/adb` es almacenamiento **cifrado por dispositivo (DE)**: se descifra *antes* de que el usuario
desbloquee el teléfono (Before First Unlock), así que cualquier cosa ahí es legible antes del
desbloqueo. `/data/misc_ce` está **cifrado por credencial (CE)**: Android lo mantiene cifrado hasta que
el usuario desbloquea (After First Unlock).

- **Modo AFU (predeterminado, `START_IN_BFU=0`):** el demonio espera al desbloqueo y lee su clave de
  host, `authorized_keys` y los hashes de contraseña desde el almacenamiento CE. Máxima protección; SSH
  funciona solo después de que el dispositivo se haya desbloqueado una vez desde el arranque.
- **Modo BFU (`START_IN_BFU=1`):** el demonio arranca antes del desbloqueo para que puedas entrar por
  SSH temprano (por ejemplo, para desbloquear el dispositivo de forma remota). Sus secretos viven
  entonces en el almacenamiento DE y son legibles antes del desbloqueo, un compromiso deliberado y
  documentado. Actívalo solo si necesitas SSH antes del desbloqueo.

Deliberadamente **no** añadimos nuestro propio cifrado encima de CE: ya está cifrado con la credencial
del usuario, y superponer otro cifrado necesitaría una clave que tendría que vivir en algún sitio (en
DE quedaría expuesta; derivarla de la credencial del usuario no es más que reimplementar CE). Eso daría
una falsa sensación de seguridad, no una protección real.

### Contraseñas

El inicio de sesión por contraseña está **desactivado por defecto**, porque todo inicio de sesión es
root y las claves son mucho más seguras. Cuando sí estableces una contraseña, la WebUI exige una
fortaleza mínima y guarda solo un hash, nunca texto plano.

## Compilación

El binario del servidor lo compila el CI a partir del **upstream [mkj/dropbear](https://github.com/mkj/dropbear)**
con un conjunto de parches pequeño y auditable (consulta [`patches/`](patches/)): una cadena de
identidad neutral/configurable, rutas dirigidas por configuración para `authorized_keys` y el archivo
de contraseñas, y el arreglo `openpty` de Android para PTY interactivas. Un flujo de trabajo programado
sigue al upstream y reconstruye, de modo que el módulo se mantiene al día. Consulta
[`.github/workflows/`](.github/workflows/) y [`CONTRIBUTING.md`](CONTRIBUTING.md).

## Documentación

<!-- vd-docs -->
La documentación completa está en la [wiki](https://github.com/VD171/VD-dropbear/wiki) y bajo
[`docs/`](docs/).
<!-- /vd-docs -->

## Véase también

Proyectos hermanos del mismo autor:

- **[VDInfos](https://github.com/VD171/VD-Infos)**: un depurador de métodos del dispositivo que lee cada elemento a través de cada método que puede leerlo y los compara lado a lado.
- **[VDGoogle](https://github.com/VD171/VD-Google)**: tus servicios de Google (RCS, Wallet, atestaciones de Play Integrity), leídos en tu dispositivo y sin internet.
- **[VDBackup](https://github.com/VD171/VD-Backup)**: copia de seguridad y restauración completas de apps y datos como root, gobernadas por entero desde una WebUI.
- **[COPG-VD](https://github.com/VD171/COPG-VD)**: un spoofer global de huella del dispositivo y de build.

## Contactos

* https://vd171.ru
* https://vd.priv8.ru
* **Telegram:** @VD_Priv8 https://t.me/VD_Priv8
* **Channel:** @Priv8_VD https://t.me/Priv8_VD
* **Discord:** @VD.Priv8 https://discord.com/users/1296831918989639721
* **E-mail:** vd.priv8@pm.me
* **XDA-Developers:** @VD171 https://xdaforums.com/m/vd171.4699873/
* **XDA thread:** _(marcador de posición, se añadirá en el primer lanzamiento público)_
* **GitHub:** @VD171 https://github.com/VD171

## Licencia

El código propio de VD Dropbear es **Apache-2.0**; consulta [LICENSE](LICENSE). El módulo también
incluye binarios de terceros: [Dropbear](https://matt.ucc.asn.au/dropbear/) (estilo MIT), el
`sftp-server` y `scp` de OpenSSH (BSD), y `rsync` (GPL-3.0), cada uno bajo su propia licencia;
consulta [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md), incluido cómo cumplimos la GPL para rsync.
Nuestro código Apache-2.0 no se ve afectado (el binario GPL está meramente agregado, no enlazado).

## Marcas

VD Dropbear es un proyecto independiente y no oficial, sin afiliación ni respaldo de ningún tercero.
"Android" es una marca de Google LLC; "SSH" es una marca registrada de SSH Communications Security.
VD Dropbear se ejecuta por completo en tu dispositivo.

## Tags

`SSH` `Dropbear` `KernelSU` `Magisk` `APatch` `root` `sshd` `remote-access` `openssh-alternative` `Android` `BFU` `VD-dropbear`
