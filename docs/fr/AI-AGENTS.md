<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk - no invasive ADB exposure.
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

> **Languages:** [English](../AI-AGENTS.md) · [العربية](../ar/AI-AGENTS.md) · [Čeština](../cs/AI-AGENTS.md) · [Deutsch](../de/AI-AGENTS.md) · [Español](../es/AI-AGENTS.md) · [فارسی](../fa/AI-AGENTS.md) · Français · [हिन्दी](../hi/AI-AGENTS.md) · [Bahasa Indonesia](../in/AI-AGENTS.md) · [Italiano](../it/AI-AGENTS.md) · [日本語](../ja/AI-AGENTS.md) · [한국어](../ko/AI-AGENTS.md) · [Nederlands](../nl/AI-AGENTS.md) · [Polski](../pl/AI-AGENTS.md) · [Português](../pt/AI-AGENTS.md) · [Русский](../ru/AI-AGENTS.md) · [Svenska](../sv/AI-AGENTS.md) · [ไทย](../th/AI-AGENTS.md) · [Türkçe](../tr/AI-AGENTS.md) · [Українська](../uk/AI-AGENTS.md) · [Tiếng Việt](../vi/AI-AGENTS.md) · [中文](../zh/AI-AGENTS.md)

---

# Les agents IA sur votre appareil

Un point d'accès SSH permanent transforme votre téléphone en quelque chose qu'un **agent IA autonome
peut piloter directement**. Tout agent capable de piloter un shell ou une connexion SSH - Claude Code,
aider, un script avec un LLM dans la boucle, votre propre automatisation - obtient une véritable session
root sur l'appareil, par le réseau, sans câble USB et sans aucun des indicateurs de débogage d'ADB qui
se trahissent eux-mêmes.

Cette page développe l'idée présentée dans le README.

## Pourquoi SSH, et non ADB, pour les agents

ADB se signale lui-même : `adb_enabled` et `development_settings_enabled` sont lisibles par tous, la
connexion est journalisée, et il n'existe aucun moyen pris en charge de cacher que le débogage est (ou a
été) activé. Un agent qui travaille via ADB laisse cette trace sur l'appareil, lisible par n'importe
quelle application ou n'importe quel SDK antifraude. VD Dropbear est l'alternative privée - une connexion
SSH normale, avec des identifiants que vous contrôlez et une bannière qui ne révèle rien.

## Ce qu'un agent peut faire

Au cours d'une seule connexion, un agent voit un shell normal de type Linux et peut :

- lire et modifier des fichiers, changer des réglages et gérer des modules, des paquets et des services ;
- trier les journaux, récupérer des artefacts et lancer des diagnostics ou des analyses forensiques à la demande ;
- déplacer et synchroniser des fichiers dans les deux sens via `scp` / `sftp` / `rsync` - sauvegardes, migrations, provisionnement ;
- piloter toute une flotte d'appareils rootés depuis un seul endroit, chacun accessible par sa propre clé.

Comme le projet est conçu pour être **compatible avec l'IA** - un fichier de configuration documenté, un
[contrat d'environnement](../../patches/README.md) explicite à l'exécution, des chemins prévisibles et un
état en texte clair - un agent peut découvrir comment l'utiliser sans deviner.

## Le faire en toute sécurité

C'est du root, alors traitez-le comme du root :

- donnez à l'agent un **utilisateur et une clé dédiés**, pas les vôtres ;
- limitez les binds aux réseaux de confiance - loopback ou un VPN plutôt que l'Internet ouvert
  (voir [Configuration](CONFIGURATION.md)) ;
- laissez l'authentification par mot de passe désactivée ; une clé est révocable et ne se tape jamais ;
- vous pouvez révoquer une clé ou arrêter le démon à tout moment depuis la WebUI ;
- rappelez-vous que chaque connexion est une session root complète - ne donnez à l'agent que la portée dont il a besoin.

## Une configuration minimale

1. Générez une paire de clés rien que pour l'agent.
2. Ajoutez sa clé publique dans la WebUI (**Authorized keys**).
3. Faites le bind uniquement sur loopback ou votre VPN, sur un port non par défaut.
4. Pointez la configuration SSH de l'agent vers l'appareil et laissez-le travailler.
