<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk. No invasive ADB exposure.
   Building the binaries, and the Android crypto/crypt() story.

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

> **Languages:** [English](../BUILDING.md) · [العربية](../ar/BUILDING.md) · [Čeština](../cs/BUILDING.md) · [Deutsch](../de/BUILDING.md) · [Español](../es/BUILDING.md) · [فارسی](../fa/BUILDING.md) · Français · [हिन्दी](../hi/BUILDING.md) · [Bahasa Indonesia](../id/BUILDING.md) · [Italiano](../it/BUILDING.md) · [日本語](../ja/BUILDING.md) · [한국어](../ko/BUILDING.md) · [Nederlands](../nl/BUILDING.md) · [Polski](../pl/BUILDING.md) · [Português](../pt/BUILDING.md) · [Русский](../ru/BUILDING.md) · [Svenska](../sv/BUILDING.md) · [ไทย](../th/BUILDING.md) · [Türkçe](../tr/BUILDING.md) · [Українська](../uk/BUILDING.md) · [Tiếng Việt](../vi/BUILDING.md) · [中文](../zh/BUILDING.md)

---

# Compiler VD Dropbear

VD Dropbear livre le **[Dropbear](https://github.com/mkj/dropbear) upstream** (le tag figé dans
[`UPSTREAM_VERSION`](../../UPSTREAM_VERSION)) plus le petit jeu de patches auditable dans
[`patches/`](../../patches/). La CI le compile ; vous pouvez le reproduire localement.

## Démarrage rapide

```sh
# une fois : un Android NDK (r27 ou plus récent)
export NDK=/path/to/android-ndk

# compile chaque ABI (arm64-v8a armeabi-v7a x86 x86_64)
./scripts/build.sh

# ou juste un, pour itérer vite
ABIS="arm64-v8a" ./scripts/build.sh
```

