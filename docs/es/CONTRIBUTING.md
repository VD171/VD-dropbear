<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk - no invasive ADB exposure.
   Contributing guide.

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

> **Languages:** [English](../../CONTRIBUTING.md) · [العربية](../ar/CONTRIBUTING.md) · [Čeština](../cs/CONTRIBUTING.md) · [Deutsch](../de/CONTRIBUTING.md) · Español · [فارسی](../fa/CONTRIBUTING.md) · [Français](../fr/CONTRIBUTING.md) · [हिन्दी](../hi/CONTRIBUTING.md) · [Bahasa Indonesia](../in/CONTRIBUTING.md) · [Italiano](../it/CONTRIBUTING.md) · [日本語](../ja/CONTRIBUTING.md) · [한국어](../ko/CONTRIBUTING.md) · [Nederlands](../nl/CONTRIBUTING.md) · [Polski](../pl/CONTRIBUTING.md) · [Português](../pt/CONTRIBUTING.md) · [Русский](../ru/CONTRIBUTING.md) · [Svenska](../sv/CONTRIBUTING.md) · [ไทย](../th/CONTRIBUTING.md) · [Türkçe](../tr/CONTRIBUTING.md) · [Українська](../uk/CONTRIBUTING.md) · [Tiếng Việt](../vi/CONTRIBUTING.md) · [中文](../zh/CONTRIBUTING.md)

---

# Contribuir a VD Dropbear

Gracias por tu interés. Este es un proyecto pequeño y sensible a la seguridad (reparte acceso root), así
que los cambios se revisan con eso presente.

## Estructura del repositorio

```
module/     the installable KernelSU / APatch / Magisk module (scripts, WebUI, config, installer)
patches/    the patch set applied on top of upstream Dropbear (the only changes to the SSH server)
src/        where CI unpacks upstream Dropbear to build (not committed)
scripts/    build and maintenance helpers
.github/    CI workflows and issue/PR templates
docs/       documentation (mirrored to the wiki)
```

## Compilación

El binario lo produce la CI a partir de **[mkj/dropbear](https://github.com/mkj/dropbear) upstream** más
los parches de `patches/`. Para compilar en local necesitas el NDK de Android:

```sh
scripts/build.sh            # fetches the tracked upstream, applies patches, builds arm64 + arm32
```

El conjunto de parches es deliberadamente mínimo y auditable: una cadena de identidad neutra/configurable,
rutas gobernadas por configuración para `authorized_keys` y el archivo de contraseñas, el arreglo de
`openpty` para Android y la configuración en tiempo de ejecución. Por favor, mantén los parches nuevos
pequeños, documentados y justificados en la PR.

## Pull requests

- Un cambio lógico por PR; describe la motivación y el impacto en seguridad.
- Respeta el estilo de shell existente (POSIX `sh` / `mksh` de Android; sin bashismos).
- Cada archivo lleva una breve cabecera SPDX - consérvala.
- Actualiza [`CHANGELOG.md`](../../CHANGELOG.md) bajo `[Unreleased]` para cualquier cambio real y visible para el usuario.
- Al enviar una PR aceptas licenciar tu contribución bajo la licencia [Apache-2.0](../../LICENSE) del proyecto.

## Traducciones

El README y la documentación se mantienen en muchos idiomas (`README.<lang>.md`). El inglés es la fuente
de verdad; las traducciones lo siguen. Si mejoras una traducción o añades un idioma, mantén la estructura
y los anclajes de sección idénticos a los de la versión en inglés.

## Reportar errores y problemas de seguridad

Usa las plantillas de incidencias para errores y solicitudes de funciones. Para cualquier cosa que pueda
comprometer un dispositivo, sigue [`SECURITY.md`](SECURITY.md) y repórtalo de forma privada en lugar de
abrir una incidencia pública.
