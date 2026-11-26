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

> **Languages:** [English](../BUILDING.md) · [العربية](../ar/BUILDING.md) · Čeština · [Deutsch](../de/BUILDING.md) · [Español](../es/BUILDING.md) · [فارسی](../fa/BUILDING.md) · [Français](../fr/BUILDING.md) · [हिन्दी](../hi/BUILDING.md) · [Bahasa Indonesia](../id/BUILDING.md) · [Italiano](../it/BUILDING.md) · [日本語](../ja/BUILDING.md) · [한국어](../ko/BUILDING.md) · [Nederlands](../nl/BUILDING.md) · [Polski](../pl/BUILDING.md) · [Português](../pt/BUILDING.md) · [Русский](../ru/BUILDING.md) · [Svenska](../sv/BUILDING.md) · [ไทย](../th/BUILDING.md) · [Türkçe](../tr/BUILDING.md) · [Українська](../uk/BUILDING.md) · [Tiếng Việt](../vi/BUILDING.md) · [中文](../zh/BUILDING.md)

---

# Sestavení VD Dropbear

VD Dropbear dodává **[Dropbear](https://github.com/mkj/dropbear) upstream** (tag připnutý v
[`UPSTREAM_VERSION`](../../UPSTREAM_VERSION)) plus malou, auditovatelnou sadu patchů v
[`patches/`](../../patches/). CI jej sestavuje, můžeš to reprodukovat lokálně.

## Rychlý start

```sh
# jednorázově: Android NDK (r27 nebo novější)
export NDK=/path/to/android-ndk

# sestav každé ABI (arm64-v8a armeabi-v7a x86 x86_64)
./scripts/build.sh

# nebo jen jedno, pro rychlé iterace
ABIS="arm64-v8a" ./scripts/build.sh
```