`scripts/build.sh` clone le tag upstream figé, applique `patches/*.patch` et `localoptions.h`, puis
cross-compile `vddropbear` et `dropbearkey` dans `module/bin/<abi>/`. La sortie est un ELF
**dynamique** (`file` rapporte `dynamically linked, interpreter /system/bin/linker64 … for Android
24`), lié contre la libc bionic que tout appareil Android possède déjà. libtomcrypt reste intégré dans
le binaire ; seule la bibliothèque C est dynamique. Voir [Dynamique, pas static-PIE](#dynamique-pas-static-pie).

Les binaires **ne sont pas commités** ; ils sont compilés par la CI à chaque tag et joints à la
release. Voir [`.gitignore`](../../.gitignore).

---

## L'histoire de crypt()/libcrypto (pourquoi l'auth par mot de passe a vraiment demandé du travail)

L'authentification par mot de passe de Dropbear est écrite pour un hôte Unix normal avec `crypt()` et
`/etc/shadow`. Android **n'a ni l'un ni l'autre**, et cela entre en conflit avec la compilation à trois
endroits distincts. Cette section documente chacun d'eux, car c'est exactement le genre de chose
pénible à redécouvrir. Tout cela est géré par le patch
[`0003-password-file.patch`](../../patches/0003-password-file.patch) ; rien de ce qui suit n'est laissé au
hasard à l'exécution.

### 1. bionic n'a pas de `crypt()` utilisable

La bibliothèque C d'Android (bionic) ne fournit pas `crypt()`, `crypt_r()`, ni une base shadow. Le NDK
n'expose aucun `<crypt.h>`. Donc le chemin standard de mot de passe de Dropbear, qui appelle
`crypt(password, salt)` et compare contre `/etc/shadow`, ne peut tout simplement pas être compilé ni
exécuté sur Android. Il n'y a pas non plus de `libcrypt` à lier, et tirer le `libcrypto` d'OpenSSL juste
pour un hash de mot de passe serait une dépendance lourde et maladroite pour un binaire statique.

**Notre réponse :** ne pas utiliser `crypt()` du tout. L'auth par mot de passe vérifie le mot de passe
présenté avec **PBKDF2-HMAC-SHA256** contre un fichier de hash (`DROPBEAR_PASSWD_FILE`), une KDF
publique, standard, salée et itérée. Le format du fichier est documenté dans
[`patches/README.md`](../../patches/README.md).

### 2. le garde-fou à la compilation dans `sysoptions.h`

Avant même qu'un code ne s'exécute, Dropbear refuse de compiler :

```c
#if DROPBEAR_SVR_PASSWORD_AUTH && !HAVE_CRYPT
    #error "DROPBEAR_SVR_PASSWORD_AUTH requires `crypt()'."
#endif
```

Avec `HAVE_CRYPT` non défini (toujours, sur bionic) et l'auth par mot de passe activée, c'est un
`#error` dur. Comme notre vérificateur n'appelle jamais `crypt()`, le patch `0003` **supprime ce
garde-fou**. (Il laisse intacte la vérification « au moins une méthode d'auth doit être activée ».)

### 3. le piège de libtomcrypt : PBKDF2 est compilé *hors*

Dropbear intègre un **libtomcrypt** allégé, qui contient *bien* PBKDF2 (`pkcs_5_alg2`,
`src/misc/pkcs5/pkcs_5_2.c`). La correction évidente est de l'appeler. Ça ne marche pas, pour deux
raisons qui se cumulent :

- **Le prototype est caché.** `pkcs_5_alg2` n'est déclaré qu'à l'intérieur de `#ifdef LTC_PKCS_5` dans
  `tomcrypt_pkcs.h`. Les fichiers source *propres* à Dropbear ne sont pas compilés avec `LTC_PKCS_5`
  défini, donc la déclaration est invisible et le compilateur échoue avec *implicit function
  declaration*.
- **Le symbole n'existe pas.** Pire, le *corps* de `pkcs_5_alg2` est lui-même derrière `#ifdef
  LTC_PKCS_5`. La compilation de libtomcrypt de Dropbear ne le définit pas, donc `pkcs_5_2.o` compile en
  un **objet vide** : il est dans `libtomcrypt.a`, mais ne contient aucun symbole `pkcs_5_alg2`.
  L'édition de liens échoue avec `undefined symbol: pkcs_5_alg2`.

Vous pouvez le constater vous-même :

```sh
# l'objet existe mais est vide (pas de T pkcs_5_alg2) :
llvm-nm build/dropbear-*/libtomcrypt/src/misc/pkcs5/pkcs_5_2.o
# -> seulement un marqueur de données, pas de pkcs_5_alg2

# le HMAC, en revanche, est pleinement compilé (Dropbear l'utilise pour les MAC SSH) :
llvm-nm build/dropbear-*/libtomcrypt/src/mac/hmac/hmac_memory.o
# -> définit hmac_memory
```

**Notre réponse :** construire PBKDF2 nous-mêmes sur les primitives que Dropbear compile *bien*.
`hmac_memory` et le hash `sha256` enregistré sont tous deux présents et liables, donc le patch `0003`
implémente PBKDF2-HMAC-SHA256 directement (RFC 2898 ; un seul bloc de sortie de 32 octets, puisque
`dkLen == hLen` pour SHA-256). Nous déclarons `hmac_memory` nous-mêmes (même souci de prototype caché
que plus haut) et l'objet est tiré de `libtomcrypt.a` à l'édition de liens. Le résultat est un PBKDF2
standard et donc interopérable : le hash que la WebUI calcule avec le **WebCrypto** `deriveBits` du
navigateur est octet pour octet identique à celui que le serveur calcule, vérifié contre le
`hashlib.pbkdf2_hmac` de Python comme troisième implémentation indépendante.

> **En bref :** Android ne vous donne aucun `crypt()`, et le PBKDF2 intégré de Dropbear est compilé à
> néant. L'auth par mot de passe ici est un PBKDF2-HMAC-SHA256 from scratch sur le HMAC de libtomcrypt,
> avec le garde-fou de compilation de crypt() retiré. Pas d'OpenSSL/`libcrypto`, pas d'obfuscation, pas
> de shadow système.

---

## Dynamique, pas static-PIE

Les binaires sont **dynamiques** (liés contre la bionic du système via `/system/bin/linker64`), pas
statiques. Cela compte, et cela a été appris à la dure, **sur un vrai appareil**, pas en CI :

- Une compilation **static-PIE** *paraît* bonne (`file` rapporte un `static-pie executable` propre) et
  lie sans erreur, mais **fait un SIGSEGV à l'instant où elle tourne sur l'appareil** (vérifié sur un
  téléphone arm64 Android 16, exit 139, aucun tombstone utile). Les exécutables statiques sur Android
  sont fragiles ; la forme fiable est un binaire dynamique normal, qui est aussi la façon dont tout
  dropbear Android établi est livré.
- Une compilation **statique, non-PIE** ne démarre même pas : bionic la rejette avec
  `executable's TLS segment is underaligned … needs to be at least 64 for ARM64 Bionic`.
- Donc la compilation est **dynamique** (`make` sans `STATIC=1` ; `-pie`), ne liant que la libc bionic,
  présente sur tout appareil. libtomcrypt reste intégré statiquement dans le binaire, donc aucune
  bibliothèque supplémentaire à livrer.

Leçon pour tester : **`qemu-aarch64` (qemu-user) n'est pas un smoke test valide** ici (il fait aussi un
segfault sur ces binaires), et une compilation+liaison réussie non plus. **Exécutez le binaire sur un
vrai appareil Android arm64.** (Cela a été validé exactement ainsi: le daemon a été lancé sur un port alternatif sur un appareil vivant et une connexion
par mot de passe a été confirmée comme réussie, un mauvais mot de passe étant rejeté.)

## Pas de flag `-E`

Le serveur est compilé `--disable-syslog`, donc il journalise toujours sur stderr et l'option `-E` de
l'upstream (« log to stderr ») **n'existe pas** dans ce binaire ; la passer affiche `Invalid option -E`
et le daemon ne démarre jamais. Le constructeur d'arguments du module ne passe donc pas `-E`.

## openpty

Les sessions PTY interactives utilisent `openpty()`. bionic le déclare dans `<pty.h>`, et le
`configure` croisé de Dropbear le détecte avec le NDK (`HAVE_OPENPTY` est défini, `HAVE_PTY_H 1`), donc
**aucun patch n'est nécessaire** ; les PTY fonctionnent d'emblée. (L'usage non interactif comme exec,
SFTP, rsync et le port-forwarding n'en dépend de toute façon pas.)

## Outils intégrés : sftp-server, scp, rsync

`scripts/build-bundles.sh` cross-compile les outils de transfert de fichiers en binaires dynamiques
dans `module/bin/<abi>/`. La CI le lance juste après `build.sh`.

- **rsync** (avec popt + zlib intégrés) compile proprement une fois que vous dites à son configure que
  bionic n'a pas `lutimes` (`ac_cv_func_lutimes=no`).
- **sftp-server** et **scp** viennent d'**OpenSSH portable**, compilés `--without-openssl` (la crypto
  intégrée d'OpenSSH suffit pour ces deux-là), avec un petit **zlib** statique que ce script compile
  d'abord.

OpenSSH sur Android est aussi capricieux que l'histoire de crypt() ci-dessus, car son `configure`
détecte mal plusieurs fonctions de la libc en compilation croisée. Le script encode la correction ;
pour mémoire, les pièces sont :

1. **Un seed de cache des fonctions que bionic n'a pas** mais que configure croit avoir, pour que les
   versions compat soient compilées à la place : `recallocarray`, `close_range`, `getentropy`,
   `getrandom`, `nl_langinfo`, `setpwent`/`getpwent`/`endpwent`, `crypt`, `futimes`, `lutimes`,
   `strtonum`, `pledge`, `explicit_bzero`.
2. **`-DHAVE_ATTRIBUTE__SENTINEL__=1 -DHAVE_ATTRIBUTE__NONNULL__=1`.** Sans eux, le `defines.h`
   d'OpenSSH fait `#define __sentinel__` (vide), ce qui mutile ensuite le propre
   `__attribute__((__sentinel__(1)))` de bionic dans `<unistd.h>` et chaque compilation échoue avec
   `expected ')'`.
3. **Un compat d'`explicit_bzero` qui utilise `memset`.** Le `bzero` de bionic est une macro de type
   fonction (pas un vrai symbole), donc le compat par défaut d'OpenSSH, qui prend `&bzero` comme
   pointeur de fonction, ne compile pas. bionic n'a pas d'`explicit_bzero` à lui.
4. **Retirer `xcrypt.o` et `getrrsetbyname.o`** de la bibliothèque compat. `xcrypt.c` appelle
   `getpwent()`/`crypt()` inconditionnellement (bionic n'a ni l'un ni l'autre), et `getrrsetbyname.c`
   utilise des internes du resolver que bionic n'expose pas. Aucun des deux n'est utilisé par
   `sftp-server` ou `scp`.
5. **`-Wl,--allow-multiple-definition`.** `reallocarray` est l'image miroir des fonctions en (1) :
   bionic ne la *déclare* pas en API 24, donc OpenSSH compile son propre compat, mais le **symbole**
   existe bien dans `libc.a`, donc les deux entrent en collision à l'édition de liens. Autoriser le
   doublon prend celui de bionic, ce qui convient.
6. **Protéger `pw_gecos` contre NULL dans `pwcopy()`.** Le `getpwuid()` de bionic renvoie un `pw_gecos`
   `NULL` (Android ne garde pas de champ GECOS). Le `pwcopy()` d'OpenSSH protège `pw_passwd` contre
   `NULL` mais pas `pw_gecos`, donc `sftp-server` atteint `xstrdup(NULL)` et fait un SIGSEGV au
   démarrage, à l'instant où une session s'ouvre. (`scp` via le protocole legacy n'appelle jamais
   `pwcopy`, c'est pourquoi il marchait tandis que SFTP non.) La compilation patche `pwcopy()` pour
   coalescer `pw_gecos` à `""`.

Les versions figées sont en haut de `scripts/build-bundles.sh` (`ZLIB_VERSION`, `RSYNC_VERSION`,
`OPENSSH_VERSION`).

## Reproduire un seul ABI à la main

```sh
git clone --depth 1 --branch "$(cat UPSTREAM_VERSION)" https://github.com/mkj/dropbear /tmp/db
cp patches/localoptions.h /tmp/db/localoptions.h
for p in patches/*.patch; do patch -p1 -d /tmp/db < "$p"; done
cd /tmp/db
TC="$NDK/toolchains/llvm/prebuilt/linux-x86_64/bin"
./configure --host=aarch64-linux-android --disable-zlib --disable-syslog \
    CC="$TC/aarch64-linux-android24-clang"
make PROGRAMS="dropbear dropbearkey" -j"$(nproc)"
file ./dropbear   # -> dynamically linked, interpreter /system/bin/linker64, for Android 24
```

<!-- doc-footer -->

---

> _Cette documentation a été générée avec Claude (Anthropic) et est maintenue par VD171. Les corrections et améliorations sont les bienvenues ; voir [CONTRIBUTING.md](CONTRIBUTING.md)._
