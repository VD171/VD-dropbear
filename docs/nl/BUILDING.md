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

> **Languages:** [English](../BUILDING.md) · [العربية](../ar/BUILDING.md) · [Čeština](../cs/BUILDING.md) · [Deutsch](../de/BUILDING.md) · [Español](../es/BUILDING.md) · [فارسی](../fa/BUILDING.md) · [Français](../fr/BUILDING.md) · [हिन्दी](../hi/BUILDING.md) · [Bahasa Indonesia](../id/BUILDING.md) · [Italiano](../it/BUILDING.md) · [日本語](../ja/BUILDING.md) · [한국어](../ko/BUILDING.md) · Nederlands · [Polski](../pl/BUILDING.md) · [Português](../pt/BUILDING.md) · [Русский](../ru/BUILDING.md) · [Svenska](../sv/BUILDING.md) · [ไทย](../th/BUILDING.md) · [Türkçe](../tr/BUILDING.md) · [Українська](../uk/BUILDING.md) · [Tiếng Việt](../vi/BUILDING.md) · [中文](../zh/BUILDING.md)

---

# VD Dropbear bouwen

VD Dropbear levert de **[Dropbear](https://github.com/mkj/dropbear) upstream** (de tag vastgezet in
[`UPSTREAM_VERSION`](../../UPSTREAM_VERSION)) plus de kleine, controleerbare patchset in
[`patches/`](../../patches/). De CI bouwt het, je kunt het lokaal reproduceren.

## Snel starten

```sh
# eenmalig: een Android NDK (r27 of nieuwer)
export NDK=/path/to/android-ndk

# bouw elke ABI (arm64-v8a armeabi-v7a x86 x86_64)
./scripts/build.sh

# of slechts één, om snel te itereren
ABIS="arm64-v8a" ./scripts/build.sh
```

`scripts/build.sh` kloont de vastgezette upstream-tag, past `patches/*.patch` en `localoptions.h` toe, en
cross-compileert dan `vddropbear` en `dropbearkey` naar `module/bin/<abi>/`. De uitvoer is een
**dynamische** ELF (`file` meldt `dynamically linked, interpreter /system/bin/linker64 … for Android
24`), gelinkt tegen de bionic-libc die elk Android-toestel al heeft. libtomcrypt blijft ingebed in het
binary, alleen de C-bibliotheek is dynamisch. Zie [Dynamisch, geen static-PIE](#dynamisch-geen-static-pie).

De binaries worden **niet gecommit**, ze worden bij elke tag door de CI gebouwd en aan de release
gehecht. Zie [`.gitignore`](../../.gitignore).

---

## Het crypt()/libcrypto-verhaal (waarom wachtwoord-auth echt werk vergde)

De wachtwoordauthenticatie van Dropbear is geschreven voor een normale Unix-host met `crypt()` en
`/etc/shadow`. Android heeft **geen van beide**, en dat botst op drie aparte plekken met de build. Dit
deel documenteert ze allemaal, want het is precies het soort ding dat pijnlijk is om opnieuw te
ontdekken. Alles wordt afgehandeld door patch
[`0003-password-file.patch`](../../patches/0003-password-file.patch), niets hieronder wordt tijdens runtime
aan het toeval overgelaten.

### 1. bionic heeft geen bruikbare `crypt()`

De C-bibliotheek van Android (bionic) biedt geen `crypt()`, `crypt_r()`, noch een shadow-database. De
NDK stelt geen `<crypt.h>` beschikbaar. Dus het standaard wachtwoordpad van Dropbear, dat `crypt(password,
salt)` aanroept en vergelijkt met `/etc/shadow`, kan simpelweg niet gebouwd of uitgevoerd worden op
Android. Er is ook geen `libcrypt` om tegen te linken, en OpenSSL's `libcrypto` binnenhalen enkel voor
een wachtwoord-hash zou een grote, onhandige afhankelijkheid zijn voor een statisch binary.

**Ons antwoord:** `crypt()` helemaal niet gebruiken. Wachtwoord-auth verifieert het aangeboden
wachtwoord met **PBKDF2-HMAC-SHA256** tegen een hash-bestand (`DROPBEAR_PASSWD_FILE`), een publieke,
standaard, gesalte, geïtereerde KDF. Het bestandsformaat is gedocumenteerd in
[`patches/README.md`](../../patches/README.md).

### 2. de compile-time guard in `sysoptions.h`

Nog voordat er code draait, weigert Dropbear te bouwen:

```c
#if DROPBEAR_SVR_PASSWORD_AUTH && !HAVE_CRYPT
    #error "DROPBEAR_SVR_PASSWORD_AUTH requires `crypt()'."
#endif
```

Met `HAVE_CRYPT` niet gedefinieerd (altijd, op bionic) en wachtwoord-auth ingeschakeld, is dit een harde
`#error`. Omdat onze verifier nooit `crypt()` aanroept, **verwijdert** patch `0003` deze guard. (De
controle "ten minste één auth-methode moet ingeschakeld zijn" blijft intact.)

