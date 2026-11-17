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

> **Languages:** [English](../BUILDING.md) · [العربية](../ar/BUILDING.md) · [Čeština](../cs/BUILDING.md) · [Deutsch](../de/BUILDING.md) · [Español](../es/BUILDING.md) · [فارسی](../fa/BUILDING.md) · [Français](../fr/BUILDING.md) · [हिन्दी](../hi/BUILDING.md) · [Bahasa Indonesia](../in/BUILDING.md) · [Italiano](../it/BUILDING.md) · [日本語](../ja/BUILDING.md) · [한국어](../ko/BUILDING.md) · [Nederlands](../nl/BUILDING.md) · [Polski](../pl/BUILDING.md) · [Português](../pt/BUILDING.md) · [Русский](../ru/BUILDING.md) · Svenska · [ไทย](../th/BUILDING.md) · [Türkçe](../tr/BUILDING.md) · [Українська](../uk/BUILDING.md) · [Tiếng Việt](../vi/BUILDING.md) · [中文](../zh/BUILDING.md)

---

# Bygga VD Dropbear

VD Dropbear levererar **[Dropbear](https://github.com/mkj/dropbear) upstream** (taggen som är fäst i
[`UPSTREAM_VERSION`](../UPSTREAM_VERSION)) plus den lilla, granskningsbara patchuppsättningen i
[`patches/`](../patches/). CI bygger det; du kan reproducera det lokalt.

## Snabbstart

```sh
# en gång: ett Android NDK (r27 eller nyare)
export NDK=/path/to/android-ndk

# bygg varje ABI (arm64-v8a armeabi-v7a x86 x86_64)
./scripts/build.sh

# eller bara en, för att iterera snabbt
ABIS="arm64-v8a" ./scripts/build.sh
```

