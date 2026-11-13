<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk - no invasive ADB exposure.
   AI agents on your device.

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

> **Languages:** [English](../AI-AGENTS.md) · [العربية](../ar/AI-AGENTS.md) · [Čeština](../cs/AI-AGENTS.md) · [Deutsch](../de/AI-AGENTS.md) · [Español](../es/AI-AGENTS.md) · [فارسی](../fa/AI-AGENTS.md) · [Français](../fr/AI-AGENTS.md) · [हिन्दी](../hi/AI-AGENTS.md) · Bahasa Indonesia · [Italiano](../it/AI-AGENTS.md) · [日本語](../ja/AI-AGENTS.md) · [한국어](../ko/AI-AGENTS.md) · [Nederlands](../nl/AI-AGENTS.md) · [Polski](../pl/AI-AGENTS.md) · [Português](../pt/AI-AGENTS.md) · [Русский](../ru/AI-AGENTS.md) · [Svenska](../sv/AI-AGENTS.md) · [ไทย](../th/AI-AGENTS.md) · [Türkçe](../tr/AI-AGENTS.md) · [Українська](../uk/AI-AGENTS.md) · [Tiếng Việt](../vi/AI-AGENTS.md) · [中文](../zh/AI-AGENTS.md)

---

# Agen AI di perangkat Anda

Sebuah endpoint SSH yang selalu aktif mengubah ponsel Anda menjadi sesuatu yang **dapat dioperasikan
langsung oleh agen AI otonom**. Agen apa pun yang bisa menjalankan shell atau koneksi SSH - Claude
Code, aider, skrip LLM-in-the-loop, otomatisasi buatan Anda sendiri - mendapatkan sesi root sungguhan
di perangkat, melalui jaringan, tanpa kabel USB dan tanpa satu pun flag debug ADB yang membongkar
dirinya sendiri.

Halaman ini memperluas gagasan yang diperkenalkan di README.

## Mengapa SSH, bukan ADB, untuk agen

ADB mengumumkan dirinya sendiri: `adb_enabled` dan `development_settings_enabled` dapat dibaca oleh
siapa saja, koneksinya tercatat, dan tidak ada cara yang didukung untuk menyembunyikan bahwa debugging
sedang (atau pernah) aktif. Agen yang bekerja melalui ADB meninggalkan jejak itu di perangkat untuk
dibaca oleh aplikasi atau SDK anti-penipuan mana pun. VD Dropbear adalah alternatif privat - login SSH
biasa, dengan kredensial yang Anda kendalikan dan banner yang tidak mengungkap apa pun.

## Apa yang bisa dilakukan agen

Melalui satu koneksi, agen melihat shell mirip Linux yang biasa dan dapat:

- membaca dan mengedit berkas, mengubah pengaturan, serta mengelola modul, paket, dan layanan;
- memilah log, menarik artefak, dan menjalankan diagnostik atau forensik sesuai permintaan;
- memindahkan dan menyinkronkan berkas dua arah melalui `scp` / `sftp` / `rsync` - pencadangan, migrasi, penyediaan;
- mengendalikan seluruh armada perangkat ter-root dari satu tempat, masing-masing dapat dijangkau dengan kuncinya sendiri.

Karena proyek ini dibangun agar **ramah AI** - berkas konfigurasi yang terdokumentasi, sebuah
[env contract](../../patches/README.md) runtime yang eksplisit, jalur yang dapat diprediksi, dan status
dalam teks biasa - sebuah agen dapat menemukan cara menggunakannya tanpa menebak-nebak.

## Melakukannya dengan aman

Ini adalah root, jadi perlakukan seperti root:

- berikan agen **pengguna dan kunci khusus**, bukan milik pribadi Anda;
- batasi bind hanya ke jaringan yang Anda percayai - loopback atau VPN alih-alih Internet terbuka
  (lihat [Configuration](CONFIGURATION.md));
- biarkan autentikasi kata sandi tetap mati; sebuah kunci dapat dicabut dan tidak pernah diketik;
- Anda dapat mencabut kunci atau menghentikan daemon kapan saja dari WebUI;
- ingat setiap koneksi adalah sesi root penuh - berikan agen hanya jangkauan yang ia butuhkan.

## Pengaturan minimal

1. Buat sepasang kunci khusus untuk agen.
2. Tambahkan kunci publiknya di WebUI (**Authorized keys**).
3. Bind hanya ke loopback atau VPN Anda, pada port non-default.
4. Arahkan konfigurasi SSH agen ke perangkat dan biarkan ia bekerja.