### 3. de libtomcrypt-val: PBKDF2 wordt *weg*gecompileerd

Dropbear bedt een uitgeklede **libtomcrypt** in, die PBKDF2 *wel degelijk* bevat (`pkcs_5_alg2`,
`src/misc/pkcs5/pkcs_5_2.c`). De voor de hand liggende fix is het aanroepen. Dat werkt niet, om twee
elkaar versterkende redenen:

- **Het prototype is verborgen.** `pkcs_5_alg2` wordt alleen binnen `#ifdef LTC_PKCS_5` in
  `tomcrypt_pkcs.h` gedeclareerd. Dropbears *eigen* bronbestanden worden niet met `LTC_PKCS_5`
  gedefinieerd gecompileerd, dus de declaratie is onzichtbaar en de compiler faalt met *implicit
  function declaration*.
- **Het symbool bestaat niet.** Erger nog, de *body* van `pkcs_5_alg2` zit zelf achter `#ifdef
  LTC_PKCS_5`. Dropbears libtomcrypt-build definieert het niet, dus `pkcs_5_2.o` compileert naar een
  **leeg object**: het zit in `libtomcrypt.a`, maar bevat geen `pkcs_5_alg2`-symbool. Het linken faalt
  met `undefined symbol: pkcs_5_alg2`.

Je kunt dit zelf zien:

```sh
# het object bestaat maar is leeg (geen T pkcs_5_alg2):
llvm-nm build/dropbear-*/libtomcrypt/src/misc/pkcs5/pkcs_5_2.o
# -> alleen een datamarkering, geen pkcs_5_alg2

# HMAC daarentegen is volledig gecompileerd (Dropbear gebruikt het voor SSH-MAC's):
llvm-nm build/dropbear-*/libtomcrypt/src/mac/hmac/hmac_memory.o
# -> definieert hmac_memory
```

**Ons antwoord:** PBKDF2 zelf bouwen op de primitieven die Dropbear *wel* compileert. `hmac_memory` en
de geregistreerde `sha256`-hash zijn beide aanwezig en linkbaar, dus patch `0003` implementeert
PBKDF2-HMAC-SHA256 rechtstreeks (RFC 2898; een enkel uitvoerblok van 32 bytes, aangezien `dkLen ==
hLen` voor SHA-256). We declareren `hmac_memory` zelf (zelfde probleem van verborgen prototype als
hierboven) en het object wordt bij het linken uit `libtomcrypt.a` gehaald. Het resultaat is standaard
PBKDF2 en dus interoperabel: de hash die de WebUI berekent met de **WebCrypto** `deriveBits` van de
browser is byte voor byte identiek aan wat de server berekent, geverifieerd tegen Pythons
`hashlib.pbkdf2_hmac` als een derde, onafhankelijke implementatie.

> **Kort gezegd:** Android geeft je geen `crypt()`, en Dropbears ingebedde PBKDF2 wordt tot niets
> gecompileerd. Wachtwoord-auth is hier een PBKDF2-HMAC-SHA256 vanaf nul boven op libtomcrypts HMAC, met
> de crypt()-build-guard verwijderd. Geen OpenSSL/`libcrypto`, geen obfuscatie, geen systeem-shadow.

---

## Dynamisch, geen static-PIE

De binaries zijn **dynamisch** (gelinkt tegen de systeem-bionic via `/system/bin/linker64`), niet
statisch. Dit is belangrijk, en het werd op de harde manier geleerd, **op een echt toestel**, niet in
de CI:

- Een **static-PIE**-build *lijkt* in orde (`file` meldt een schone `static-pie executable`) en linkt
  foutloos, maar **doet een SIGSEGV op het moment dat hij op het toestel draait** (geverifieerd op een
  arm64 Android 16-telefoon, exit 139, geen bruikbare tombstone). Statische executables op Android zijn
  broos, de betrouwbare vorm is een normaal dynamisch binary, wat ook de manier is waarop elke gevestigde
  Android-dropbear wordt geleverd.
- Een **statische, non-PIE**-build start niet eens: bionic weigert hem met
  `executable's TLS segment is underaligned … needs to be at least 64 for ARM64 Bionic`.
- Dus de build is **dynamisch** (`make` zonder `STATIC=1`; `-pie`), en linkt alleen de bionic-libc, op
  elk toestel aanwezig. libtomcrypt blijft statisch in het binary ingebed, dus er is geen extra
  bibliotheek om te leveren.

Les voor het testen: **`qemu-aarch64` (qemu-user) is hier geen geldige smoke test** (het geeft ook een
segfault op deze binaries), en een geslaagde compile+link evenmin. **Draai het binary op een echt arm64
Android-toestel.** (Dit is op precies deze manier gevalideerd: de
daemon werd op een alternatieve poort op een live toestel gestart en een wachtwoord-login werd bevestigd
als geslaagd, met een fout wachtwoord afgewezen.)

