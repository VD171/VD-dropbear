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

> **Languages:** [English](../BUILDING.md) · [العربية](../ar/BUILDING.md) · [Čeština](../cs/BUILDING.md) · [Deutsch](../de/BUILDING.md) · [Español](../es/BUILDING.md) · [فارسی](../fa/BUILDING.md) · [Français](../fr/BUILDING.md) · [हिन्दी](../hi/BUILDING.md) · [Bahasa Indonesia](../in/BUILDING.md) · [Italiano](../it/BUILDING.md) · [日本語](../ja/BUILDING.md) · [한국어](../ko/BUILDING.md) · [Nederlands](../nl/BUILDING.md) · Polski · [Português](../pt/BUILDING.md) · [Русский](../ru/BUILDING.md) · [Svenska](../sv/BUILDING.md) · [ไทย](../th/BUILDING.md) · [Türkçe](../tr/BUILDING.md) · [Українська](../uk/BUILDING.md) · [Tiếng Việt](../vi/BUILDING.md) · [中文](../zh/BUILDING.md)

---

# Budowanie VD Dropbear

VD Dropbear dostarcza **[Dropbear](https://github.com/mkj/dropbear) upstream** (tag przypięty w
[`UPSTREAM_VERSION`](../UPSTREAM_VERSION)) oraz mały, audytowalny zestaw łatek w
[`patches/`](../patches/). CI go buduje; możesz to odtworzyć lokalnie.

## Szybki start

```sh
# jednorazowo: Android NDK (r27 lub nowszy)
export NDK=/path/to/android-ndk

# zbuduj każde ABI (arm64-v8a armeabi-v7a x86 x86_64)
./scripts/build.sh

# albo tylko jedno, by iterować szybko
ABIS="arm64-v8a" ./scripts/build.sh
```

