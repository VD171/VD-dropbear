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

> **Languages:** [English](../USER-GUIDE.md) · [العربية](../ar/USER-GUIDE.md) · [Čeština](../cs/USER-GUIDE.md) · [Deutsch](../de/USER-GUIDE.md) · [Español](../es/USER-GUIDE.md) · [فارسی](../fa/USER-GUIDE.md) · Français · [हिन्दी](../hi/USER-GUIDE.md) · [Bahasa Indonesia](../in/USER-GUIDE.md) · [Italiano](../it/USER-GUIDE.md) · [日本語](../ja/USER-GUIDE.md) · [한국어](../ko/USER-GUIDE.md) · [Nederlands](../nl/USER-GUIDE.md) · [Polski](../pl/USER-GUIDE.md) · [Português](../pt/USER-GUIDE.md) · [Русский](../ru/USER-GUIDE.md) · [Svenska](../sv/USER-GUIDE.md) · [ไทย](../th/USER-GUIDE.md) · [Türkçe](../tr/USER-GUIDE.md) · [Українська](../uk/USER-GUIDE.md) · [Tiếng Việt](../vi/USER-GUIDE.md) · [中文](../zh/USER-GUIDE.md)

---

# Guide de l'utilisateur

VD Dropbear donne à votre appareil rooté un serveur SSH privé. Ce guide vous mène de l'installation à une
connexion fonctionnelle, y compris le transfert de fichiers et le mode avant le premier déverrouillage
(BFU).

> **Chaque connexion authentifiée obtient un shell root.** Préférez les clés aux mots de passe, faites le
> bind uniquement sur des réseaux de confiance, et n'exposez jamais le port à l'Internet ouvert sans
> raison.

## 1. Installer

Flashez le zip du module dans le gestionnaire **KernelSU**, **APatch** ou **Magisk** (ou depuis un shell
avec `ksud module install` / `apd module install`), puis ouvrez la **WebUI** du module.

## 2. Ajouter une clé (recommandé)

Dans la WebUI, sous **Authorized keys**, collez votre clé publique (`ssh-ed25519 AAAA... you@host`) et
appuyez sur **Add key**. Les clés sont la valeur par défaut et la façon la plus sûre d'entrer.

Pour générer une clé sur votre ordinateur, si vous n'en avez pas :

```sh
ssh-keygen -t ed25519 -C "you@host"
cat ~/.ssh/id_ed25519.pub     # paste this into the WebUI
```

## 3. Ou définir un mot de passe

La connexion par mot de passe est désactivée par défaut (chaque connexion est root, donc les clés sont
préférées). Pour l'activer, activez **Password login** dans les réglages, puis sous **Password accounts**
définissez un mot de passe pour l'utilisateur de connexion. Le hachage est calculé dans votre navigateur
avec PBKDF2 ; le mot de passe lui-même ne quitte jamais la page.

## 4. Choisir un port et où écouter

Sous **Settings**, définissez le **Port** et choisissez les binds. Par défaut, VD Dropbear écoute
uniquement sur **loopback** ; pour l'atteindre depuis votre LAN ou un VPN, activez les interfaces
voulues. Évitez **Listen on all interfaces** sauf si vous comprenez l'exposition que cela implique.

Appuyez sur **Save & restart** pour appliquer, puis sur **Start** s'il n'est pas déjà en marche.

## 5. Se connecter

```sh
ssh -p 2222 root@<device-ip>
sftp -P 2222 root@<device-ip>
scp -P 2222 file root@<device-ip>:/sdcard/
rsync -e 'ssh -p 2222' -av ./dir/ root@<device-ip>:/sdcard/dir/
```

`sftp-server`, `scp` et `rsync` sont inclus, donc SFTP, `sshfs`, les clients graphiques et les
sauvegardes fonctionnent tous sur la même connexion.

## 6. Avant le premier déverrouillage (BFU)

Par défaut, le démon démarre uniquement **après** que vous avez déverrouillé l'appareil une fois (AFU),
car ses secrets résident sur un stockage chiffré par identifiants. Si vous avez besoin de SSH **avant**
le premier déverrouillage - par exemple pour déverrouiller un appareil à distance après un redémarrage -
activez **Start before first unlock (BFU)**. Les secrets passent alors sur un stockage chiffré par
appareil, lisible avant le déverrouillage : un compromis délibéré et documenté. Voir
[Modèle de sécurité](#) dans le README.

## 7. Contrôler le démon

- **WebUI :** Start / Stop / Restart, et état en direct (en marche, PID, port, mode, empreinte de la host
  key).
- **Bouton Action du gestionnaire :** (re)lance le démon.
- Il démarre aussi automatiquement au boot (sauf si vous le désactivez).

## Dépannage

- **Il ne démarre pas.** Vérifiez `/data/adb/vddropbear/state/daemon.log`. Assurez-vous que **Enabled**
  est activé et qu'une host key a pu être générée.
- **Clé rejetée.** Confirmez que la ligne de la clé publique est exactement celle que propose votre
  client, et que l'utilisateur de connexion est un compte que le système résout (généralement `root`).
- **Impossible de se connecter depuis une autre machine.** Vous êtes probablement encore en bind
  uniquement sur loopback - activez l'interface voulue et redémarrez.
- **SFTP/scp échoue mais le shell fonctionne.** Assurez-vous que le `sftp-server` inclus a été livré pour
  votre ABI ; l'état de la WebUI montre l'ABI détectée.
