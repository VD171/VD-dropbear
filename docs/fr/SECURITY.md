<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk - no invasive ADB exposure.
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
   XDA thread     : https://xdaforums.com/t/VD-dropbear.4808524/
   Telegram       : @VD_Priv8 https://t.me/VD_Priv8
   Channel        : @Priv8_VD https://t.me/Priv8_VD
   Discord        : @VD.Priv8 https://discord.com/users/1296831918989639721
   E-mail         : vd.priv8@pm.me
  ======================================================================
-->

> **Languages:** [English](../../SECURITY.md) · [العربية](../ar/SECURITY.md) · [Čeština](../cs/SECURITY.md) · [Deutsch](../de/SECURITY.md) · [Español](../es/SECURITY.md) · [فارسی](../fa/SECURITY.md) · Français · [हिन्दी](../hi/SECURITY.md) · [Bahasa Indonesia](../in/SECURITY.md) · [Italiano](../it/SECURITY.md) · [日本語](../ja/SECURITY.md) · [한국어](../ko/SECURITY.md) · [Nederlands](../nl/SECURITY.md) · [Polski](../pl/SECURITY.md) · [Português](../pt/SECURITY.md) · [Русский](../ru/SECURITY.md) · [Svenska](../sv/SECURITY.md) · [ไทย](../th/SECURITY.md) · [Türkçe](../tr/SECURITY.md) · [Українська](../uk/SECURITY.md) · [Tiếng Việt](../vi/SECURITY.md) · [中文](../zh/SECURITY.md)

---

# Politique de sécurité

## La seule chose à comprendre

VD Dropbear démarre un serveur SSH, et **chaque connexion qui s'authentifie avec succès reçoit un shell
root**. La sécurité de votre appareil équivaut donc à la sécurité de la configuration et des identifiants
de ce serveur. Merci de :

- **Préférer les clés publiques aux mots de passe.** La connexion par mot de passe est désactivée par
  défaut.
- Si vous devez utiliser un mot de passe, choisissez-en un robuste - la WebUI impose un minimum et ne
  stocke qu'un hachage.
- **Ne pas exposer le port à l'Internet public.** Faites le bind sur loopback ou un LAN de confiance, ou
  atteignez-le via un VPN / tunnel.
- Comprendre le **compromis BFU** : activer le démarrage avant déverrouillage place la host key et les
  identifiants sur un stockage chiffré par appareil, lisible avant que l'appareil soit déverrouillé.
  Laissez-le désactivé sauf si vous avez besoin de SSH avant le déverrouillage.
- Laisser la redirection désactivée sauf si vous en avez besoin (elle est désactivée par défaut).

## Ce que VD Dropbear fait pour aider

- Une bannière de version neutre et peu informative afin que les scanners réseau ne puissent pas
  identifier le serveur et la version exacts.
- Des identifiants sur un stockage chiffré par identifiants par défaut (déchiffré uniquement après votre
  déverrouillage).
- Pas de télémétrie, pas d'appels réseau propres, pas d'analytique. Il s'exécute entièrement sur votre
  appareil.

## Versions prises en charge

Les correctifs de sécurité arrivent sur la dernière version. Le binaire du serveur suit Dropbear upstream ;
les versions de sécurité d'upstream sont recompilées et livrées dès que la CI les récupère.

## Signaler une vulnérabilité

Merci de signaler les problèmes de sécurité en privé, pas dans un ticket public :

- **E-mail :** vd.priv8@pm.me
- **Telegram :** [@VD_Priv8](https://t.me/VD_Priv8)

Incluez la version, une description et (idéalement) un moyen de reproduire. Vous recevrez un accusé de
réception, et nous coordonnerons avec vous un correctif et un calendrier de divulgation. Pour les
vulnérabilités dans Dropbear lui-même, signalez-les aussi à upstream sur
<https://matt.ucc.asn.au/dropbear/>.
