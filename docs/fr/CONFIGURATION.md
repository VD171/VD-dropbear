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
   XDA thread     : https://xdaforums.com/t/VD-dropbear.4808524/
   Telegram       : @VD_Priv8 https://t.me/VD_Priv8
   Channel        : @Priv8_VD https://t.me/Priv8_VD
   Discord        : @VD.Priv8 https://discord.com/users/1296831918989639721
   E-mail         : vd.priv8@pm.me
  ======================================================================
-->

> **Languages:** [English](../CONFIGURATION.md) · [العربية](../ar/CONFIGURATION.md) · [Čeština](../cs/CONFIGURATION.md) · [Deutsch](../de/CONFIGURATION.md) · [Español](../es/CONFIGURATION.md) · [فارسی](../fa/CONFIGURATION.md) · Français · [हिन्दी](../hi/CONFIGURATION.md) · [Bahasa Indonesia](../in/CONFIGURATION.md) · [Italiano](../it/CONFIGURATION.md) · [日本語](../ja/CONFIGURATION.md) · [한국어](../ko/CONFIGURATION.md) · [Nederlands](../nl/CONFIGURATION.md) · [Polski](../pl/CONFIGURATION.md) · [Português](../pt/CONFIGURATION.md) · [Русский](../ru/CONFIGURATION.md) · [Svenska](../sv/CONFIGURATION.md) · [ไทย](../th/CONFIGURATION.md) · [Türkçe](../tr/CONFIGURATION.md) · [Українська](../uk/CONFIGURATION.md) · [Tiếng Việt](../vi/CONFIGURATION.md) · [中文](../zh/CONFIGURATION.md)

---

# Configuration

Les réglages résident dans `/data/adb/vddropbear/config` (initialisés depuis
`module/common/config.default` au premier démarrage). La **WebUI** édite ce fichier pour vous ; vous
pouvez aussi l'éditer à la main. Il est sourcé comme du shell, alors utilisez `KEY=value` sans espaces
autour du `=`. Les réglages ne sont pas secrets et résident dans un stockage chiffré par appareil ; les
secrets (host keys, clés autorisées, hachages de mots de passe) résident dans le magasin de secrets,
jamais ici.

Appliquez les changements en redémarrant le démon (le **Save & restart** de la WebUI le fait).

## Général

| Key | Default | Signification |
|-----|---------|---------|
| `ENABLED` | `1` | Démarre le démon au boot. `0` le désactive entièrement. |
| `START_IN_BFU` | `0` | `0` : démarre uniquement après le premier déverrouillage (AFU) ; les secrets restent sur le stockage chiffré par identifiants (CE). `1` : démarre aussi avant le premier déverrouillage (BFU) ; les secrets passent au stockage chiffré par appareil (DE), lisible avant le déverrouillage. |
| `PORT` | `2222` | Port d'écoute par défaut (les ports par bind peuvent le remplacer dans `LISTEN_ADDRESSES`). |

## Écoute / binds (composables)

Toute combinaison est permise ; les binds sélectionnés sont fusionnés. Si vous videz tout, VD Dropbear
fait le bind sur loopback plutôt que sur chaque interface.

| Key | Default | Signification |
|-----|---------|---------|
| `LISTEN_LOOPBACK` | `1` | Écoute uniquement sur `127.0.0.1` / `::1`. |
| `LISTEN_ALL` | `0` | Écoute sur chaque interface (`0.0.0.0` / `::`) - expose l'appareil. |
| `LISTEN_IPV4` | `1` | Inclut les binds IPv4. |
| `LISTEN_IPV6` | `1` | Inclut les binds IPv6. |
| `LISTEN_ADDRESSES` | `""` | Binds spécifiques supplémentaires, séparés par des virgules : `addr` (utilise `PORT`) ou `addr:port`, IPv4 ou IPv6. |

## Identité

| Key | Default | Signification |
|-----|---------|---------|
| `HIDE_IDENT` | `1` | Envoie une bannière d'identité SSH neutre afin que les scanners ne puissent pas identifier le serveur/la version exacts. |
| `IDENT_STRING` | `""` | Une chaîne d'identité personnalisée. Vide, utilise la valeur neutre intégrée par défaut. |

## Authentification

Chaque connexion authentifiée est **root**. Les clés sont la valeur par défaut ; les mots de passe sont
optionnels.

| Key | Default | Signification |
|-----|---------|---------|
| `PUBKEY_AUTH` | `1` | Autorise la connexion par clé publique (lit les clés autorisées dans le magasin de secrets). |
| `PASSWORD_AUTH` | `0` | Autorise la connexion par mot de passe. Désactivé, le démon démarre avec l'authentification par mot de passe désactivée. |
| `MAX_AUTH_TRIES` | `3` | Nombre maximal de tentatives d'authentification par connexion. |
| `LOGIN_USER` | `root` | Le compte avec lequel se connecter. Doit être un compte que le système résout (généralement `root`). |

## Session / environnement

| Key | Default | Signification |
|-----|---------|---------|
| `LOGIN_SHELL` | `""` | Shell de la session. Vide, utilise celui du compte par défaut. |
| `HOME_DIR` | `""` | `HOME` de la session. Vide, utilise le répertoire du module. |
| `EXTRA_ENV` | `""` | Environnement supplémentaire, `K=V;K2=V2`. |
| `IDLE_TIMEOUT` | `0` | Déconnecte après N secondes d'inactivité. `0` désactive. |
| `KEEPALIVE` | `0` | Envoie un keepalive toutes les N secondes. `0` désactive. |
| `RECEIVE_WINDOW` | `""` | Taille de la fenêtre de réception de Dropbear. Vide, utilise la valeur par défaut. |

## Redirection (désactivée par défaut)

| Key | Default | Signification |
|-----|---------|---------|
| `ALLOW_LOCAL_FORWARD` | `0` | Autorise la redirection de port locale (`-L`). |
| `ALLOW_REMOTE_FORWARD` | `0` | Autorise la redirection de port distante (`-R`). |
| `GATEWAY_PORTS` | `0` | Laisse les ports distants redirigés faire le bind sur toutes les interfaces. |

## Host key

| Key | Default | Signification |
|-----|---------|---------|
| `HOSTKEY_TYPE` | `ed25519` | Type de host key : `ed25519`, `rsa` ou `ecdsa`. Générée au premier démarrage dans le magasin de secrets. |

## Le magasin de secrets

Non configuré ici - résolu à partir de `START_IN_BFU` :

- **AFU (par défaut) :** `/data/misc_ce/0/vddropbear/secret` - chiffré par identifiants, disponible
  uniquement après que vous déverrouillez l'appareil.
- **BFU :** `/data/adb/vddropbear/secret` - chiffré par appareil, lisible avant le premier déverrouillage.

Il contient la host key, `authorized_keys` et le fichier de hachages `passwd`. Voir
[BUILDING.md](../BUILDING.md) pour le format du hachage de mot de passe.
