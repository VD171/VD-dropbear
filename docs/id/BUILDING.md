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

> **Languages:** [English](../BUILDING.md) · [العربية](../ar/BUILDING.md) · [Čeština](../cs/BUILDING.md) · [Deutsch](../de/BUILDING.md) · [Español](../es/BUILDING.md) · [فارسی](../fa/BUILDING.md) · [Français](../fr/BUILDING.md) · [हिन्दी](../hi/BUILDING.md) · Bahasa Indonesia · [Italiano](../it/BUILDING.md) · [日本語](../ja/BUILDING.md) · [한국어](../ko/BUILDING.md) · [Nederlands](../nl/BUILDING.md) · [Polski](../pl/BUILDING.md) · [Português](../pt/BUILDING.md) · [Русский](../ru/BUILDING.md) · [Svenska](../sv/BUILDING.md) · [ไทย](../th/BUILDING.md) · [Türkçe](../tr/BUILDING.md) · [Українська](../uk/BUILDING.md) · [Tiếng Việt](../vi/BUILDING.md) · [中文](../zh/BUILDING.md)

---

# Membangun VD Dropbear

VD Dropbear mengirimkan **[Dropbear](https://github.com/mkj/dropbear) upstream** (tag yang disematkan di
[`UPSTREAM_VERSION`](../../UPSTREAM_VERSION)) ditambah set patch kecil yang dapat diaudit di
[`patches/`](../../patches/). CI membangunnya, Anda bisa mereproduksinya secara lokal.

## Mulai cepat

```sh
# sekali: sebuah Android NDK (r27 atau lebih baru)
export NDK=/path/to/android-ndk

# bangun setiap ABI (arm64-v8a armeabi-v7a x86 x86_64)
./scripts/build.sh

# atau hanya satu, untuk iterasi cepat
ABIS="arm64-v8a" ./scripts/build.sh
```