`scripts/build.sh` naklonuje připnutý upstream tag, aplikuje `patches/*.patch` a `localoptions.h` a poté
křížově zkompiluje `vddropbear` a `dropbearkey` do `module/bin/<abi>/`. Výstupem je **dynamický** ELF
(`file` hlásí `dynamically linked, interpreter /system/bin/linker64 … for Android 24`), slinkovaný proti
bionic libc, kterou každé zařízení s Androidem už má. libtomcrypt zůstává vestavěný v binárce, dynamická
je jen knihovna C. Viz [Dynamický, ne static-PIE](#dynamický-ne-static-pie).

Binárky se **necommitují**, sestavuje je CI při každém tagu a připojuje je k vydání. Viz
[`.gitignore`](../../.gitignore).

---

## Příběh crypt()/libcrypto (proč autentizace heslem vyžadovala skutečnou práci)

Autentizace heslem v Dropbearu je napsaná pro běžný unixový host s `crypt()` a `/etc/shadow`. Android
**nemá ani jedno**, a to naráží na sestavení na třech samostatných místech. Tato sekce dokumentuje každé
z nich, protože je to přesně ten druh věci, který je bolestivé znovu objevovat. Vše řeší patch
[`0003-password-file.patch`](../../patches/0003-password-file.patch), nic níže není za běhu ponecháno
náhodě.

### 1. bionic nemá použitelné `crypt()`

Knihovna C Androidu (bionic) neposkytuje `crypt()`, `crypt_r()` ani databázi shadow. NDK nevystavuje
žádné `<crypt.h>`. Takže standardní cesta hesla v Dropbearu, která volá `crypt(password, salt)` a
porovnává proti `/etc/shadow`, jednoduše nejde na Androidu sestavit ani spustit. Není ani žádné
`libcrypt`, se kterým by se dalo slinkovat, a tahat `libcrypto` z OpenSSL jen kvůli hashi hesla by byla
velká, nemotorná závislost pro statickou binárku.

**Naše odpověď:** `crypt()` vůbec nepoužívat. Autentizace heslem ověřuje předložené heslo pomocí
**PBKDF2-HMAC-SHA256** proti souboru hashů (`DROPBEAR_PASSWD_FILE`), veřejné, standardní, solené,
iterované KDF. Formát souboru je zdokumentován v [`patches/README.md`](../../patches/README.md).

### 2. kontrola v době kompilace v `sysoptions.h`

Ještě než se spustí jakýkoli kód, Dropbear odmítne sestavení:

```c
#if DROPBEAR_SVR_PASSWORD_AUTH && !HAVE_CRYPT
    #error "DROPBEAR_SVR_PASSWORD_AUTH requires `crypt()'."
#endif
```

S nedefinovaným `HAVE_CRYPT` (vždy, na bionicu) a zapnutou autentizací heslem je tohle tvrdý `#error`.
Protože náš ověřovač nikdy nevolá `crypt()`, patch `0003` **tuto kontrolu odstraňuje**. (Ponechává
nedotčenou kontrolu „musí být zapnutá alespoň jedna metoda autentizace".)

### 3. past libtomcrypt: PBKDF2 je vykompilováno *ven*

Dropbear vestavuje ořezaný **libtomcrypt**, který PBKDF2 *skutečně* obsahuje (`pkcs_5_alg2`,
`src/misc/pkcs5/pkcs_5_2.c`). Zřejmou opravou je jej zavolat. Nefunguje to, ze dvou skládajících se
důvodů:

- **Prototyp je skrytý.** `pkcs_5_alg2` je deklarován pouze uvnitř `#ifdef LTC_PKCS_5` v
  `tomcrypt_pkcs.h`. *Vlastní* zdrojové soubory Dropbearu se nekompilují s definovaným `LTC_PKCS_5`,
  takže deklarace je neviditelná a kompilátor selže s *implicit function declaration*.
- **Symbol neexistuje.** Hůř, samotné *tělo* `pkcs_5_alg2` je také za `#ifdef LTC_PKCS_5`. Build
  libtomcrypt v Dropbearu jej nedefinuje, takže `pkcs_5_2.o` se zkompiluje do **prázdného objektu**: je
  v `libtomcrypt.a`, ale neobsahuje žádný symbol `pkcs_5_alg2`. Linkování selže s
  `undefined symbol: pkcs_5_alg2`.

Můžeš si to ověřit sám:

```sh
# objekt existuje, ale je prázdný (žádné T pkcs_5_alg2):
llvm-nm build/dropbear-*/libtomcrypt/src/misc/pkcs5/pkcs_5_2.o
# -> jen datová značka, žádné pkcs_5_alg2

# HMAC je naopak plně zkompilován (Dropbear jej používá pro MAC v SSH):
llvm-nm build/dropbear-*/libtomcrypt/src/mac/hmac/hmac_memory.o
# -> definuje hmac_memory
```

**Naše odpověď:** sestavit PBKDF2 sami nad primitivy, které Dropbear *skutečně* kompiluje. `hmac_memory`
i registrovaný hash `sha256` jsou oba přítomné a linkovatelné, takže patch `0003` implementuje
PBKDF2-HMAC-SHA256 přímo (RFC 2898; jediný 32bajtový výstupní blok, protože `dkLen == hLen` pro
SHA-256). `hmac_memory` deklarujeme sami (stejný problém se skrytým prototypem jako výše) a objekt se při
linkování vytáhne z `libtomcrypt.a`. Výsledkem je standardní PBKDF2, a tedy interoperabilní: hash, který
WebUI počítá pomocí **WebCrypto** `deriveBits` prohlížeče, je bajt po bajtu identický s tím, co počítá
server, ověřeno proti `hashlib.pbkdf2_hmac` v Pythonu jako třetí, nezávislé implementaci.

> **Stručně:** Android ti nedá žádné `crypt()` a vestavěné PBKDF2 Dropbearu je zkompilováno do ničeho.
> Autentizace heslem je tu PBKDF2-HMAC-SHA256 od nuly nad HMAC z libtomcrypt, s odstraněnou kontrolou
> sestavení crypt(). Žádné OpenSSL/`libcrypto`, žádná obfuskace, žádné systémové shadow.

---

## Dynamický, ne static-PIE

Binárky jsou **dynamické** (slinkované proti systémovému bionicu přes `/system/bin/linker64`), ne
statické. Na tom záleží a bylo to naučeno tvrdě, **na skutečném zařízení**, ne v CI:

- Build **static-PIE** *vypadá* v pořádku (`file` hlásí čistý `static-pie executable`) a slinkuje se bez
  chyby, ale **udělá SIGSEGV v okamžiku, kdy se spustí na zařízení** (ověřeno na telefonu arm64 s
  Androidem 16, exit 139, žádný užitečný tombstone). Statické spustitelné soubory na Androidu jsou
  křehké, spolehlivou formou je běžná dynamická binárka, což je také způsob, jakým se dodává každý
  zavedený dropbear pro Android.
- Build **statický, non-PIE** se ani nespustí: bionic jej odmítne s
  `executable's TLS segment is underaligned … needs to be at least 64 for ARM64 Bionic`.
- Takže build je **dynamický** (`make` bez `STATIC=1`; `-pie`), linkující jen bionic libc, přítomnou na
  každém zařízení. libtomcrypt je stále staticky vestavěný v binárce, takže není žádná knihovna navíc k
  dodání.

Lekce pro testování: **`qemu-aarch64` (qemu-user) zde není platný smoke test** (na těchto binárkách také
padá segfaultem), a úspěšná kompilace+linkování také ne. **Spusť binárku na skutečném zařízení arm64 s
Androidem.** (Tohle bylo validováno přesně takto: daemon
byl spuštěn na alternativním portu na živém zařízení a přihlášení heslem bylo potvrzeno jako úspěšné, se
zamítnutým chybným heslem.)

## Žádný flag `-E`

Server je sestaven s `--disable-syslog`, takže vždy loguje do stderr a upstreamová volba `-E` ("log to
stderr") v této binárce **neexistuje**, její předání vypíše `Invalid option -E` a daemon se nikdy
nespustí. Builder argumentů modulu proto `-E` nepředává.

## openpty

Interaktivní relace PTY používají `openpty()`. bionic jej deklaruje v `<pty.h>` a křížový `configure`
Dropbearu jej detekuje pomocí NDK (`HAVE_OPENPTY` se nastaví, `HAVE_PTY_H 1`), takže **žádný patch není
potřeba**, PTY fungují rovnou. (Neinteraktivní použití jako exec, SFTP, rsync a přesměrování portů na
něm stejně nezávisí.)

## Vestavěné nástroje: sftp-server, scp, rsync

`scripts/build-bundles.sh` křížově kompiluje nástroje pro přenos souborů jako dynamické binárky do
`module/bin/<abi>/`. CI jej spouští hned po `build.sh`.

- **rsync** (s vestavěnými popt + zlib) se zkompiluje čistě, jakmile jeho configure řekneš, že bionic
  nemá `lutimes` (`ac_cv_func_lutimes=no`).
- **sftp-server** a **scp** pocházejí z **OpenSSH portable**, sestavené s `--without-openssl` (vestavěná
  krypto OpenSSH pro tyto dva stačí), s malým statickým **zlib**, který tento skript sestaví jako první.

OpenSSH na Androidu je stejně vybíravé jako příběh crypt() výše, protože jeho `configure` při křížové
kompilaci špatně detekuje několik funkcí libc. Skript opravu kóduje, pro pořádek jsou díly:

1. **Seed cache funkcí, které bionicu chybí**, ale configure si myslí, že je má, aby se místo nich
   zkompilovaly verze compat: `recallocarray`, `close_range`, `getentropy`, `getrandom`, `nl_langinfo`,
   `setpwent`/`getpwent`/`endpwent`, `crypt`, `futimes`, `lutimes`, `strtonum`, `pledge`,
   `explicit_bzero`.
2. **`-DHAVE_ATTRIBUTE__SENTINEL__=1 -DHAVE_ATTRIBUTE__NONNULL__=1`.** Bez nich `defines.h` OpenSSH
   udělá `#define __sentinel__` (prázdné), což pak zmrší vlastní `__attribute__((__sentinel__(1)))`
   bionicu v `<unistd.h>` a každá kompilace selže s `expected ')'`.
3. **Compat `explicit_bzero`, který používá `memset`.** `bzero` bionicu je makro podobné funkci (ne
   skutečný symbol), takže výchozí compat OpenSSH, který bere `&bzero` jako ukazatel na funkci, se
   nezkompiluje. bionic nemá vlastní `explicit_bzero`.
4. **Vyřazení `xcrypt.o` a `getrrsetbyname.o`** z knihovny compat. `xcrypt.c` volá `getpwent()`/`crypt()`
   bezpodmínečně (bionic nemá ani jedno) a `getrrsetbyname.c` používá vnitřnosti resolveru, které bionic
   nevystavuje. Ani jedno není používáno `sftp-server` ani `scp`.
5. **`-Wl,--allow-multiple-definition`.** `reallocarray` je zrcadlovým obrazem funkcí z (1): bionic jej
   v API 24 *nedeklaruje*, takže OpenSSH kompiluje vlastní compat, ale **symbol** v `libc.a` existuje,
   takže oba při linkování kolidují. Povolení duplikátu vezme ten z bionicu, což je v pořádku.
6. **Ošetření `pw_gecos` proti NULL v `pwcopy()`.** `getpwuid()` bionicu vrací `NULL`-ové `pw_gecos`
   (Android nevede pole GECOS). `pwcopy()` OpenSSH ošetřuje `pw_passwd` proti `NULL`, ale ne `pw_gecos`,
   takže `sftp-server` dosáhne `xstrdup(NULL)` a udělá SIGSEGV při startu, v okamžiku, kdy se otevře
   relace. (`scp` přes legacy protokol `pwcopy` nikdy nevolá, proto fungoval, zatímco SFTP ne.) Build
   patchuje `pwcopy()`, aby sloučil `pw_gecos` na `""`.

Připnuté verze jsou nahoře v `scripts/build-bundles.sh` (`ZLIB_VERSION`, `RSYNC_VERSION`,
`OPENSSH_VERSION`).

## Ruční reprodukce jednoho ABI

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

> _Tato dokumentace byla vytvořena pomocí Claude (Anthropic) a spravuje ji VD171. Opravy a vylepšení jsou vítány, viz [CONTRIBUTING.md](CONTRIBUTING.md)._