`scripts/build.sh` klonuje przypięty tag upstream, nakłada `patches/*.patch` i `localoptions.h`, a
następnie kompiluje skrośnie `vddropbear` i `dropbearkey` do `module/bin/<abi>/`. Wyjściem jest
**dynamiczny** ELF (`file` zgłasza `dynamically linked, interpreter /system/bin/linker64 … for Android
24`), zlinkowany z libc bionic, którą ma już każde urządzenie z Androidem. libtomcrypt pozostaje wbudowany
w binarkę; dynamiczna jest tylko biblioteka C. Zobacz [Dynamiczny, nie static-PIE](#dynamiczny-nie-static-pie).

Binarki **nie są commitowane**; buduje je CI przy każdym tagu i dołącza do wydania. Zobacz
[`.gitignore`](../.gitignore).

---

## Historia crypt()/libcrypto (dlaczego uwierzytelnianie hasłem wymagało prawdziwej pracy)

Uwierzytelnianie hasłem w Dropbear jest napisane dla zwykłego hosta Unix z `crypt()` i `/etc/shadow`.
Android **nie ma żadnego z nich**, i to koliduje z budowaniem w trzech osobnych miejscach. Ten rozdział
dokumentuje każde z nich, bo to dokładnie ten rodzaj rzeczy, który boli przy ponownym odkrywaniu.
Wszystkim zajmuje się łatka [`0003-password-file.patch`](../patches/0003-password-file.patch); nic
poniżej nie jest zostawione przypadkowi w czasie działania.

### 1. bionic nie ma użytecznego `crypt()`

Biblioteka C Androida (bionic) nie dostarcza `crypt()`, `crypt_r()` ani bazy shadow. NDK nie udostępnia
żadnego `<crypt.h>`. Więc standardowa ścieżka hasła w Dropbear, która wywołuje `crypt(password, salt)` i
porównuje z `/etc/shadow`, po prostu nie da się zbudować ani uruchomić na Androidzie. Nie ma też żadnego
`libcrypt` do zlinkowania, a wciąganie `libcrypto` z OpenSSL tylko dla skrótu hasła byłoby dużą,
niewygodną zależnością dla statycznej binarki.

**Nasza odpowiedź:** w ogóle nie używać `crypt()`. Uwierzytelnianie hasłem weryfikuje przedstawione
hasło za pomocą **PBKDF2-HMAC-SHA256** wobec pliku skrótu (`DROPBEAR_PASSWD_FILE`), publicznej,
standardowej, solonej, iterowanej KDF. Format pliku jest udokumentowany w
[`patches/README.md`](../patches/README.md).

### 2. strażnik kompilacji w `sysoptions.h`

Jeszcze zanim uruchomi się jakikolwiek kod, Dropbear odmawia budowania:

```c
#if DROPBEAR_SVR_PASSWORD_AUTH && !HAVE_CRYPT
    #error "DROPBEAR_SVR_PASSWORD_AUTH requires `crypt()'."
#endif
```

Przy niezdefiniowanym `HAVE_CRYPT` (zawsze, na bionic) i włączonym uwierzytelnianiu hasłem, to twardy
`#error`. Ponieważ nasz weryfikator nigdy nie wywołuje `crypt()`, łatka `0003` **usuwa tego strażnika**.
(Pozostawia nietkniętą kontrolę „co najmniej jedna metoda uwierzytelniania musi być włączona".)

### 3. pułapka libtomcrypt: PBKDF2 jest wykompilowywany *na zewnątrz*

Dropbear wbudowuje okrojony **libtomcrypt**, który *rzeczywiście* zawiera PBKDF2 (`pkcs_5_alg2`,
`src/misc/pkcs5/pkcs_5_2.c`). Oczywistą poprawką jest go wywołać. To nie działa, z dwóch nakładających
się powodów:

- **Prototyp jest ukryty.** `pkcs_5_alg2` jest deklarowany tylko wewnątrz `#ifdef LTC_PKCS_5` w
  `tomcrypt_pkcs.h`. *Własne* pliki źródłowe Dropbear nie są kompilowane ze zdefiniowanym `LTC_PKCS_5`,
  więc deklaracja jest niewidoczna, a kompilator zgłasza błąd *implicit function declaration*.
- **Symbol nie istnieje.** Gorzej, samo *ciało* `pkcs_5_alg2` również jest za `#ifdef LTC_PKCS_5`. Build
  libtomcrypt w Dropbear tego nie definiuje, więc `pkcs_5_2.o` kompiluje się do **pustego obiektu**:
  jest w `libtomcrypt.a`, ale nie zawiera żadnego symbolu `pkcs_5_alg2`. Linkowanie kończy się błędem
  `undefined symbol: pkcs_5_alg2`.

Możesz to sam zobaczyć:

```sh
# obiekt istnieje, ale jest pusty (brak T pkcs_5_alg2):
llvm-nm build/dropbear-*/libtomcrypt/src/misc/pkcs5/pkcs_5_2.o
# -> tylko znacznik danych, brak pkcs_5_alg2

# HMAC natomiast jest w pełni skompilowany (Dropbear używa go do MAC-ów SSH):
llvm-nm build/dropbear-*/libtomcrypt/src/mac/hmac/hmac_memory.o
# -> definiuje hmac_memory
```

**Nasza odpowiedź:** zbudować PBKDF2 samodzielnie na prymitywach, które Dropbear *rzeczywiście*
kompiluje. `hmac_memory` oraz zarejestrowany skrót `sha256` są oba obecne i linkowalne, więc łatka
`0003` implementuje PBKDF2-HMAC-SHA256 bezpośrednio (RFC 2898; pojedynczy 32-bajtowy blok wyjściowy, bo
`dkLen == hLen` dla SHA-256). Deklarujemy `hmac_memory` samodzielnie (ten sam problem ukrytego prototypu
co wyżej), a obiekt jest wyciągany z `libtomcrypt.a` przy linkowaniu. Wynikiem jest standardowy PBKDF2,
a więc interoperacyjny: skrót, który WebUI liczy za pomocą **WebCrypto** `deriveBits` przeglądarki, jest
bajt w bajt identyczny z tym, który liczy serwer, zweryfikowany wobec `hashlib.pbkdf2_hmac` Pythona jako
trzeciej, niezależnej implementacji.

> **W skrócie:** Android nie daje ci żadnego `crypt()`, a wbudowany PBKDF2 Dropbear jest kompilowany do
> niczego. Uwierzytelnianie hasłem to tutaj PBKDF2-HMAC-SHA256 od zera na HMAC z libtomcrypt, z usuniętym
> strażnikiem kompilacji crypt(). Bez OpenSSL/`libcrypto`, bez zaciemniania, bez systemowego shadow.

---

## Dynamiczny, nie static-PIE

Binarki są **dynamiczne** (zlinkowane z systemowym bionic przez `/system/bin/linker64`), nie statyczne.
To ma znaczenie i zostało nauczone w trudny sposób, **na prawdziwym urządzeniu**, nie w CI:

- Build **static-PIE** *wygląda* dobrze (`file` zgłasza czysty `static-pie executable`) i linkuje się
  bez błędu, ale **robi SIGSEGV w chwili, gdy uruchamia się na urządzeniu** (zweryfikowane na telefonie
  arm64 z Androidem 16, exit 139, brak użytecznego tombstone). Statyczne pliki wykonywalne na Androidzie
  są kruche; niezawodną formą jest zwykła dynamiczna binarka, co jest również sposobem, w jaki dostarczany
  jest każdy utrwalony dropbear na Androida.
- Build **statyczny, non-PIE** nawet się nie uruchamia: bionic go odrzuca z
  `executable's TLS segment is underaligned … needs to be at least 64 for ARM64 Bionic`.
- Więc build jest **dynamiczny** (`make` bez `STATIC=1`; `-pie`), linkując tylko libc bionic, obecną na
  każdym urządzeniu. libtomcrypt wciąż jest statycznie wbudowany w binarkę, więc nie ma dodatkowej
  biblioteki do dostarczenia.

Lekcja na testy: **`qemu-aarch64` (qemu-user) nie jest tutaj prawidłowym smoke testem** (również robi
segfault na tych binarkach), a udana kompilacja+linkowanie też nie. **Uruchom binarkę na prawdziwym
urządzeniu arm64 z Androidem.** (To zweryfikowano dokładnie w ten sposób: daemon został uruchomiony na alternatywnym porcie na żywym urządzeniu, a logowanie hasłem
zostało potwierdzone jako udane, z odrzuconym błędnym hasłem.)

## Brak flagi `-E`

Serwer jest budowany z `--disable-syslog`, więc zawsze loguje do stderr, a opcja `-E` z upstream ("log
to stderr") **nie istnieje** w tej binarce; przekazanie jej wypisuje `Invalid option -E` i daemon nigdy
się nie uruchamia. Dlatego budowniczy argumentów modułu nie przekazuje `-E`.

## openpty

Interaktywne sesje PTY używają `openpty()`. bionic deklaruje je w `<pty.h>`, a skrośny `configure`
Dropbear wykrywa je z NDK (`HAVE_OPENPTY` jest ustawiane, `HAVE_PTY_H 1`), więc **żadna łatka nie jest
potrzebna**; PTY działają od razu. (Użycie nieinteraktywne, jak exec, SFTP, rsync i przekazywanie
portów, i tak od tego nie zależy.)

## Wbudowane narzędzia: sftp-server, scp, rsync

`scripts/build-bundles.sh` kompiluje skrośnie narzędzia do transferu plików jako dynamiczne binarki do
`module/bin/<abi>/`. CI uruchamia je zaraz po `build.sh`.

- **rsync** (z wbudowanymi popt + zlib) kompiluje się czysto, gdy tylko powiesz jego configure, że
  bionic nie ma `lutimes` (`ac_cv_func_lutimes=no`).
- **sftp-server** i **scp** pochodzą z **OpenSSH portable**, budowane z `--without-openssl` (wbudowana
  krypto OpenSSH wystarcza dla tych dwóch), z małym statycznym **zlib**, który ten skrypt buduje jako
  pierwszy.

OpenSSH na Androidzie jest tak samo kapryśny jak historia crypt() powyżej, bo jego `configure` błędnie
wykrywa kilka funkcji libc przy kompilacji skrośnej. Skrypt koduje poprawkę; dla porządku, elementy to:

1. **Seed cache funkcji, których bionic nie ma**, ale configure sądzi, że je ma, aby zamiast nich
   kompilowane były wersje compat: `recallocarray`, `close_range`, `getentropy`, `getrandom`,
   `nl_langinfo`, `setpwent`/`getpwent`/`endpwent`, `crypt`, `futimes`, `lutimes`, `strtonum`, `pledge`,
   `explicit_bzero`.
2. **`-DHAVE_ATTRIBUTE__SENTINEL__=1 -DHAVE_ATTRIBUTE__NONNULL__=1`.** Bez nich `defines.h` OpenSSH robi
   `#define __sentinel__` (puste), co następnie psuje własny `__attribute__((__sentinel__(1)))` bionic w
   `<unistd.h>` i każda kompilacja kończy się błędem `expected ')'`.
3. **Compat `explicit_bzero`, który używa `memset`.** `bzero` bionic to makro funkcyjne (nie prawdziwy
   symbol), więc domyślny compat OpenSSH, który bierze `&bzero` jako wskaźnik funkcji, nie kompiluje
   się. bionic nie ma własnego `explicit_bzero`.
4. **Odrzucenie `xcrypt.o` i `getrrsetbyname.o`** z biblioteki compat. `xcrypt.c` wywołuje
   `getpwent()`/`crypt()` bezwarunkowo (bionic nie ma żadnego z nich), a `getrrsetbyname.c` używa
   wewnętrznych elementów resolvera, których bionic nie udostępnia. Żadne z nich nie jest używane przez
   `sftp-server` ani `scp`.
5. **`-Wl,--allow-multiple-definition`.** `reallocarray` to lustrzane odbicie funkcji z (1): bionic nie
   *deklaruje* go w API 24, więc OpenSSH kompiluje własny compat, ale **symbol** jak najbardziej istnieje
   w `libc.a`, więc oba kolidują przy linkowaniu. Dopuszczenie duplikatu bierze ten z bionic, co jest w
   porządku.
6. **Zabezpieczenie `pw_gecos` przed NULL w `pwcopy()`.** `getpwuid()` bionic zwraca `NULL`-owe
   `pw_gecos` (Android nie trzyma pola GECOS). `pwcopy()` OpenSSH zabezpiecza `pw_passwd` przed `NULL`,
   ale nie `pw_gecos`, więc `sftp-server` dochodzi do `xstrdup(NULL)` i robi SIGSEGV przy starcie, w
   chwili, gdy otwiera się sesja. (`scp` przez protokół legacy nigdy nie wywołuje `pwcopy`, dlatego
   działał, podczas gdy SFTP nie.) Build łata `pwcopy()`, by scalić `pw_gecos` do `""`.

Przypięte wersje znajdują się na górze `scripts/build-bundles.sh` (`ZLIB_VERSION`, `RSYNC_VERSION`,
`OPENSSH_VERSION`).

## Odtworzenie pojedynczego ABI ręcznie

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

> _Ta dokumentacja została wygenerowana za pomocą Claude (Anthropic) i jest utrzymywana przez VD171. Poprawki i ulepszenia są mile widziane; zobacz [CONTRIBUTING.md](CONTRIBUTING.md)._
