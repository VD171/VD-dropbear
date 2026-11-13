<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk. No invasive ADB exposure.
   Contributing guide.

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

> **Languages:** [English](../../CONTRIBUTING.md) · [العربية](../ar/CONTRIBUTING.md) · [Čeština](../cs/CONTRIBUTING.md) · [Deutsch](../de/CONTRIBUTING.md) · [Español](../es/CONTRIBUTING.md) · [فارسی](../fa/CONTRIBUTING.md) · [Français](../fr/CONTRIBUTING.md) · [हिन्दी](../hi/CONTRIBUTING.md) · Bahasa Indonesia · [Italiano](../it/CONTRIBUTING.md) · [日本語](../ja/CONTRIBUTING.md) · [한국어](../ko/CONTRIBUTING.md) · [Nederlands](../nl/CONTRIBUTING.md) · [Polski](../pl/CONTRIBUTING.md) · [Português](../pt/CONTRIBUTING.md) · [Русский](../ru/CONTRIBUTING.md) · [Svenska](../sv/CONTRIBUTING.md) · [ไทย](../th/CONTRIBUTING.md) · [Türkçe](../tr/CONTRIBUTING.md) · [Українська](../uk/CONTRIBUTING.md) · [Tiếng Việt](../vi/CONTRIBUTING.md) · [中文](../zh/CONTRIBUTING.md)

---

# Berkontribusi ke VD Dropbear

Terima kasih atas minat Anda. Ini adalah proyek kecil yang sensitif terhadap keamanan (ia memberikan
root), jadi perubahan ditinjau dengan mempertimbangkan hal itu.

## Tata letak repositori

```
module/     the installable KernelSU / APatch / Magisk module (scripts, WebUI, config, installer)
patches/    the patch set applied on top of upstream Dropbear (the only changes to the SSH server)
src/        where CI unpacks upstream Dropbear to build (not committed)
scripts/    build and maintenance helpers
.github/    CI workflows and issue/PR templates
docs/       documentation (mirrored to the wiki)
```

## Membangun

Binary diproduksi oleh CI dari **upstream [mkj/dropbear](https://github.com/mkj/dropbear)** ditambah
patch di `patches/`. Untuk membangun secara lokal Anda memerlukan Android NDK:

```sh
scripts/build.sh            # fetches the tracked upstream, applies patches, builds arm64 + arm32
```

Kumpulan patch sengaja dibuat minimal dan dapat diaudit: string identitas netral/dapat dikonfigurasi,
jalur berbasis konfigurasi untuk `authorized_keys` dan berkas kata sandi, perbaikan `openpty` Android,
serta konfigurasi runtime. Mohon jaga patch baru tetap kecil, terdokumentasi, dan dibenarkan di PR.

## Pull request

- Satu perubahan logis per PR; jelaskan motivasi dan dampak keamanannya.
- Sesuaikan dengan gaya shell yang ada (POSIX `sh` / `mksh` Android; tanpa bashism).
- Setiap berkas memuat header SPDX singkat. Pertahankan.
- Perbarui [`CHANGELOG.md`](../../CHANGELOG.md) di bawah `[Unreleased]` untuk setiap perubahan nyata yang terlihat pengguna.
- Dengan mengirimkan PR, Anda setuju melisensikan kontribusi Anda di bawah lisensi [Apache-2.0](../../LICENSE) proyek ini.

## Terjemahan

README dan docs dikelola dalam banyak bahasa (`README.<lang>.md`). Bahasa Inggris adalah sumber
kebenaran; terjemahan mengikutinya. Jika Anda memperbaiki sebuah terjemahan atau menambah bahasa, jaga
struktur dan anchor bagian tetap identik dengan versi bahasa Inggris.

## Melaporkan bug dan masalah keamanan

Gunakan templat issue untuk bug dan permintaan fitur. Untuk apa pun yang bisa membahayakan sebuah
perangkat, ikuti [`SECURITY.md`](SECURITY.md) dan laporkan secara pribadi alih-alih membuka issue
publik.