`scripts/build.sh` mengklon tag upstream yang disematkan, menerapkan `patches/*.patch` dan
`localoptions.h`, lalu mengompilasi silang `vddropbear` dan `dropbearkey` ke `module/bin/<abi>/`.
Keluarannya adalah ELF **dinamis** (`file` melaporkan `dynamically linked, interpreter
/system/bin/linker64 … for Android 24`), ditautkan terhadap libc bionic yang sudah dimiliki setiap
perangkat Android. libtomcrypt tetap tertanam di dalam biner, hanya pustaka C yang dinamis. Lihat
[Dinamis, bukan static-PIE](#dinamis-bukan-static-pie).

Biner **tidak di-commit**, keduanya dibangun oleh CI pada setiap tag dan dilampirkan ke rilis. Lihat
[`.gitignore`](../../.gitignore).

---

## Kisah crypt()/libcrypto (mengapa auth kata sandi butuh kerja nyata)

Autentikasi kata sandi Dropbear ditulis untuk host Unix biasa dengan `crypt()` dan `/etc/shadow`.
Android **tidak punya keduanya**, dan itu berbenturan dengan build di tiga tempat terpisah. Bagian ini
mendokumentasikan masing-masing, karena ini persis jenis hal yang menyakitkan untuk ditemukan kembali.
Semuanya ditangani oleh patch [`0003-password-file.patch`](../../patches/0003-password-file.patch), tidak
ada yang di bawah ini diserahkan pada keberuntungan saat runtime.

### 1. bionic tidak punya `crypt()` yang dapat dipakai

Pustaka C Android (bionic) tidak menyediakan `crypt()`, `crypt_r()`, maupun basis data shadow. NDK tidak
mengekspos `<crypt.h>` apa pun. Jadi jalur kata sandi standar Dropbear, yang memanggil `crypt(password,
salt)` dan membandingkan terhadap `/etc/shadow`, sama sekali tidak bisa dibangun atau dijalankan di
Android. Juga tidak ada `libcrypt` untuk ditautkan, dan menarik `libcrypto` OpenSSL hanya untuk hash kata
sandi akan menjadi dependensi besar dan canggung untuk biner statis.

**Jawaban kami:** sama sekali tidak memakai `crypt()`. Auth kata sandi memverifikasi kata sandi yang
disajikan dengan **PBKDF2-HMAC-SHA256** terhadap berkas hash (`DROPBEAR_PASSWD_FILE`), sebuah KDF publik,
standar, bergaram, dan beriterasi. Format berkas didokumentasikan di
[`patches/README.md`](../../patches/README.md).

### 2. penjaga waktu kompilasi di `sysoptions.h`

Bahkan sebelum ada kode yang berjalan, Dropbear menolak untuk dibangun:

```c
#if DROPBEAR_SVR_PASSWORD_AUTH && !HAVE_CRYPT
    #error "DROPBEAR_SVR_PASSWORD_AUTH requires `crypt()'."
#endif
```

Dengan `HAVE_CRYPT` tidak terdefinisi (selalu, di bionic) dan auth kata sandi diaktifkan, ini adalah
`#error` yang keras. Karena verifikator kami tidak pernah memanggil `crypt()`, patch `0003` **menghapus
penjaga ini**. (Ia membiarkan utuh pemeriksaan "setidaknya satu metode auth harus diaktifkan".)

### 3. jebakan libtomcrypt: PBKDF2 dikompilasi *keluar*

Dropbear menanamkan **libtomcrypt** yang dipangkas, yang *memang* berisi PBKDF2 (`pkcs_5_alg2`,
`src/misc/pkcs5/pkcs_5_2.c`). Perbaikan yang jelas adalah memanggilnya. Itu tidak berhasil, karena dua
alasan yang saling memperkuat:

- **Prototipenya tersembunyi.** `pkcs_5_alg2` dideklarasikan hanya di dalam `#ifdef LTC_PKCS_5` di
  `tomcrypt_pkcs.h`. Berkas sumber *milik* Dropbear sendiri tidak dikompilasi dengan `LTC_PKCS_5`
  terdefinisi, jadi deklarasinya tidak terlihat dan kompilator gagal dengan *implicit function
  declaration*.
- **Simbolnya tidak ada.** Lebih buruk, *tubuh* dari `pkcs_5_alg2` juga berada di balik `#ifdef
  LTC_PKCS_5`. Build libtomcrypt Dropbear tidak mendefinisikannya, jadi `pkcs_5_2.o` dikompilasi menjadi
  **objek kosong**: ia ada di `libtomcrypt.a`, tetapi tidak berisi simbol `pkcs_5_alg2`. Penautan gagal
  dengan `undefined symbol: pkcs_5_alg2`.

Anda bisa melihatnya sendiri:

```sh
# objeknya ada tapi kosong (tanpa T pkcs_5_alg2):
llvm-nm build/dropbear-*/libtomcrypt/src/misc/pkcs5/pkcs_5_2.o
# -> hanya penanda data, tanpa pkcs_5_alg2

# HMAC, sebaliknya, dikompilasi penuh (Dropbear memakainya untuk MAC SSH):
llvm-nm build/dropbear-*/libtomcrypt/src/mac/hmac/hmac_memory.o
# -> mendefinisikan hmac_memory
```

**Jawaban kami:** membangun PBKDF2 sendiri di atas primitif yang *memang* dikompilasi Dropbear.
`hmac_memory` dan hash `sha256` terdaftar keduanya hadir dan dapat ditautkan, jadi patch `0003`
mengimplementasikan PBKDF2-HMAC-SHA256 secara langsung (RFC 2898; satu blok keluaran 32 bita, karena
`dkLen == hLen` untuk SHA-256). Kami mendeklarasikan `hmac_memory` sendiri (masalah prototipe
tersembunyi yang sama seperti di atas) dan objeknya ditarik dari `libtomcrypt.a` saat penautan. Hasilnya
adalah PBKDF2 standar dan karenanya dapat dioperasikan bersama: hash yang dihitung WebUI dengan
**WebCrypto** `deriveBits` peramban identik bita per bita dengan yang dihitung server, diverifikasi
terhadap `hashlib.pbkdf2_hmac` Python sebagai implementasi ketiga yang independen.

> **Singkatnya:** Android tidak memberi Anda `crypt()` apa pun, dan PBKDF2 bawaan Dropbear dikompilasi
> menjadi nihil. Auth kata sandi di sini adalah PBKDF2-HMAC-SHA256 dari nol di atas HMAC libtomcrypt,
> dengan penjaga build crypt() dihapus. Tanpa OpenSSL/`libcrypto`, tanpa obfuskasi, tanpa shadow sistem.

---

## Dinamis, bukan static-PIE

Biner bersifat **dinamis** (ditautkan terhadap bionic sistem via `/system/bin/linker64`), bukan statis.
Ini penting, dan dipelajari dengan cara sulit, **di perangkat nyata**, bukan di CI:

- Build **static-PIE** *tampak* baik-baik saja (`file` melaporkan `static-pie executable` yang bersih)
  dan menaut tanpa galat, tetapi **melakukan SIGSEGV pada saat ia berjalan di perangkat** (diverifikasi
  di ponsel arm64 Android 16, exit 139, tanpa tombstone yang berguna). Eksekutabel statis di Android
  rapuh, bentuk yang andal adalah biner dinamis biasa, yang juga merupakan cara setiap dropbear Android
  mapan dikirimkan.
- Build **statis, non-PIE** bahkan tidak memulai: bionic menolaknya dengan
  `executable's TLS segment is underaligned … needs to be at least 64 for ARM64 Bionic`.
- Jadi build-nya **dinamis** (`make` tanpa `STATIC=1`; `-pie`), hanya menautkan libc bionic yang hadir di
  setiap perangkat. libtomcrypt tetap tertanam secara statis di dalam biner, jadi tidak ada pustaka
  tambahan untuk dikirim.

Pelajaran untuk pengujian: **`qemu-aarch64` (qemu-user) bukan smoke test yang sahih** di sini (ia juga
segfault pada biner-biner ini), dan compile+link yang sukses pun bukan. **Jalankan biner di perangkat
Android arm64 nyata.** (Ini divalidasi persis begini: daemon
diluncurkan pada port alternatif di perangkat hidup dan login kata sandi dikonfirmasi berhasil, dengan
kata sandi yang salah ditolak.)

## Tanpa flag `-E`

Server dibangun dengan `--disable-syslog`, jadi ia selalu mencatat ke stderr dan opsi upstream `-E`
("log to stderr") **tidak ada** di biner ini, meneruskannya mencetak `Invalid option -E` dan daemon tidak
pernah memulai. Karena itu pembangun argumen modul tidak meneruskan `-E`.

## openpty

Sesi PTY interaktif memakai `openpty()`. bionic mendeklarasikannya di `<pty.h>`, dan `configure` silang
Dropbear mendeteksinya dengan NDK (`HAVE_OPENPTY` disetel, `HAVE_PTY_H 1`), jadi **tidak ada patch yang
diperlukan**, PTY bekerja langsung. (Penggunaan non-interaktif seperti exec, SFTP, rsync, dan penerusan
port toh tidak bergantung padanya.)

## Alat bawaan: sftp-server, scp, rsync

`scripts/build-bundles.sh` mengompilasi silang alat transfer berkas sebagai biner dinamis ke
`module/bin/<abi>/`. CI menjalankannya tepat setelah `build.sh`.

- **rsync** (dengan popt + zlib bawaan) dikompilasi bersih begitu Anda memberi tahu configure-nya bahwa
  bionic tidak punya `lutimes` (`ac_cv_func_lutimes=no`).
- **sftp-server** dan **scp** berasal dari **OpenSSH portable**, dibangun dengan `--without-openssl`
  (kripto bawaan OpenSSH cukup untuk keduanya), dengan **zlib** statis kecil yang dibangun skrip ini
  lebih dulu.

OpenSSH di Android serewel kisah crypt() di atas, karena `configure`-nya salah mendeteksi beberapa fungsi
libc saat kompilasi silang. Skrip mengkodekan perbaikannya, sebagai catatan, bagian-bagiannya adalah:

1. **Seed cache fungsi yang tidak dimiliki bionic** tetapi configure mengira ada, agar versi compat-nya
   yang dikompilasi: `recallocarray`, `close_range`, `getentropy`, `getrandom`, `nl_langinfo`,
   `setpwent`/`getpwent`/`endpwent`, `crypt`, `futimes`, `lutimes`, `strtonum`, `pledge`,
   `explicit_bzero`.
2. **`-DHAVE_ATTRIBUTE__SENTINEL__=1 -DHAVE_ATTRIBUTE__NONNULL__=1`.** Tanpa ini, `defines.h` OpenSSH
   melakukan `#define __sentinel__` (kosong), yang kemudian merusak `__attribute__((__sentinel__(1)))`
   milik bionic sendiri di `<unistd.h>` dan setiap kompilasi gagal dengan `expected ')'`.
3. **Sebuah compat `explicit_bzero` yang memakai `memset`.** `bzero` bionic adalah makro mirip fungsi
   (bukan simbol nyata), jadi compat default OpenSSH, yang mengambil `&bzero` sebagai penunjuk fungsi,
   tidak dikompilasi. bionic tidak punya `explicit_bzero` sendiri.
4. **Membuang `xcrypt.o` dan `getrrsetbyname.o`** dari pustaka compat. `xcrypt.c` memanggil
   `getpwent()`/`crypt()` tanpa syarat (bionic tidak punya keduanya), dan `getrrsetbyname.c` memakai
   internal resolver yang tidak diekspos bionic. Keduanya tidak dipakai oleh `sftp-server` atau `scp`.
5. **`-Wl,--allow-multiple-definition`.** `reallocarray` adalah bayangan cermin dari fungsi di (1):
   bionic tidak *mendeklarasikannya* di API 24, jadi OpenSSH mengompilasi compat-nya sendiri, tetapi
   **simbolnya** memang ada di `libc.a`, jadi keduanya bertabrakan saat penautan. Mengizinkan duplikat
   mengambil milik bionic, yang mana tidak masalah.
6. **Menjaga `pw_gecos` terhadap NULL di `pwcopy()`.** `getpwuid()` bionic mengembalikan `pw_gecos`
   bernilai `NULL` (Android tidak menyimpan field GECOS). `pwcopy()` OpenSSH menjaga `pw_passwd`
   terhadap `NULL` tetapi tidak `pw_gecos`, jadi `sftp-server` mencapai `xstrdup(NULL)` dan SIGSEGV saat
   mulai, pada saat sesi dibuka. (`scp` lewat protokol lawas tidak pernah memanggil `pwcopy`, itulah
   sebabnya ia bekerja sementara SFTP tidak.) Build menambal `pwcopy()` untuk menyatukan `pw_gecos`
   menjadi `""`.

Versi yang disematkan berada di bagian atas `scripts/build-bundles.sh` (`ZLIB_VERSION`, `RSYNC_VERSION`,
`OPENSSH_VERSION`).

## Mereproduksi satu ABI secara manual

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

> _Dokumentasi ini dibuat dengan Claude (Anthropic) dan dikelola oleh VD171. Koreksi dan perbaikan dipersilakan, lihat [CONTRIBUTING.md](CONTRIBUTING.md)._
