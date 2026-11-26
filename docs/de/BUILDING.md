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

> **Languages:** [English](../BUILDING.md) · [العربية](../ar/BUILDING.md) · [Čeština](../cs/BUILDING.md) · Deutsch · [Español](../es/BUILDING.md) · [فارسی](../fa/BUILDING.md) · [Français](../fr/BUILDING.md) · [हिन्दी](../hi/BUILDING.md) · [Bahasa Indonesia](../id/BUILDING.md) · [Italiano](../it/BUILDING.md) · [日本語](../ja/BUILDING.md) · [한국어](../ko/BUILDING.md) · [Nederlands](../nl/BUILDING.md) · [Polski](../pl/BUILDING.md) · [Português](../pt/BUILDING.md) · [Русский](../ru/BUILDING.md) · [Svenska](../sv/BUILDING.md) · [ไทย](../th/BUILDING.md) · [Türkçe](../tr/BUILDING.md) · [Українська](../uk/BUILDING.md) · [Tiếng Việt](../vi/BUILDING.md) · [中文](../zh/BUILDING.md)

---

# VD Dropbear bauen

VD Dropbear liefert das **[Dropbear](https://github.com/mkj/dropbear)-Upstream** (das in
[`UPSTREAM_VERSION`](../../UPSTREAM_VERSION) fixierte Tag) plus das kleine, prüfbare Patch-Set in
[`patches/`](../../patches/). Die CI baut es, du kannst es lokal reproduzieren.

## Schnellstart

```sh
# einmalig: ein Android NDK (r27 oder neuer)
export NDK=/path/to/android-ndk

# baue jede ABI (arm64-v8a armeabi-v7a x86 x86_64)
./scripts/build.sh

# oder nur eine, um schnell zu iterieren
ABIS="arm64-v8a" ./scripts/build.sh
```

