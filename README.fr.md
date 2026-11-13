<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk - no invasive ADB exposure.

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

**Un serveur SSH [Dropbear](https://matt.ucc.asn.au/dropbear/) autonome et entièrement configurable**,
empaqueté comme module KernelSU / APatch / Magisk. Il démarre tout seul et ne dépend d'aucun autre module.

> ⚠️ **Toute connexion qui s'authentifie obtient un shell ROOT.** Traite cela comme les clés de
> l'appareil : préfère les clés publiques aux mots de passe, et garde le port hors de l'Internet public.

Languages: English · [العربية](README.ar.md) · [Čeština](README.cs.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [فارسی](README.fa.md) · [Français](README.fr.md) · [हिन्दी](README.hi.md) · [Bahasa](README.in.md) · [Italiano](README.it.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Nederlands](README.nl.md) · [Polski](README.pl.md) · [Português](README.pt.md) · [Русский](README.ru.md) · [Svenska](README.sv.md) · [ไทย](README.th.md) · [Türkçe](README.tr.md) · [Українська](README.uk.md) · [Tiếng Việt](README.vi.md) · [中文](README.zh.md)

## Pourquoi

Le moyen intégré d'Android pour obtenir un shell sur son propre téléphone, c'est ADB (débogage USB),
et l'activer est intrusif et vous trahit. `adb_enabled` et `development_settings_enabled` sont des
réglages lisibles par tout le monde - n'importe quelle application, SDK ou bibliothèque antifraude /
RASP peut les lire, la connexion est journalisée, et il n'existe aucun moyen pris en charge de cacher
qu'ADB est, ou a déjà été, activé. Cette exposition vous suit même sur un téléphone d'origine et non
rooté : pour obtenir un shell, vous devez l'annoncer.

VD Dropbear est l'alternative privée. Sur un appareil rooté, il vous donne un vrai serveur SSH - shell
root, SFTP et rsync sur le réseau - sans le signe révélateur `adb_enabled`, sans drapeau de débogage
USB, avec une bannière de version qui ne révèle rien, et avec des identifiants que vous contrôlez.
Votre accès reste le vôtre, au lieu d'un drapeau « je suis en cours de débogage » lisible globalement
que tout ce qui se trouve sur l'appareil peut lire.

## Fonctionnalités

- **Un seul démon, toujours.** Il démarre au boot et depuis le bouton **Action** du gestionnaire, et
  tu peux le **démarrer / arrêter / redémarrer** depuis la WebUI à tout moment ; jamais plus d'une
  instance.
- **Tout est configurable** depuis la WebUI (ou `/data/adb/vddropbear/config`) :
  - le port, et la liaison à loopback / tout / IPv4 / IPv6 / adresses précises
  - **démarrer avant le premier déverrouillage (BFU) ou seulement après (AFU)** - un unique
    interrupteur
  - authentification par clé publique et/ou mot de passe, nombre maximal de tentatives d'authentification
  - utilisateur de connexion, shell, `HOME`, environnement supplémentaire
  - délai d'inactivité, keepalive, fenêtre de réception
  - redirection de ports locale / distante et gateway ports (tout **désactivé** par défaut)
  - type de clé d'hôte (ed25519 / rsa / ecdsa)
- **Bannière de version masquée.** Le protocole SSH exige *une* bannière, elle ne peut donc pas être
  supprimée, mais VD Dropbear la remplace par une bannière sans intérêt pour que les scanners ne
  puissent pas identifier précisément le serveur ou la version et lui lancer des attaques ciblant une
  version connue.
- **Secrets stockés judicieusement** (voir [Modèle de sécurité](#security-model)).
- **Apporte tes propres identifiants.** Ajoute des ensembles `user + key` et `user + password` ; la
  WebUI impose une force minimale de mot de passe et ne stocke jamais un mot de passe en clair.
- **Transfert et synchronisation de fichiers intégrés.** Le paquet livre `sftp-server`, `scp` et
  `rsync`, de sorte que SFTP, sshfs, les clients graphiques et les sauvegardes fonctionnent tous par
  la même connexion.
- **Tout appareil et tout émulateur.** `arm64-v8a`, `armeabi-v7a`, `x86`, `x86_64`.

## Agents IA sur ton appareil

Un point d'accès SSH permanent transforme ton téléphone en quelque chose qu'un **agent IA autonome
peut piloter directement**. Tout agent capable de conduire un shell ou une connexion SSH - Claude
Code, aider, un script avec un LLM dans la boucle, ta propre automatisation - obtient une vraie
session root sur l'appareil, par le réseau, sans câble USB et sans aucun des drapeaux de débogage
révélateurs d'ADB. L'agent voit un shell normal, à la manière de Linux, et peut :

- lire et modifier des fichiers, basculer des réglages et gérer modules, paquets et services ;
- trier des journaux, récupérer des artefacts et exécuter des diagnostics ou de l'analyse forensique à la demande ;
- déplacer et synchroniser des fichiers dans les deux sens via `scp` / `sftp` / `rsync`, pour des sauvegardes, migrations ou provisionnements ;
- piloter toute une flotte d'appareils rootés depuis un seul endroit, chacun joignable par sa propre clé.

Parce que le projet est conçu pour être **compatible avec l'IA** - un fichier de configuration
documenté, un [contrat d'environnement](patches/README.md) d'exécution explicite, des chemins
prévisibles et un état en texte clair - un agent peut découvrir comment l'utiliser sans deviner.

> **C'est du root, alors traite-le comme du root.** Toute connexion authentifiée arrive en root (voir
> l'avertissement ci-dessous). Quand tu confies l'accès à un agent, donne-lui un **utilisateur et une
> clé dédiés**, limite les liaisons aux réseaux auxquels tu fais confiance (loopback ou un VPN plutôt
> que l'internet ouvert), laisse l'authentification par mot de passe désactivée, et souviens-toi que
> tu peux révoquer une clé ou arrêter le démon à tout moment depuis la WebUI.

## Installation

Flashe le zip du module dans le gestionnaire KernelSU, APatch ou Magisk (ou en ligne de commande avec
`ksud module install` / `apd module install`), ouvre la **WebUI** du module pour régler le port et
ajouter tes clés, puis redémarre (ou appuie sur **Action** pour le lancer tout de suite).

## Modèle de sécurité

### Où vivent les secrets : BFU vs AFU

`/data/adb` est un stockage **chiffré au niveau de l'appareil (DE)** : il est déchiffré *avant* que
l'utilisateur déverrouille le téléphone (Before First Unlock), donc tout ce qui s'y trouve est lisible
avant le déverrouillage. `/data/misc_ce` est **chiffré par identifiant (CE)** : Android le garde
chiffré jusqu'à ce que l'utilisateur déverrouille (After First Unlock).

- **Mode AFU (par défaut, `START_IN_BFU=0`) :** le démon attend le déverrouillage et lit sa clé
  d'hôte, `authorized_keys` et les empreintes de mots de passe depuis le stockage CE. Protection
  maximale ; SSH ne fonctionne qu'après que l'appareil a été déverrouillé une fois depuis le boot.
- **Mode BFU (`START_IN_BFU=1`) :** le démon démarre avant le déverrouillage pour que tu puisses te
  connecter en SSH tôt (par exemple, pour déverrouiller l'appareil à distance). Ses secrets vivent
  alors sur le stockage DE et sont lisibles avant le déverrouillage, un compromis délibéré et
  documenté. Ne l'active que si tu as besoin de SSH avant le déverrouillage.

Nous n'ajoutons délibérément **pas** notre propre chiffrement par-dessus CE : il est déjà chiffré avec
l'identifiant de l'utilisateur, et superposer un autre chiffrement nécessiterait une clé qui doit
vivre quelque part (sur DE elle serait exposée ; la dériver de l'identifiant de l'utilisateur ne fait
que réimplémenter CE). Cela donnerait un faux sentiment de sécurité, pas une protection réelle.

### Mots de passe

La connexion par mot de passe est **désactivée par défaut**, car chaque connexion est root et les clés
sont bien plus sûres. Quand tu définis malgré tout un mot de passe, la WebUI impose une force minimale
et ne stocke qu'une empreinte, jamais de texte en clair.

## Compilation

Le binaire du serveur est compilé par la CI à partir de l'**upstream
[mkj/dropbear](https://github.com/mkj/dropbear)** avec un petit jeu de correctifs auditables (voir
[`patches/`](patches/)) : une chaîne d'identité neutre/configurable, des chemins pilotés par la
configuration pour `authorized_keys` et le fichier de mots de passe, et le correctif `openpty`
d'Android pour les PTY interactifs. Un workflow planifié suit l'upstream et recompile, afin que le
module reste à jour. Voir [`.github/workflows/`](.github/workflows/) et
[`CONTRIBUTING.md`](CONTRIBUTING.md).

## Documentation

<!-- vd-docs -->
La documentation complète se trouve dans le [wiki](https://github.com/VD171/VD-dropbear/wiki) et sous
[`docs/`](docs/).
<!-- /vd-docs -->

## Voir aussi

Projets frères du même auteur :

- **[VDInfos](https://github.com/VD171/VD-Infos)** : un débogueur de méthodes de l'appareil qui lit chaque élément par chaque méthode capable de le lire et les compare côte à côte.
- **[VDGoogle](https://github.com/VD171/VD-Google)** : tes services Google (RCS, Wallet, attestations Play Integrity), lus sur ton appareil sans internet.
- **[VDBackup](https://github.com/VD171/VD-Backup)** : sauvegarde et restauration complètes des applications et des données en root, pilotées entièrement depuis une WebUI.
- **[COPG-VD](https://github.com/VD171/COPG-VD)** : un falsificateur global d'empreinte d'appareil et de build.

## Contacts

* https://vd171.ru
* https://vd.priv8.ru
* **Telegram:** @VD_Priv8 https://t.me/VD_Priv8
* **Channel:** @Priv8_VD https://t.me/Priv8_VD
* **Discord:** @VD.Priv8 https://discord.com/users/1296831918989639721
* **E-mail:** vd.priv8@pm.me
* **XDA-Developers:** @VD171 https://xdaforums.com/m/vd171.4699873/
* **XDA thread:** _(espace réservé - ajouté lors de la première publication publique)_
* **GitHub:** @VD171 https://github.com/VD171

## Licence

Le code propre à VD Dropbear est sous **Apache-2.0** - voir [LICENSE](LICENSE). Le module embarque aussi
des binaires tiers - [Dropbear](https://matt.ucc.asn.au/dropbear/) (style MIT), les `sftp-server` et
`scp` d'OpenSSH (BSD), et `rsync` (GPL-3.0) - chacun sous sa propre licence ; voir
[THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md), y compris la manière dont nous respectons la GPL pour
rsync. Notre code Apache-2.0 n'en est pas affecté (le binaire GPL est simplement agrégé, pas lié).

## Marques

VD Dropbear est un projet indépendant et non officiel, ni affilié à un tiers ni approuvé par un tiers.
« Android » est une marque de Google LLC ; « SSH » est une marque déposée de SSH Communications
Security. VD Dropbear s'exécute entièrement sur ton appareil.

## Tags

`SSH` `Dropbear` `KernelSU` `Magisk` `APatch` `root` `sshd` `remote-access` `openssh-alternative` `Android` `BFU` `VD-dropbear`
