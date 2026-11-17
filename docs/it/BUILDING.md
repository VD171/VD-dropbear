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

> **Languages:** [English](../BUILDING.md) · [العربية](../ar/BUILDING.md) · [Čeština](../cs/BUILDING.md) · [Deutsch](../de/BUILDING.md) · [Español](../es/BUILDING.md) · [فارسی](../fa/BUILDING.md) · [Français](../fr/BUILDING.md) · [हिन्दी](../hi/BUILDING.md) · [Bahasa Indonesia](../id/BUILDING.md) · Italiano · [日本語](../ja/BUILDING.md) · [한국어](../ko/BUILDING.md) · [Nederlands](../nl/BUILDING.md) · [Polski](../pl/BUILDING.md) · [Português](../pt/BUILDING.md) · [Русский](../ru/BUILDING.md) · [Svenska](../sv/BUILDING.md) · [ไทย](../th/BUILDING.md) · [Türkçe](../tr/BUILDING.md) · [Українська](../uk/BUILDING.md) · [Tiếng Việt](../vi/BUILDING.md) · [中文](../zh/BUILDING.md)

---

# Compilare VD Dropbear

VD Dropbear distribuisce il **[Dropbear](https://github.com/mkj/dropbear) upstream** (il tag fissato in
[`UPSTREAM_VERSION`](../../UPSTREAM_VERSION)) più il piccolo set di patch verificabile in
[`patches/`](../../patches/). La CI lo compila; puoi riprodurlo in locale.

## Avvio rapido

```sh
# una volta sola: un Android NDK (r27 o più recente)
export NDK=/path/to/android-ndk

# compila ogni ABI (arm64-v8a armeabi-v7a x86 x86_64)
./scripts/build.sh

# oppure solo una, per iterare in fretta
ABIS="arm64-v8a" ./scripts/build.sh
```

