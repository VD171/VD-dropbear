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
   XDA thread     : https://xdaforums.com/t/VD-dropbear.4808524/
   Telegram       : @VD_Priv8 https://t.me/VD_Priv8
   Channel        : @Priv8_VD https://t.me/Priv8_VD
   Discord        : @VD.Priv8 https://discord.com/users/1296831918989639721
   E-mail         : vd.priv8@pm.me
  ======================================================================
-->

> **Languages:** [English](../../CONTRIBUTING.md) · [العربية](../ar/CONTRIBUTING.md) · [Čeština](../cs/CONTRIBUTING.md) · [Deutsch](../de/CONTRIBUTING.md) · [Español](../es/CONTRIBUTING.md) · [فارسی](../fa/CONTRIBUTING.md) · Français · [हिन्दी](../hi/CONTRIBUTING.md) · [Bahasa Indonesia](../in/CONTRIBUTING.md) · [Italiano](../it/CONTRIBUTING.md) · [日本語](../ja/CONTRIBUTING.md) · [한국어](../ko/CONTRIBUTING.md) · [Nederlands](../nl/CONTRIBUTING.md) · [Polski](../pl/CONTRIBUTING.md) · [Português](../pt/CONTRIBUTING.md) · [Русский](../ru/CONTRIBUTING.md) · [Svenska](../sv/CONTRIBUTING.md) · [ไทย](../th/CONTRIBUTING.md) · [Türkçe](../tr/CONTRIBUTING.md) · [Українська](../uk/CONTRIBUTING.md) · [Tiếng Việt](../vi/CONTRIBUTING.md) · [中文](../zh/CONTRIBUTING.md)

---

# Contribuer à VD Dropbear

Merci de votre intérêt. C'est un petit projet sensible à la sécurité (il distribue du root), donc les
changements sont relus avec cela à l'esprit.

## Organisation du dépôt

```
module/     the installable KernelSU / APatch / Magisk module (scripts, WebUI, config, installer)
patches/    the patch set applied on top of upstream Dropbear (the only changes to the SSH server)
src/        where CI unpacks upstream Dropbear to build (not committed)
scripts/    build and maintenance helpers
.github/    CI workflows and issue/PR templates
docs/       documentation (mirrored to the wiki)
```

## Compilation

Le binaire est produit par la CI à partir de **[mkj/dropbear](https://github.com/mkj/dropbear) upstream**
plus les correctifs de `patches/`. Pour compiler en local, il vous faut le NDK Android :

```sh
scripts/build.sh            # fetches the tracked upstream, applies patches, builds arm64 + arm32
```

Le jeu de correctifs est délibérément minimal et auditable : une chaîne d'identité neutre/configurable,
des chemins pilotés par la configuration pour `authorized_keys` et le fichier de mots de passe, le
correctif `openpty` d'Android, et la configuration à l'exécution. Merci de garder les nouveaux correctifs
petits, documentés et justifiés dans la PR.

## Pull requests

- Un changement logique par PR ; décrivez la motivation et l'impact sur la sécurité.
- Respectez le style de shell existant (POSIX `sh` / `mksh` d'Android ; pas de bashismes).
- Chaque fichier porte un court en-tête SPDX - conservez-le.
- Mettez à jour [`CHANGELOG.md`](../../CHANGELOG.md) sous `[Unreleased]` pour tout changement réel et visible par l'utilisateur.
- En soumettant une PR, vous acceptez de licencier votre contribution sous la licence [Apache-2.0](../../LICENSE) du projet.

## Traductions

Le README et la documentation sont maintenus dans de nombreuses langues (`README.<lang>.md`). L'anglais
est la source de vérité ; les traductions le suivent. Si vous améliorez une traduction ou ajoutez une
langue, gardez la structure et les ancres de section identiques à la version anglaise.

## Signaler des bugs et des problèmes de sécurité

Utilisez les modèles de tickets pour les bugs et les demandes de fonctionnalités. Pour tout ce qui
pourrait compromettre un appareil, suivez [`SECURITY.md`](SECURITY.md) et signalez-le en privé plutôt que
d'ouvrir un ticket public.
