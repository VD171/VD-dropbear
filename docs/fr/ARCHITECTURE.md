<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk - no invasive ADB exposure.
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

> **Languages:** [English](../ARCHITECTURE.md) · [العربية](../ar/ARCHITECTURE.md) · [Čeština](../cs/ARCHITECTURE.md) · [Deutsch](../de/ARCHITECTURE.md) · [Español](../es/ARCHITECTURE.md) · [فارسی](../fa/ARCHITECTURE.md) · Français · [हिन्दी](../hi/ARCHITECTURE.md) · [Bahasa Indonesia](../in/ARCHITECTURE.md) · [Italiano](../it/ARCHITECTURE.md) · [日本語](../ja/ARCHITECTURE.md) · [한국어](../ko/ARCHITECTURE.md) · [Nederlands](../nl/ARCHITECTURE.md) · [Polski](../pl/ARCHITECTURE.md) · [Português](../pt/ARCHITECTURE.md) · [Русский](../ru/ARCHITECTURE.md) · [Svenska](../sv/ARCHITECTURE.md) · [ไทย](../th/ARCHITECTURE.md) · [Türkçe](../tr/ARCHITECTURE.md) · [Українська](../uk/ARCHITECTURE.md) · [Tiếng Việt](../vi/ARCHITECTURE.md) · [中文](../zh/ARCHITECTURE.md)

---

# Architecture

VD Dropbear est un module KernelSU / APatch / Magisk qui exécute exactement un démon SSH Dropbear,
piloté entièrement par la configuration. Rien du serveur SSH n'est codé en dur pour un appareil précis ;
tout ce qui est spécifique est de la configuration à l'exécution ou un secret.

## Les pièces

- `module/common/vddropbear.sh` - la bibliothèque centrale : charger la configuration (avec des valeurs
  par défaut intégrées et sûres), résoudre le magasin de secrets, garantir une host key, construire le
  vecteur d'arguments de Dropbear et gérer une unique instance du démon (start / stop / status /
  restart).
- `module/service.sh` - point d'entrée au démarrage. Respecte la politique de démarrage BFU/AFU ; en
  mode AFU, il attend que le stockage chiffré par identifiants se déverrouille sans bloquer le démarrage.
- `module/action.sh` - le bouton **Action** du gestionnaire : (re)lancer le démon. Il ne lit jamais
  stdin et détache le démon dans sa propre session, de sorte que le gestionnaire ne se fige pas.
- `module/common/vddb-webui.sh` + `module/webroot/index.html` - le backend et la page de la WebUI.
- `patches/` - de petits correctifs auditables appliqués à Dropbear upstream au moment de la compilation.
- `scripts/build.sh`, `scripts/build-bundles.sh`, `.github/workflows/build.yml` - la compilation.

## Cycle de vie du démon (instance unique)

`vddb_start` charge la configuration, arrête toute instance en cours, garantit l'existence d'une host key,
puis lance un unique démon. Le binaire est livré sous le nom `vddropbear`, de sorte que son nom de
processus correspond exactement à `pgrep -x` (le `mksh` d'Android n'a pas `exec -a`). Il est lancé avec
`setsid` pour se détacher du groupe de processus de l'appelant - c'est ce qui empêche l'Action du
gestionnaire de se bloquer.

## Le magasin de secrets (CE vs DE, BFU vs AFU)

Les réglages ne sont pas secrets et résident dans un stockage chiffré par appareil
(`/data/adb/vddropbear`), lisible au démarrage. Les secrets - host key, `authorized_keys`, hachages de
mots de passe - résident par défaut dans un stockage **chiffré par identifiants**
(`/data/misc_ce/0/vddropbear`), qui ne se déverrouille qu'après authentification de l'utilisateur.
Activer `START_IN_BFU` déplace les secrets vers le stockage chiffré par appareil afin que le démon puisse
s'exécuter avant le premier déverrouillage, au prix de secrets lisibles plus tôt. Le module calcule quel
magasin utiliser à chaque étape du démarrage.

## Le jeu de correctifs

Le serveur SSH reste Dropbear upstream ; nos modifications se limitent à quelques correctifs relisibles
(voir [patches/README.md](../../patches/README.md)) :

- une bannière d'identité neutre, configurable à l'exécution ;
- `authorized_keys` lu depuis un chemin fixé par l'environnement (afin que les clés vivent dans le
  magasin de secrets) ;
- l'authentification par mot de passe contre un fichier de hachage PBKDF2 plutôt que la fonction
  `crypt()`/shadow du système, qui manque à Android (voir [BUILDING.md](../BUILDING.md)).

## La WebUI

Une page statique dans la WebUI du gestionnaire (KernelSU / APatch / WebUI-X). Elle pilote
`module/common/vddb-webui.sh` via le pont `ksu.exec` : état, start/stop/restart, lecture/écriture de la
configuration, et gestion des clés et des comptes avec mot de passe. Toutes les données traversent le
pont encodées en base64, de sorte que le shell ne les interprète jamais ; les hachages de mots de passe
sont calculés dans le navigateur avec WebCrypto, si bien que le mot de passe en clair ne quitte jamais la
page.