`scripts/build.sh` clona il tag upstream fissato, applica `patches/*.patch` e `localoptions.h`, poi
cross-compila `vddropbear` e `dropbearkey` in `module/bin/<abi>/`. L'output è un ELF **dinamico** (`file`
riporta `dynamically linked, interpreter /system/bin/linker64 … for Android 24`), collegato alla libc
bionic che ogni dispositivo Android ha già. libtomcrypt resta incorporato nel binario; solo la libreria
C è dinamica. Vedi [Dinamico, non static-PIE](#dinamico-non-static-pie).

I binari **non vengono committati**; li compila la CI a ogni tag e vengono allegati alla release. Vedi
[`.gitignore`](../../.gitignore).

---

## La storia di crypt()/libcrypto (perché l'auth con password ha richiesto lavoro vero)

L'autenticazione con password di Dropbear è scritta per un normale host Unix con `crypt()` e
`/etc/shadow`. Android **non ha né l'uno né l'altro**, e questo si scontra con la build in tre punti
distinti. Questa sezione documenta ciascuno di essi, perché è esattamente il tipo di cosa doloroso da
riscoprire. Tutto è gestito dalla patch
[`0003-password-file.patch`](../../patches/0003-password-file.patch); nulla di quanto segue è lasciato al
caso a runtime.

### 1. bionic non ha un `crypt()` utilizzabile

La libreria C di Android (bionic) non fornisce `crypt()`, `crypt_r()`, né un database shadow. L'NDK non
espone alcun `<crypt.h>`. Quindi il percorso standard della password di Dropbear, che chiama
`crypt(password, salt)` e confronta con `/etc/shadow`, semplicemente non può essere compilato né
eseguito su Android. Non c'è nemmeno alcun `libcrypt` a cui collegarsi, e tirare dentro il `libcrypto`
di OpenSSL solo per un hash di password sarebbe una dipendenza grande e scomoda per un binario statico.

**La nostra risposta:** non usare `crypt()` affatto. L'auth con password verifica la password
presentata con **PBKDF2-HMAC-SHA256** contro un file di hash (`DROPBEAR_PASSWD_FILE`), una KDF
pubblica, standard, con salt e iterata. Il formato del file è documentato in
[`patches/README.md`](../../patches/README.md).

### 2. il guard a tempo di compilazione in `sysoptions.h`

Ancora prima che qualsiasi codice giri, Dropbear si rifiuta di compilare:

```c
#if DROPBEAR_SVR_PASSWORD_AUTH && !HAVE_CRYPT
    #error "DROPBEAR_SVR_PASSWORD_AUTH requires `crypt()'."
#endif
```

Con `HAVE_CRYPT` non definito (sempre, su bionic) e l'auth con password abilitata, questo è un `#error`
rigido. Poiché il nostro verificatore non chiama mai `crypt()`, la patch `0003` **rimuove questo
guard**. (Lascia intatto il controllo "almeno un metodo di auth deve essere abilitato".)

### 3. la trappola di libtomcrypt: PBKDF2 è compilato *fuori*

Dropbear incorpora un **libtomcrypt** ridotto, che *contiene davvero* PBKDF2 (`pkcs_5_alg2`,
`src/misc/pkcs5/pkcs_5_2.c`). La correzione ovvia è chiamarlo. Non funziona, per due ragioni che si
sommano:

- **Il prototipo è nascosto.** `pkcs_5_alg2` è dichiarato solo dentro `#ifdef LTC_PKCS_5` in
  `tomcrypt_pkcs.h`. I file sorgente *propri* di Dropbear non sono compilati con `LTC_PKCS_5` definito,
  quindi la dichiarazione è invisibile e il compilatore dà errore di *implicit function declaration*.
- **Il simbolo non esiste.** Peggio, il *corpo* di `pkcs_5_alg2` è anch'esso dietro `#ifdef
  LTC_PKCS_5`. La build di libtomcrypt di Dropbear non lo definisce, quindi `pkcs_5_2.o` compila in un
  **oggetto vuoto**: è in `libtomcrypt.a`, ma non contiene alcun simbolo `pkcs_5_alg2`. Il link
  fallisce con `undefined symbol: pkcs_5_alg2`.

Puoi vederlo tu stesso:

```sh
# l'oggetto esiste ma è vuoto (nessun T pkcs_5_alg2):
llvm-nm build/dropbear-*/libtomcrypt/src/misc/pkcs5/pkcs_5_2.o
# -> solo un marcatore di dati, nessun pkcs_5_alg2

# l'HMAC, invece, è compilato per intero (Dropbear lo usa per i MAC di SSH):
llvm-nm build/dropbear-*/libtomcrypt/src/mac/hmac/hmac_memory.o
# -> definisce hmac_memory
```

**La nostra risposta:** costruire PBKDF2 noi stessi sulle primitive che Dropbear *davvero* compila.
`hmac_memory` e l'hash `sha256` registrato sono entrambi presenti e collegabili, quindi la patch `0003`
implementa PBKDF2-HMAC-SHA256 direttamente (RFC 2898; un singolo blocco di output di 32 byte, dato che
`dkLen == hLen` per SHA-256). Dichiariamo `hmac_memory` noi stessi (stesso problema di prototipo
nascosto di sopra) e l'oggetto viene tirato da `libtomcrypt.a` al link. Il risultato è PBKDF2 standard e
quindi interoperabile: l'hash che la WebUI calcola con il **WebCrypto** `deriveBits` del browser è
identico byte per byte a quello che calcola il server, verificato contro `hashlib.pbkdf2_hmac` di Python
come terza implementazione indipendente.

> **In breve:** Android non ti dà alcun `crypt()`, e il PBKDF2 incorporato di Dropbear è compilato a
> nulla. L'auth con password qui è un PBKDF2-HMAC-SHA256 da zero sopra l'HMAC di libtomcrypt, con il
> guard di build di crypt() rimosso. Niente OpenSSL/`libcrypto`, niente offuscamento, niente shadow di
> sistema.

---

## Dinamico, non static-PIE

I binari sono **dinamici** (collegati alla bionic di sistema via `/system/bin/linker64`), non statici.
Questo conta, ed è stato imparato nel modo duro, **su un dispositivo reale**, non in CI:

- Una build **static-PIE** *sembra* a posto (`file` riporta un `static-pie executable` pulito) e
  collega senza errori, ma **va in SIGSEGV nell'istante in cui gira sul dispositivo** (verificato su un
  telefono arm64 Android 16, exit 139, nessun tombstone utile). Gli eseguibili statici su Android sono
  fragili; la forma affidabile è un normale binario dinamico, che è anche il modo in cui viene
  distribuito ogni dropbear Android consolidato.
- Una build **statica, non-PIE** non parte nemmeno: bionic la rifiuta con
  `executable's TLS segment is underaligned … needs to be at least 64 for ARM64 Bionic`.
- Quindi la build è **dinamica** (`make` senza `STATIC=1`; `-pie`), collegando solo la libc bionic,
  presente su ogni dispositivo. libtomcrypt resta incorporato staticamente nel binario, quindi non c'è
  alcuna libreria extra da distribuire.

Lezione per i test: **`qemu-aarch64` (qemu-user) non è uno smoke test valido** qui (anch'esso va in
segfault su questi binari), e nemmeno un compile+link riuscito lo è. **Esegui il binario su un
dispositivo Android arm64 reale.** (Questo è stato validato esattamente così: il daemon è stato avviato su una porta alternativa su un dispositivo vivo e
un login con password è stato confermato come riuscito, con una password sbagliata rifiutata.)

## Nessun flag `-E`

Il server è compilato con `--disable-syslog`, quindi logga sempre su stderr e l'opzione `-E`
dell'upstream ("log to stderr") **non esiste** in questo binario; passarla stampa `Invalid option -E` e
il daemon non parte mai. Perciò il costruttore di argomenti del modulo non passa `-E`.

## openpty

Le sessioni PTY interattive usano `openpty()`. bionic lo dichiara in `<pty.h>`, e il `configure`
cross di Dropbear lo rileva con l'NDK (`HAVE_OPENPTY` viene impostato, `HAVE_PTY_H 1`), quindi **nessuna
patch è necessaria**; i PTY funzionano da subito. (L'uso non interattivo come exec, SFTP, rsync e
port-forwarding comunque non ne dipende.)

## Strumenti incorporati: sftp-server, scp, rsync

`scripts/build-bundles.sh` cross-compila gli strumenti di trasferimento file come binari dinamici in
`module/bin/<abi>/`. La CI lo esegue subito dopo `build.sh`.

- **rsync** (con popt + zlib incorporati) compila pulito non appena dici al suo configure che bionic non
  ha `lutimes` (`ac_cv_func_lutimes=no`).
- **sftp-server** e **scp** vengono da **OpenSSH portable**, compilati con `--without-openssl` (la
  crypto integrata di OpenSSH basta per questi due), con un piccolo **zlib** statico che questo script
  compila per primo.

OpenSSH su Android è pignolo quanto la storia di crypt() qui sopra, perché il suo `configure` rileva
male diverse funzioni della libc in cross-compilazione. Lo script codifica la correzione; per
memoria, i pezzi sono:

1. **Un seed di cache delle funzioni che bionic non ha** ma che configure crede di avere, così che al
   loro posto vengano compilate le versioni compat: `recallocarray`, `close_range`, `getentropy`,
   `getrandom`, `nl_langinfo`, `setpwent`/`getpwent`/`endpwent`, `crypt`, `futimes`, `lutimes`,
   `strtonum`, `pledge`, `explicit_bzero`.
2. **`-DHAVE_ATTRIBUTE__SENTINEL__=1 -DHAVE_ATTRIBUTE__NONNULL__=1`.** Senza di essi, il `defines.h` di
   OpenSSH fa `#define __sentinel__` (vuoto), che poi rovina il `__attribute__((__sentinel__(1)))`
   stesso di bionic in `<unistd.h>` e ogni compilazione fallisce con `expected ')'`.
3. **Un compat di `explicit_bzero` che usa `memset`.** Il `bzero` di bionic è una macro simile a
   funzione (non un vero simbolo), quindi il compat di default di OpenSSH, che prende `&bzero` come
   puntatore a funzione, non compila. bionic non ha un `explicit_bzero` proprio.
4. **Scartare `xcrypt.o` e `getrrsetbyname.o`** dalla libreria compat. `xcrypt.c` chiama
   `getpwent()`/`crypt()` incondizionatamente (bionic non ha né l'uno né l'altro), e `getrrsetbyname.c`
   usa interni del resolver che bionic non espone. Nessuno dei due è usato da `sftp-server` o `scp`.
5. **`-Wl,--allow-multiple-definition`.** `reallocarray` è l'immagine speculare delle funzioni in (1):
   bionic non la *dichiara* in API 24, quindi OpenSSH compila il proprio compat, ma il **simbolo**
   esiste eccome in `libc.a`, così i due collidono al link. Permettere il duplicato prende quello di
   bionic, il che va bene.
6. **Proteggere `pw_gecos` da NULL in `pwcopy()`.** Il `getpwuid()` di bionic restituisce un `pw_gecos`
   `NULL` (Android non tiene un campo GECOS). Il `pwcopy()` di OpenSSH protegge `pw_passwd` da `NULL` ma
   non `pw_gecos`, quindi `sftp-server` raggiunge `xstrdup(NULL)` e va in SIGSEGV all'avvio, nell'istante
   in cui una sessione si apre. (`scp` sul protocollo legacy non chiama mai `pwcopy`, ecco perché
   funzionava mentre SFTP no.) La build applica una patch a `pwcopy()` per coalescere `pw_gecos` a
   `""`.

Le versioni fissate stanno in cima a `scripts/build-bundles.sh` (`ZLIB_VERSION`, `RSYNC_VERSION`,
`OPENSSH_VERSION`).

## Riprodurre una singola ABI a mano

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

> _Questa documentazione è stata generata con Claude (Anthropic) ed è gestita da VD171. Correzioni e miglioramenti sono benvenuti; vedi [CONTRIBUTING.md](CONTRIBUTING.md)._