`scripts/build.sh` klonar den fästa upstream-taggen, applicerar `patches/*.patch` och `localoptions.h`,
och korskompilerar sedan `vddropbear` och `dropbearkey` till `module/bin/<abi>/`. Utdata är en
**dynamisk** ELF (`file` rapporterar `dynamically linked, interpreter /system/bin/linker64 … for Android
24`), länkad mot bionic-libc som varje Android-enhet redan har. libtomcrypt förblir inbäddat i binären;
endast C-biblioteket är dynamiskt. Se [Dynamisk, inte static-PIE](#dynamisk-inte-static-pie).

Binärerna **committas inte**; de byggs av CI vid varje tagg och bifogas till releasen. Se
[`.gitignore`](../.gitignore).

---

## Historien om crypt()/libcrypto (varför lösenordsautentisering krävde riktigt arbete)

Dropbears lösenordsautentisering är skriven för en vanlig Unix-värd med `crypt()` och `/etc/shadow`.
Android har **ingetdera**, och det krockar med bygget på tre separata ställen. Det här avsnittet
dokumenterar var och en av dem, för det är precis den sortens sak som är smärtsam att återupptäcka. Allt
hanteras av patchen [`0003-password-file.patch`](../patches/0003-password-file.patch); inget nedan
lämnas åt slumpen vid körning.

### 1. bionic har inget användbart `crypt()`

Androids C-bibliotek (bionic) tillhandahåller varken `crypt()`, `crypt_r()` eller en shadow-databas. NDK
exponerar ingen `<crypt.h>`. Så Dropbears standardlösenordsväg, som anropar `crypt(password, salt)` och
jämför mot `/etc/shadow`, går helt enkelt inte att bygga eller köra på Android. Det finns inte heller
något `libcrypt` att länka mot, och att dra in OpenSSL:s `libcrypto` bara för en lösenordshash vore ett
stort, otympligt beroende för en statisk binär.

**Vårt svar:** använd inte `crypt()` alls. Lösenordsautentiseringen verifierar det angivna lösenordet
med **PBKDF2-HMAC-SHA256** mot en hashfil (`DROPBEAR_PASSWD_FILE`), en publik, standard, saltad, itererad
KDF. Filformatet är dokumenterat i [`patches/README.md`](../patches/README.md).

### 2. kompileringstidsskyddet i `sysoptions.h`

Redan innan någon kod körs vägrar Dropbear att bygga:

```c
#if DROPBEAR_SVR_PASSWORD_AUTH && !HAVE_CRYPT
    #error "DROPBEAR_SVR_PASSWORD_AUTH requires `crypt()'."
#endif
```

Med `HAVE_CRYPT` odefinierat (alltid, på bionic) och lösenordsautentisering påslagen är detta ett hårt
`#error`. Eftersom vår verifierare aldrig anropar `crypt()`, **tar** patchen `0003` **bort det här
skyddet**. (Den lämnar kontrollen "minst en autentiseringsmetod måste vara påslagen" orörd.)

### 3. libtomcrypt-fällan: PBKDF2 kompileras *bort*

Dropbear bäddar in en nedbantad **libtomcrypt**, som *faktiskt* innehåller PBKDF2 (`pkcs_5_alg2`,
`src/misc/pkcs5/pkcs_5_2.c`). Den uppenbara lösningen är att anropa det. Det fungerar inte, av två
samverkande skäl:

- **Prototypen är dold.** `pkcs_5_alg2` deklareras bara inuti `#ifdef LTC_PKCS_5` i `tomcrypt_pkcs.h`.
  Dropbears *egna* källfiler kompileras inte med `LTC_PKCS_5` definierat, så deklarationen är osynlig och
  kompilatorn felar med *implicit function declaration*.
- **Symbolen finns inte.** Värre, själva *kroppen* av `pkcs_5_alg2` ligger också bakom `#ifdef
  LTC_PKCS_5`. Dropbears libtomcrypt-bygge definierar det inte, så `pkcs_5_2.o` kompileras till ett
  **tomt objekt**: det finns i `libtomcrypt.a`, men innehåller ingen `pkcs_5_alg2`-symbol. Länkningen
  misslyckas med `undefined symbol: pkcs_5_alg2`.

Du kan se det själv:

```sh
# objektet finns men är tomt (ingen T pkcs_5_alg2):
llvm-nm build/dropbear-*/libtomcrypt/src/misc/pkcs5/pkcs_5_2.o
# -> bara en datamarkör, ingen pkcs_5_alg2

# HMAC är däremot fullt kompilerat (Dropbear använder det för SSH-MAC:er):
llvm-nm build/dropbear-*/libtomcrypt/src/mac/hmac/hmac_memory.o
# -> definierar hmac_memory
```

**Vårt svar:** bygga PBKDF2 själva ovanpå primitiverna som Dropbear *faktiskt* kompilerar. `hmac_memory`
och den registrerade `sha256`-hashen finns båda och går att länka, så patchen `0003` implementerar
PBKDF2-HMAC-SHA256 direkt (RFC 2898; ett enda 32-bytes utdatablock, eftersom `dkLen == hLen` för
SHA-256). Vi deklarerar `hmac_memory` själva (samma dolda-prototyp-problem som ovan) och objektet dras
ur `libtomcrypt.a` vid länkning. Resultatet är standard-PBKDF2 och därmed interoperabelt: hashen som
WebUI beräknar med webbläsarens **WebCrypto** `deriveBits` är byte för byte identisk med vad servern
beräknar, verifierat mot Pythons `hashlib.pbkdf2_hmac` som en tredje, oberoende implementation.

> **Kort sagt:** Android ger dig inget `crypt()`, och Dropbears inbäddade PBKDF2 kompileras till
> ingenting. Lösenordsautentiseringen här är ett PBKDF2-HMAC-SHA256 från grunden ovanpå libtomcrypts
> HMAC, med crypt()-byggskyddet borttaget. Inget OpenSSL/`libcrypto`, ingen obfuskering, ingen
> system-shadow.

---

## Dynamisk, inte static-PIE

Binärerna är **dynamiska** (länkade mot systemets bionic via `/system/bin/linker64`), inte statiska. Det
spelar roll, och det lärdes på det hårda sättet, **på en riktig enhet**, inte i CI:

- Ett **static-PIE**-bygge *ser* bra ut (`file` rapporterar en ren `static-pie executable`) och länkar
  utan fel, men **gör en SIGSEGV i samma stund som det körs på enheten** (verifierat på en arm64 Android
  16-telefon, exit 139, ingen användbar tombstone). Statiska körbara filer på Android är sköra; den
  pålitliga formen är en vanlig dynamisk binär, vilket också är hur varje etablerad Android-dropbear
  levereras.
- Ett **statiskt, non-PIE**-bygge startar inte ens: bionic avvisar det med
  `executable's TLS segment is underaligned … needs to be at least 64 for ARM64 Bionic`.
- Så bygget är **dynamiskt** (`make` utan `STATIC=1`; `-pie`), och länkar bara bionic-libc, som finns på
  varje enhet. libtomcrypt är fortfarande statiskt inbäddat i binären, så det finns inget extra
  bibliotek att leverera.

Lärdom för testning: **`qemu-aarch64` (qemu-user) är inte ett giltigt smoke test** här (det ger också
segfault på dessa binärer), och inte heller ett lyckat compile+link. **Kör binären på en riktig arm64
Android-enhet.** (Detta validerades på precis detta sätt: daemonen startades
på en alternativ port på en levande enhet och en lösenordsinloggning bekräftades lyckas, med ett
felaktigt lösenord avvisat.)

## Ingen `-E`-flagga

Servern byggs med `--disable-syslog`, så den loggar alltid till stderr och upstream-alternativet `-E`
("log to stderr") **finns inte** i denna binär; att skicka det skriver ut `Invalid option -E` och
daemonen startar aldrig. Modulens argumentbyggare skickar därför inte `-E`.

## openpty

Interaktiva PTY-sessioner använder `openpty()`. bionic deklarerar det i `<pty.h>`, och Dropbears
kors-`configure` upptäcker det med NDK (`HAVE_OPENPTY` sätts, `HAVE_PTY_H 1`), så **ingen patch behövs**;
PTY:er fungerar direkt. (Icke-interaktiv användning som exec, SFTP, rsync och portvidarebefordran är ändå
inte beroende av det.)

## Inbäddade verktyg: sftp-server, scp, rsync

`scripts/build-bundles.sh` korskompilerar filöverföringsverktygen som dynamiska binärer till
`module/bin/<abi>/`. CI kör det direkt efter `build.sh`.

- **rsync** (med inbäddat popt + zlib) kompilerar rent så fort du talar om för dess configure att bionic
  inte har `lutimes` (`ac_cv_func_lutimes=no`).
- **sftp-server** och **scp** kommer från **OpenSSH portable**, byggda med `--without-openssl` (OpenSSH:s
  inbyggda krypto räcker för dessa två), med ett litet statiskt **zlib** som detta skript bygger först.

OpenSSH på Android är lika kinkigt som crypt()-historien ovan, eftersom dess `configure` feldetekterar
flera libc-funktioner vid korskompilering. Skriptet kodar fixen; för protokollet är delarna:

1. **Ett cache-seed av funktioner som bionic saknar** men som configure tror att det har, så att
   compat-versionerna kompileras istället: `recallocarray`, `close_range`, `getentropy`, `getrandom`,
   `nl_langinfo`, `setpwent`/`getpwent`/`endpwent`, `crypt`, `futimes`, `lutimes`, `strtonum`, `pledge`,
   `explicit_bzero`.
2. **`-DHAVE_ATTRIBUTE__SENTINEL__=1 -DHAVE_ATTRIBUTE__NONNULL__=1`.** Utan dessa gör OpenSSH:s
   `defines.h` ett `#define __sentinel__` (tomt), vilket sedan förvanskar bionics eget
   `__attribute__((__sentinel__(1)))` i `<unistd.h>` och varje kompilering misslyckas med `expected
   ')'`.
3. **En `explicit_bzero`-compat som använder `memset`.** bionics `bzero` är ett funktionsliknande makro
   (inte en riktig symbol), så OpenSSH:s standard-compat, som tar `&bzero` som funktionspekare,
   kompilerar inte. bionic har ingen egen `explicit_bzero`.
4. **Att släppa `xcrypt.o` och `getrrsetbyname.o`** från compat-biblioteket. `xcrypt.c` anropar
   `getpwent()`/`crypt()` ovillkorligt (bionic har ingetdera), och `getrrsetbyname.c` använder
   resolver-interna delar som bionic inte exponerar. Ingen av dem används av `sftp-server` eller `scp`.
5. **`-Wl,--allow-multiple-definition`.** `reallocarray` är spegelbilden av funktionerna i (1): bionic
   *deklarerar* det inte i API 24, så OpenSSH kompilerar sin egen compat, men **symbolen** finns visst i
   `libc.a`, så de två krockar vid länkning. Att tillåta dubbletten tar bionics, vilket är bra.
6. **Att NULL-skydda `pw_gecos` i `pwcopy()`.** bionics `getpwuid()` returnerar ett `NULL`-`pw_gecos`
   (Android håller inget GECOS-fält). OpenSSH:s `pwcopy()` skyddar `pw_passwd` mot `NULL` men inte
   `pw_gecos`, så `sftp-server` når `xstrdup(NULL)` och gör en SIGSEGV vid start, i samma stund en
   session öppnas. (`scp` över det äldre protokollet anropar aldrig `pwcopy`, vilket är varför det
   fungerade medan SFTP inte gjorde det.) Bygget patchar `pwcopy()` för att slå samman `pw_gecos` till
   `""`.

De fästa versionerna ligger överst i `scripts/build-bundles.sh` (`ZLIB_VERSION`, `RSYNC_VERSION`,
`OPENSSH_VERSION`).

## Reproducera ett enda ABI för hand

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

> _Denna dokumentation genererades med Claude (Anthropic) och underhålls av VD171. Rättelser och förbättringar välkomnas; se [CONTRIBUTING.md](CONTRIBUTING.md)._