## Geen `-E`-flag

De server wordt met `--disable-syslog` gebouwd, dus logt hij altijd naar stderr en de upstream-optie
`-E` ("log to stderr") **bestaat niet** in dit binary, hem meegeven print `Invalid option -E` en de
daemon start nooit. De argumentenbouwer van de module geeft `-E` daarom niet mee.

## openpty

Interactieve PTY-sessies gebruiken `openpty()`. bionic declareert het in `<pty.h>`, en Dropbears
cross-`configure` detecteert het met de NDK (`HAVE_OPENPTY` wordt gezet, `HAVE_PTY_H 1`), dus is **geen
patch nodig**, PTY's werken meteen. (Niet-interactief gebruik zoals exec, SFTP, rsync en port-forwarding
hangt er sowieso niet van af.)

## Ingebedde tools: sftp-server, scp, rsync

`scripts/build-bundles.sh` cross-compileert de bestandsoverdracht-tools als dynamische binaries naar
`module/bin/<abi>/`. De CI draait het direct na `build.sh`.

- **rsync** (met ingebedde popt + zlib) compileert schoon zodra je zijn configure vertelt dat bionic
  geen `lutimes` heeft (`ac_cv_func_lutimes=no`).
- **sftp-server** en **scp** komen van **OpenSSH portable**, gebouwd met `--without-openssl` (OpenSSH's
  ingebouwde crypto volstaat voor deze twee), met een kleine statische **zlib** die dit script eerst
  bouwt.

OpenSSH op Android is net zo lastig als het crypt()-verhaal hierboven, omdat zijn `configure`
verscheidene libc-functies verkeerd detecteert bij cross-compileren. Het script codeert de fix, voor
de volledigheid zijn de onderdelen:

1. **Een cache-seed van functies die bionic mist** maar die configure denkt te hebben, zodat in plaats
   daarvan de compat-versies gecompileerd worden: `recallocarray`, `close_range`, `getentropy`,
   `getrandom`, `nl_langinfo`, `setpwent`/`getpwent`/`endpwent`, `crypt`, `futimes`, `lutimes`,
   `strtonum`, `pledge`, `explicit_bzero`.
2. **`-DHAVE_ATTRIBUTE__SENTINEL__=1 -DHAVE_ATTRIBUTE__NONNULL__=1`.** Zonder deze doet OpenSSH's
   `defines.h` een `#define __sentinel__` (leeg), wat vervolgens bionics eigen
   `__attribute__((__sentinel__(1)))` in `<unistd.h>` verminkt en elke compilatie faalt met
   `expected ')'`.
3. **Een `explicit_bzero`-compat die `memset` gebruikt.** bionics `bzero` is een functie-achtige macro
   (geen echt symbool), dus OpenSSH's standaard-compat, die `&bzero` als functiepointer neemt,
   compileert niet. bionic heeft geen eigen `explicit_bzero`.
4. **`xcrypt.o` en `getrrsetbyname.o` weglaten** uit de compat-bibliotheek. `xcrypt.c` roept
   `getpwent()`/`crypt()` onvoorwaardelijk aan (bionic heeft geen van beide), en `getrrsetbyname.c`
   gebruikt resolver-interna die bionic niet blootstelt. Geen van beide wordt gebruikt door
   `sftp-server` of `scp`.
5. **`-Wl,--allow-multiple-definition`.** `reallocarray` is het spiegelbeeld van de functies in (1):
   bionic *declareert* het niet in API 24, dus OpenSSH compileert zijn eigen compat, maar het **symbool**
   bestaat wel degelijk in `libc.a`, dus de twee botsen bij het linken. Het duplicaat toestaan neemt dat
   van bionic, wat prima is.
6. **`pw_gecos` tegen NULL beschermen in `pwcopy()`.** bionics `getpwuid()` geeft een `NULL`-`pw_gecos`
   terug (Android houdt geen GECOS-veld bij). OpenSSH's `pwcopy()` beschermt `pw_passwd` tegen `NULL`
   maar niet `pw_gecos`, dus `sftp-server` bereikt `xstrdup(NULL)` en doet een SIGSEGV bij het starten,
   op het moment dat een sessie opent. (`scp` via het legacy-protocol roept `pwcopy` nooit aan, daarom
   werkte het terwijl SFTP niet werkte.) De build patcht `pwcopy()` om `pw_gecos` tot `""` samen te
   voegen.

De vastgezette versies staan bovenaan `scripts/build-bundles.sh` (`ZLIB_VERSION`, `RSYNC_VERSION`,
`OPENSSH_VERSION`).

## Eén enkele ABI met de hand reproduceren

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

> _Deze documentatie is gegenereerd met Claude (Anthropic) en wordt onderhouden door VD171. Correcties en verbeteringen zijn welkom, zie [CONTRIBUTING.md](CONTRIBUTING.md)._