`scripts/build.sh` klont das fixierte Upstream-Tag, wendet `patches/*.patch` und `localoptions.h` an und
cross-kompiliert dann `vddropbear` und `dropbearkey` nach `module/bin/<abi>/`. Die Ausgabe ist eine
**dynamische** ELF (`file` meldet `dynamically linked, interpreter /system/bin/linker64 … for Android
24`), gegen die bionic-libc gelinkt, die jedes Android-Gerät bereits hat. libtomcrypt bleibt im Binary
eingebettet, nur die C-Bibliothek ist dynamisch. Siehe [Dynamisch, nicht static-PIE](#dynamisch-nicht-static-pie).

Die Binaries werden **nicht committet**, sie werden von der CI bei jedem Tag gebaut und an das Release
angehängt. Siehe [`.gitignore`](../../.gitignore).

---

## Die crypt()/libcrypto-Geschichte (warum Passwort-Auth echte Arbeit brauchte)

Die Passwort-Authentifizierung von Dropbear ist für einen normalen Unix-Host mit `crypt()` und
`/etc/shadow` geschrieben. Android hat **keines von beidem**, und das kollidiert an drei getrennten
Stellen mit dem Build. Dieser Abschnitt dokumentiert jede davon, weil es genau die Art Sache ist, die
schmerzhaft neu zu entdecken ist. All das übernimmt der Patch
[`0003-password-file.patch`](../../patches/0003-password-file.patch), nichts davon ist zur Laufzeit dem
Zufall überlassen.

### 1. bionic hat kein brauchbares `crypt()`

Die C-Bibliothek von Android (bionic) bietet weder `crypt()`, `crypt_r()` noch eine Shadow-Datenbank.
Das NDK stellt kein `<crypt.h>` bereit. Der Standard-Passwortpfad von Dropbear, der `crypt(password,
salt)` aufruft und gegen `/etc/shadow` vergleicht, lässt sich also auf Android schlicht nicht bauen
oder ausführen. Es gibt auch kein `libcrypt` zum Linken, und OpenSSLs `libcrypto` nur für einen
Passwort-Hash hereinzuziehen wäre eine große, unhandliche Abhängigkeit für ein statisches Binary.

**Unsere Antwort:** `crypt()` gar nicht verwenden. Die Passwort-Auth prüft das vorgelegte Passwort mit
**PBKDF2-HMAC-SHA256** gegen eine Hash-Datei (`DROPBEAR_PASSWD_FILE`), eine öffentliche, standardisierte,
gesalzene, iterierte KDF. Das Dateiformat ist in [`patches/README.md`](../../patches/README.md)
dokumentiert.

### 2. der Compile-Time-Guard in `sysoptions.h`

Noch bevor irgendein Code läuft, weigert sich Dropbear zu bauen:

```c
#if DROPBEAR_SVR_PASSWORD_AUTH && !HAVE_CRYPT
    #error "DROPBEAR_SVR_PASSWORD_AUTH requires `crypt()'."
#endif
```

Mit nicht gesetztem `HAVE_CRYPT` (immer, auf bionic) und aktivierter Passwort-Auth ist dies ein harter
`#error`. Da unser Verifizierer `crypt()` nie aufruft, **entfernt** der Patch `0003` diesen Guard. (Die
Prüfung „mindestens eine Auth-Methode muss aktiviert sein" bleibt erhalten.)

### 3. die libtomcrypt-Falle: PBKDF2 wird *heraus*kompiliert

Dropbear bettet ein abgespecktes **libtomcrypt** ein, das PBKDF2 *tatsächlich* enthält (`pkcs_5_alg2`,
`src/misc/pkcs5/pkcs_5_2.c`). Die naheliegende Lösung ist, es aufzurufen. Das funktioniert nicht, aus
zwei sich verstärkenden Gründen:

- **Der Prototyp ist versteckt.** `pkcs_5_alg2` wird nur innerhalb von `#ifdef LTC_PKCS_5` in
  `tomcrypt_pkcs.h` deklariert. Dropbears *eigene* Quelldateien werden nicht mit definiertem
  `LTC_PKCS_5` kompiliert, also ist die Deklaration unsichtbar und der Compiler bricht mit *implicit
  function declaration* ab.
- **Das Symbol existiert nicht.** Schlimmer noch, der *Rumpf* von `pkcs_5_alg2` steht selbst hinter
  `#ifdef LTC_PKCS_5`. Dropbears libtomcrypt-Build definiert es nicht, also kompiliert `pkcs_5_2.o` zu
  einem **leeren Objekt**: es ist in `libtomcrypt.a`, enthält aber kein `pkcs_5_alg2`-Symbol. Der Link
  schlägt mit `undefined symbol: pkcs_5_alg2` fehl.

Du kannst das selbst sehen:

```sh
# das Objekt existiert, ist aber leer (kein T pkcs_5_alg2):
llvm-nm build/dropbear-*/libtomcrypt/src/misc/pkcs5/pkcs_5_2.o
# -> nur ein Datenmarker, kein pkcs_5_alg2

# HMAC dagegen ist voll kompiliert (Dropbear nutzt es für SSH-MACs):
llvm-nm build/dropbear-*/libtomcrypt/src/mac/hmac/hmac_memory.o
# -> definiert hmac_memory
```

**Unsere Antwort:** PBKDF2 selbst auf den Primitiven bauen, die Dropbear *tatsächlich* kompiliert.
`hmac_memory` und der registrierte `sha256`-Hash sind beide vorhanden und linkbar, also implementiert
der Patch `0003` PBKDF2-HMAC-SHA256 direkt (RFC 2898; ein einzelner 32-Byte-Ausgabeblock, da `dkLen ==
hLen` für SHA-256). Wir deklarieren `hmac_memory` selbst (dasselbe Problem mit verstecktem Prototyp wie
oben) und das Objekt wird beim Linken aus `libtomcrypt.a` gezogen. Das Ergebnis ist Standard-PBKDF2 und
damit interoperabel: der Hash, den die WebUI mit dem **WebCrypto**-`deriveBits` des Browsers berechnet,
ist byteidentisch mit dem, den der Server berechnet, verifiziert gegen Pythons `hashlib.pbkdf2_hmac` als
dritte, unabhängige Implementierung.

> **Kurz gesagt:** Android gibt dir kein `crypt()`, und Dropbears eingebettetes PBKDF2 wird zu nichts
> kompiliert. Die Passwort-Auth ist hier ein von Grund auf neues PBKDF2-HMAC-SHA256 über libtomcrypts
> HMAC, mit entferntem crypt()-Build-Guard. Kein OpenSSL/`libcrypto`, keine Verschleierung, kein
> System-Shadow.

---

## Dynamisch, nicht static-PIE

Die Binaries sind **dynamisch** (gegen das System-bionic via `/system/bin/linker64` gelinkt), nicht
statisch. Das ist wichtig, und es wurde auf die harte Tour gelernt, **auf einem echten Gerät**, nicht
in der CI:

- Ein **static-PIE**-Build *sieht* in Ordnung aus (`file` meldet ein sauberes `static-pie executable`)
  und linkt fehlerfrei, aber **macht in dem Moment, in dem er auf dem Gerät läuft, einen SIGSEGV**
  (verifiziert auf einem arm64-Android-16-Telefon, exit 139, kein nützlicher Tombstone). Statische
  Executables auf Android sind fragil, die verlässliche Form ist ein normales dynamisches Binary, was
  auch die Art ist, wie jedes etablierte Android-Dropbear ausgeliefert wird.
- Ein **statischer, non-PIE**-Build startet nicht einmal: bionic weist ihn ab mit
  `executable's TLS segment is underaligned … needs to be at least 64 for ARM64 Bionic`.
- Der Build ist also **dynamisch** (`make` ohne `STATIC=1`; `-pie`), linkt nur die auf jedem Gerät
  vorhandene bionic-libc. libtomcrypt ist weiterhin statisch ins Binary eingebettet, es gibt also keine
  zusätzliche Bibliothek zum Ausliefern.

Lektion fürs Testen: **`qemu-aarch64` (qemu-user) ist hier kein gültiger Smoke-Test** (er macht bei
diesen Binaries ebenfalls einen Segfault), und ein erfolgreiches Compile+Link auch nicht. **Führe das
Binary auf einem echten arm64-Android-Gerät aus.** (Das wurde genau so validiert: der Daemon wurde auf einem alternativen Port auf einem Live-Gerät
gestartet und ein Passwort-Login als erfolgreich bestätigt, ein falsches Passwort abgewiesen.)

## Keine `-E`-Flag

Der Server wird mit `--disable-syslog` gebaut, loggt also immer nach stderr, und die Upstream-Option
`-E` („log to stderr") **existiert nicht** in diesem Binary, sie zu übergeben gibt `Invalid option -E`
aus und der Daemon startet nie. Der Argument-Builder des Moduls übergibt `-E` daher nicht.

## openpty

Interaktive PTY-Sitzungen nutzen `openpty()`. bionic deklariert es in `<pty.h>`, und Dropbears
Cross-`configure` erkennt es mit dem NDK (`HAVE_OPENPTY` wird gesetzt, `HAVE_PTY_H 1`), also ist **kein
Patch nötig**, PTYs funktionieren sofort. (Nicht-interaktive Nutzung wie exec, SFTP, rsync und
Port-Forwarding hängt ohnehin nicht davon ab.)

## Eingebettete Tools: sftp-server, scp, rsync

`scripts/build-bundles.sh` cross-kompiliert die Dateiübertragungs-Tools als dynamische Binaries nach
`module/bin/<abi>/`. Die CI führt es direkt nach `build.sh` aus.

- **rsync** (mit eingebettetem popt + zlib) kompiliert sauber, sobald du seinem configure sagst, dass
  bionic kein `lutimes` hat (`ac_cv_func_lutimes=no`).
- **sftp-server** und **scp** stammen aus **OpenSSH portable**, gebaut mit `--without-openssl` (OpenSSLs
  eingebaute Krypto reicht für diese beiden), mit einem kleinen statischen **zlib**, das dieses Skript
  zuerst baut.

OpenSSH auf Android ist so heikel wie die crypt()-Geschichte oben, weil sein `configure` beim
Cross-Kompilieren mehrere libc-Funktionen falsch erkennt. Das Skript kodiert die Korrektur, fürs
Protokoll sind die Teile:

1. **Ein Cache-Seed der Funktionen, die bionic fehlen**, die configure aber zu haben glaubt, damit
   stattdessen die Compat-Versionen kompiliert werden: `recallocarray`, `close_range`, `getentropy`,
   `getrandom`, `nl_langinfo`, `setpwent`/`getpwent`/`endpwent`, `crypt`, `futimes`, `lutimes`,
   `strtonum`, `pledge`, `explicit_bzero`.
2. **`-DHAVE_ATTRIBUTE__SENTINEL__=1 -DHAVE_ATTRIBUTE__NONNULL__=1`.** Ohne sie macht OpenSSLs
   `defines.h` ein `#define __sentinel__` (leer), was dann bionics eigenes
   `__attribute__((__sentinel__(1)))` in `<unistd.h>` verstümmelt und jede Kompilierung mit
   `expected ')'` scheitern lässt.
3. **Ein `explicit_bzero`-Compat, das `memset` nutzt.** bionics `bzero` ist ein funktionsartiges Makro
   (kein echtes Symbol), also kompiliert OpenSSHs Standard-Compat, das `&bzero` als Funktionszeiger
   nimmt, nicht. bionic hat kein eigenes `explicit_bzero`.
4. **`xcrypt.o` und `getrrsetbyname.o` verwerfen** aus der Compat-Bibliothek. `xcrypt.c` ruft
   `getpwent()`/`crypt()` bedingungslos auf (bionic hat keines von beidem), und `getrrsetbyname.c` nutzt
   Resolver-Interna, die bionic nicht offenlegt. Keines von beiden wird von `sftp-server` oder `scp`
   genutzt.
5. **`-Wl,--allow-multiple-definition`.** `reallocarray` ist das Spiegelbild der Funktionen in (1):
   bionic *deklariert* es in API 24 nicht, also kompiliert OpenSSH sein eigenes Compat, aber das
   **Symbol** existiert sehr wohl in `libc.a`, sodass die beiden beim Linken kollidieren. Das Duplikat
   zuzulassen nimmt bionics, was in Ordnung ist.
6. **`pw_gecos` in `pwcopy()` gegen NULL absichern.** bionics `getpwuid()` gibt ein `NULL`-`pw_gecos`
   zurück (Android führt kein GECOS-Feld). OpenSSHs `pwcopy()` sichert `pw_passwd` gegen `NULL`, aber
   nicht `pw_gecos`, also erreicht `sftp-server` `xstrdup(NULL)` und macht beim Start einen SIGSEGV, im
   Moment, in dem eine Sitzung öffnet. (`scp` über das Legacy-Protokoll ruft `pwcopy` nie auf, weshalb
   es funktionierte, während SFTP es nicht tat.) Der Build patcht `pwcopy()`, um `pw_gecos` zu `""` zu
   koaleszieren.

Die fixierten Versionen stehen oben in `scripts/build-bundles.sh` (`ZLIB_VERSION`, `RSYNC_VERSION`,
`OPENSSH_VERSION`).

## Eine einzelne ABI von Hand reproduzieren

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

> _Diese Dokumentation wurde mit Claude (Anthropic) erstellt und wird von VD171 gepflegt. Korrekturen und Verbesserungen sind willkommen, siehe [CONTRIBUTING.md](CONTRIBUTING.md)._
