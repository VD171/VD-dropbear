<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk. No invasive ADB exposure.
   Architecture.

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

> **Languages:** [English](../ARCHITECTURE.md) · [العربية](../ar/ARCHITECTURE.md) · [Čeština](../cs/ARCHITECTURE.md) · [Deutsch](../de/ARCHITECTURE.md) · [Español](../es/ARCHITECTURE.md) · [فارسی](../fa/ARCHITECTURE.md) · [Français](../fr/ARCHITECTURE.md) · [हिन्दी](../hi/ARCHITECTURE.md) · Bahasa Indonesia · [Italiano](../it/ARCHITECTURE.md) · [日本語](../ja/ARCHITECTURE.md) · [한국어](../ko/ARCHITECTURE.md) · [Nederlands](../nl/ARCHITECTURE.md) · [Polski](../pl/ARCHITECTURE.md) · [Português](../pt/ARCHITECTURE.md) · [Русский](../ru/ARCHITECTURE.md) · [Svenska](../sv/ARCHITECTURE.md) · [ไทย](../th/ARCHITECTURE.md) · [Türkçe](../tr/ARCHITECTURE.md) · [Українська](../uk/ARCHITECTURE.md) · [Tiếng Việt](../vi/ARCHITECTURE.md) · [中文](../zh/ARCHITECTURE.md)

---

# Arsitektur

VD Dropbear adalah modul KernelSU / APatch / Magisk yang menjalankan tepat satu daemon SSH Dropbear,
yang sepenuhnya dikendalikan oleh konfigurasi. Tidak ada bagian dari server SSH yang di-hardcode untuk
satu perangkat; semua yang spesifik berupa konfigurasi runtime atau sebuah secret.

## Bagian-bagian

- `module/common/vddropbear.sh`, pustaka inti: memuat konfigurasi (dengan default bawaan yang aman),
  menentukan secret store, memastikan ada host key, menyusun vektor argumen Dropbear, dan mengelola
  satu instance daemon tunggal (start / stop / status / restart).
- `module/service.sh`: titik masuk boot. Mematuhi kebijakan start BFU/AFU; dalam mode AFU ia menunggu
  penyimpanan credential-encrypted terbuka tanpa menahan proses boot.
- `module/action.sh`, tombol **Action** pada manajer: (men)jalankan ulang daemon. Ia tidak pernah
  membaca stdin dan melepaskan daemon ke sesinya sendiri, sehingga manajer tidak menggantung.
- `module/common/vddb-webui.sh` + `module/webroot/index.html`: backend dan halaman WebUI.
- `patches/`: patch kecil yang dapat diaudit, diterapkan ke Dropbear upstream saat build.
- `scripts/build.sh`, `scripts/build-bundles.sh`, `.github/workflows/build.yml`: proses build.

## Siklus hidup daemon (instance tunggal)

`vddb_start` memuat konfigurasi, menghentikan instance yang sedang berjalan, memastikan ada host key,
lalu menelurkan satu daemon. Binary dikirim sebagai `vddropbear`, sehingga nama prosesnya cocok persis
dengan `pgrep -x` (`mksh` Android tidak punya `exec -a`). Ia dijalankan dengan `setsid` agar terlepas
dari grup proses pemanggil: itulah yang membuat tombol Action manajer tidak terblokir.

## Secret store (CE vs DE, BFU vs AFU)

Pengaturan bukanlah secret dan berada di penyimpanan device-encrypted (`/data/adb/vddropbear`), yang
dapat dibaca saat boot. Secret (host key, `authorized_keys`, hash kata sandi) secara default berada
di penyimpanan **credential-encrypted** (`/data/misc_ce/0/vddropbear`), yang baru terbuka setelah
pengguna terautentikasi. Mengaktifkan `START_IN_BFU` memindahkan secret ke penyimpanan device-encrypted
agar daemon dapat berjalan sebelum first unlock, dengan konsekuensi secret tersebut dapat dibaca lebih
awal. Modul menghitung store mana yang dipakai di setiap tahap boot.

## Kumpulan patch

Server SSH tetap Dropbear upstream; perubahan kami hanya beberapa patch yang dapat ditinjau (lihat
[patches/README.md](../../patches/README.md)):

- banner identitas yang netral dan dapat dikonfigurasi saat runtime;
- `authorized_keys` dibaca dari jalur yang diatur lewat environment (agar kunci berada di secret store);
- autentikasi kata sandi terhadap berkas hash PBKDF2, bukan `crypt()`/shadow sistem yang tidak ada di
  Android (lihat [BUILDING.md](../BUILDING.md)).

## WebUI

Sebuah halaman statis di WebUI manajer (KernelSU / APatch / WebUI-X). Ia menggerakkan
`module/common/vddb-webui.sh` melalui jembatan `ksu.exec`: status, start/stop/restart, baca/tulis
konfigurasi, serta pengelolaan kunci dan akun kata sandi. Semua data menyeberangi jembatan dalam bentuk
base64, sehingga shell tidak pernah menafsirkannya; hash kata sandi dihitung di browser dengan
WebCrypto, sehingga kata sandi teks-jelas tidak pernah keluar dari halaman.
