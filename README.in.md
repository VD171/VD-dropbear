<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk. No invasive ADB exposure.

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

<p align="center">
  <img src="module/webroot/assets/logo-wordmark.svg" alt="VD Dropbear" width="540">
</p>

# VD Dropbear

<p>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-Apache--2.0-1a7f37" alt="License"></a>
  <img src="https://img.shields.io/badge/KernelSU-%E2%9C%94-635bff" alt="KernelSU">
  <img src="https://img.shields.io/badge/APatch-%E2%9C%94-ff7043" alt="APatch">
  <img src="https://img.shields.io/badge/Magisk-%E2%9C%94-00af9c" alt="Magisk">
  <a href="https://github.com/VD171/VD-dropbear/stargazers"><img src="https://img.shields.io/github/stars/VD171/VD-dropbear?color=d29922" alt="Stars"></a>
  <a href="https://github.com/VD171/VD-dropbear/releases"><img src="https://img.shields.io/github/v/release/VD171/VD-dropbear?color=1a7f37" alt="Release"></a>
</p>

Sebuah **server SSH [Dropbear](https://matt.ucc.asn.au/dropbear/) yang mandiri dan sepenuhnya dapat dikonfigurasi**,
dikemas sebagai modul KernelSU / APatch / Magisk. Ia berjalan sendiri dan tidak bergantung pada modul lain.

> ⚠️ **Sebuah login secara bawaan memberikan shell ROOT penuh.** Perlakukan ini seperti
> kunci perangkat Anda: utamakan kunci publik daripada kata sandi, dan jauhkan port dari Internet publik.

Languages: English · [العربية](README.ar.md) · [Čeština](README.cs.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [فارسی](README.fa.md) · [Français](README.fr.md) · [हिन्दी](README.hi.md) · [Bahasa](README.in.md) · [Italiano](README.it.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Nederlands](README.nl.md) · [Polski](README.pl.md) · [Português](README.pt.md) · [Русский](README.ru.md) · [Svenska](README.sv.md) · [ไทย](README.th.md) · [Türkçe](README.tr.md) · [Українська](README.uk.md) · [Tiếng Việt](README.vi.md) · [中文](README.zh.md)

## Mengapa

Cara bawaan Android untuk mendapatkan shell di ponsel Anda sendiri adalah ADB (USB debugging), dan
mengaktifkannya bersifat invasif serta membuka diri. `adb_enabled` dan `development_settings_enabled`
adalah pengaturan yang dapat dibaca oleh siapa saja: aplikasi, SDK, atau pustaka anti-penipuan / RASP
apa pun bisa membacanya, koneksinya tercatat, dan tidak ada cara resmi untuk menyembunyikan bahwa ADB
sedang, atau pernah, diaktifkan. Keterpaparan itu mengikuti Anda bahkan di ponsel stok yang tidak di-root:
untuk mendapatkan shell, Anda harus mengumumkannya.

VD Dropbear adalah alternatif yang privat. Pada perangkat yang di-root, ia memberi Anda server SSH yang
sesungguhnya: shell root, SFTP, dan rsync melalui jaringan, tanpa jejak `adb_enabled`, tanpa flag
USB-debugging, banner versi yang tidak mengungkap apa pun, dan kredensial yang Anda kendalikan. Akses Anda
tetap milik Anda, bukan sebuah flag "saya sedang di-debug" yang dapat dibaca secara global oleh apa pun di perangkat.

## Fitur

- **Satu daemon, selalu.** Ia mulai saat boot dan dari tombol **Action** di manajer, dan Anda dapat
  **start / stop / restart** dari WebUI kapan saja; tidak pernah lebih dari satu instance.
- **Semuanya dapat dikonfigurasi** dari WebUI (atau `/data/adb/vddropbear/config`):
  - port, dan bind ke loopback / all / IPv4 / IPv6 / alamat tertentu
  - **mulai sebelum first unlock (BFU) atau hanya setelahnya (AFU)**, satu sakelar saja
  - autentikasi dengan kunci publik dan/atau kata sandi, jumlah maksimal percobaan autentikasi
  - shell login, `HOME`, environment tambahan
  - idle timeout, keepalive, receive window
  - port forwarding lokal / remote dan gateway ports (semua **nonaktif** secara bawaan)
  - tipe host-key (ed25519 / rsa / ecdsa)
- **Banner versi tersembunyi.** Protokol SSH mewajibkan adanya *sebuah* banner, jadi ia tidak bisa
  dihapus, tetapi VD Dropbear menggantinya dengan yang tidak informatif sehingga pemindai tidak dapat
  mengenali server atau versi persisnya dan mengarahkan serangan berbasis versi yang diketahui padanya.
- **Rahasia disimpan secara bijak** (lihat [Model keamanan](#security-model)).
- **Bawa kredensial Anda sendiri.** Tambahkan kunci yang diotorisasi dan akun berkata sandi. Sebuah
  login berjalan sebagai akun yang Anda gunakan untuk autentikasi: **root** secara bawaan, atau akun
  Android dengan hak lebih rendah (`shell`, `system`). WebUI
  menerapkan kekuatan kata sandi minimum dan tidak pernah menyimpan kata sandi dalam teks biasa.
- **Transfer dan sinkronisasi file bawaan.** Paket ini menyertakan `sftp-server`, `scp`, dan `rsync`,
  sehingga SFTP, sshfs, klien GUI, dan pencadangan semuanya bekerja melalui koneksi yang sama.
- **Setiap perangkat dan emulator.** `arm64-v8a`, `armeabi-v7a`, `x86`, `x86_64`.

## Agen AI di perangkat Anda

Sebuah endpoint SSH yang selalu siap mengubah ponsel Anda menjadi sesuatu yang **dapat dioperasikan
langsung oleh agen AI otonom**. Agen apa pun yang bisa menjalankan shell atau koneksi SSH (Claude Code,
aider, skrip LLM-in-the-loop, otomasi buatan Anda sendiri) mendapatkan sesi root sungguhan di perangkat,
melalui jaringan, tanpa tether USB dan tanpa satu pun flag debug ADB yang membuka diri. Agen melihat
shell mirip Linux yang normal dan dapat:

- membaca dan menyunting file, mengubah pengaturan, serta mengelola modul, paket, dan layanan;
- menyaring log, mengambil artefak, dan menjalankan diagnostik atau forensik sesuai permintaan;
- memindahkan dan menyinkronkan file dua arah melalui `scp` / `sftp` / `rsync`, untuk pencadangan, migrasi, atau provisioning;
- menggerakkan seluruh armada perangkat yang di-root dari satu tempat, masing-masing dapat dijangkau dengan kuncinya sendiri.

Karena proyek ini dibangun agar **ramah AI** (berkas konfigurasi yang terdokumentasi, sebuah
[kontrak env](patches/README.md) runtime yang eksplisit, jalur yang dapat diprediksi, dan status
teks-biasa), sebuah agen dapat menemukan cara memakainya tanpa menebak-nebak.

> **Root secara bawaan, jadi perlakukan seperti root.** Sebuah login bawaan masuk sebagai root, dan Anda
> juga bisa masuk sebagai akun dengan hak lebih rendah (`shell`, `system`); lihat peringatan di bawah.
> Ketika Anda menyerahkan akses kepada sebuah agen, berikan kredensialnya sendiri (bukan kunci pribadi
> Anda), arahkan ke akun dengan hak lebih rendah seperti `shell` jika Anda ingin membatasi jangkauannya,
> batasi bind ke jaringan yang Anda percayai (loopback atau VPN alih-alih
> internet terbuka), biarkan autentikasi kata sandi tetap nonaktif, dan ingat bahwa Anda bisa mencabut
> kunci atau menghentikan daemon kapan saja dari WebUI.

## Instalasi

Flash zip modul di manajer KernelSU, APatch, atau Magisk (atau dari baris perintah dengan
`ksud module install` / `apd module install`), buka **WebUI** modul untuk mengatur port dan
menambahkan kunci Anda, lalu reboot (atau tekan **Action** untuk menjalankannya sekarang).

## Model keamanan

### Di mana rahasia berada: BFU vs AFU

`/data/adb` adalah penyimpanan **device-encrypted (DE)**: ia didekripsi *sebelum* pengguna membuka kunci
ponsel (Before First Unlock), jadi apa pun di sana dapat dibaca sebelum unlock. `/data/misc_ce` adalah
**credential-encrypted (CE)**: Android menjaganya tetap terenkripsi sampai pengguna membuka kunci (After First Unlock).

- **Mode AFU (bawaan, `START_IN_BFU=0`):** daemon menunggu unlock dan membaca host key-nya,
  `authorized_keys`, serta hash kata sandi dari penyimpanan CE. Perlindungan maksimal; SSH hanya bekerja
  setelah perangkat dibuka kuncinya sekali sejak boot.
- **Mode BFU (`START_IN_BFU=1`):** daemon mulai sebelum unlock sehingga Anda bisa SSH masuk lebih awal
  (misalnya, untuk membuka kunci perangkat dari jarak jauh). Rahasianya lalu berada di penyimpanan DE dan
  dapat dibaca sebelum unlock, sebuah kompromi yang disengaja dan terdokumentasi. Aktifkan hanya jika Anda
  butuh SSH pra-unlock.

Kami sengaja **tidak** menambahkan enkripsi kami sendiri di atas CE: ia sudah terenkripsi dengan
kredensial pengguna, dan melapisi cipher lain akan membutuhkan kunci yang harus disimpan di suatu tempat
(di DE ia akan terbuka; menurunkannya dari kredensial pengguna hanya mengimplementasikan ulang CE). Itu
hanya akan memberi rasa aman yang palsu, bukan perlindungan yang sebenarnya.

### Kata sandi

Login dengan kata sandi **nonaktif secara bawaan**, karena sebuah login secara bawaan adalah root dan kunci jauh lebih
aman. Ketika Anda memang mengatur kata sandi, WebUI menerapkan kekuatan minimum dan hanya menyimpan hash,
tidak pernah teks biasa.

## Build

Biner server dibangun oleh CI dari **upstream [mkj/dropbear](https://github.com/mkj/dropbear)** dengan
seperangkat patch kecil yang dapat diaudit (lihat [`patches/`](patches/)): string identitas yang
netral/dapat dikonfigurasi, jalur yang digerakkan konfigurasi untuk `authorized_keys` dan berkas kata
sandi, serta perbaikan `openpty` Android untuk PTY interaktif. Sebuah workflow terjadwal melacak upstream
dan membangun ulang, sehingga modul tetap mutakhir. Lihat [`.github/workflows/`](.github/workflows/) dan
[`CONTRIBUTING.md`](CONTRIBUTING.md).

## Dokumentasi

<!-- vd-docs -->
Dokumentasi lengkap berada di [wiki](https://github.com/VD171/VD-dropbear/wiki) dan di bawah
[`docs/`](docs/).
<!-- /vd-docs -->

## Lihat juga

Proyek serupa dari penulis yang sama:

- **[VDInfos](https://github.com/VD171/VD-Infos)**: sebuah debugger metode perangkat yang membaca setiap item melalui setiap metode yang dapat membacanya dan membandingkannya berdampingan.
- **[VDGoogle](https://github.com/VD171/VD-Google)**: layanan Google Anda (RCS, Wallet, atestasi Play Integrity), dibaca di perangkat Anda tanpa internet.
- **[VDBackup](https://github.com/VD171/VD-Backup)**: pencadangan dan pemulihan aplikasi serta data secara penuh sebagai root, dikendalikan sepenuhnya dari sebuah WebUI.
- **[COPG-VD](https://github.com/VD171/COPG-VD)**: sebuah spoofer fingerprint perangkat dan build secara global.

## Kontak

* https://vd171.ru
* https://vd.priv8.ru
* **Telegram:** @VD_Priv8 https://t.me/VD_Priv8
* **Channel:** @Priv8_VD https://t.me/Priv8_VD
* **Discord:** @VD.Priv8 https://discord.com/users/1296831918989639721
* **E-mail:** vd.priv8@pm.me
* **XDA-Developers:** @VD171 https://xdaforums.com/m/vd171.4699873/
* **XDA thread:** <https://xdaforums.com/t/VD-Dropbear.4808524/>
* **GitHub:** @VD171 https://github.com/VD171

## Lisensi

Kode milik VD Dropbear sendiri adalah **Apache-2.0**; lihat [LICENSE](LICENSE). Modul ini juga
menyertakan biner pihak ketiga: [Dropbear](https://matt.ucc.asn.au/dropbear/) (gaya MIT), `sftp-server`
dan `scp` dari OpenSSH (BSD), serta `rsync` (GPL-3.0), masing-masing di bawah lisensinya sendiri; lihat
[THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md), termasuk bagaimana kami mematuhi GPL untuk rsync. Kode
Apache-2.0 kami tidak terpengaruh (biner GPL hanya diagregasi, bukan di-link).

## Merek dagang

VD Dropbear adalah proyek independen dan tidak resmi, tidak berafiliasi dengan atau didukung oleh pihak
ketiga mana pun. "Android" adalah merek dagang Google LLC; "SSH" adalah merek dagang terdaftar SSH
Communications Security. VD Dropbear berjalan sepenuhnya di perangkat Anda.

## Tags

`SSH` `Dropbear` `KernelSU` `Magisk` `APatch` `root` `sshd` `remote-access` `openssh-alternative` `Android` `BFU` `VD-dropbear`
