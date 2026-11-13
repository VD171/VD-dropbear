<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk - no invasive ADB exposure.
   Configuration reference.

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

> **Languages:** [English](../CONFIGURATION.md) · [العربية](../ar/CONFIGURATION.md) · [Čeština](../cs/CONFIGURATION.md) · [Deutsch](../de/CONFIGURATION.md) · [Español](../es/CONFIGURATION.md) · [فارسی](../fa/CONFIGURATION.md) · [Français](../fr/CONFIGURATION.md) · [हिन्दी](../hi/CONFIGURATION.md) · Bahasa Indonesia · [Italiano](../it/CONFIGURATION.md) · [日本語](../ja/CONFIGURATION.md) · [한국어](../ko/CONFIGURATION.md) · [Nederlands](../nl/CONFIGURATION.md) · [Polski](../pl/CONFIGURATION.md) · [Português](../pt/CONFIGURATION.md) · [Русский](../ru/CONFIGURATION.md) · [Svenska](../sv/CONFIGURATION.md) · [ไทย](../th/CONFIGURATION.md) · [Türkçe](../tr/CONFIGURATION.md) · [Українська](../uk/CONFIGURATION.md) · [Tiếng Việt](../vi/CONFIGURATION.md) · [中文](../zh/CONFIGURATION.md)

---

# Konfigurasi

Pengaturan berada di `/data/adb/vddropbear/config` (disemai dari `module/common/config.default` pada
boot pertama). **WebUI** menyunting berkas ini untuk Anda; Anda juga dapat menyuntingnya secara manual.
Berkas ini di-source sebagai shell, jadi gunakan `KEY=value` tanpa spasi di sekitar `=`. Pengaturan
bukan secret dan berada di penyimpanan device-encrypted; secret (host key, authorized keys, hash kata
sandi) berada di secret store, tidak pernah di sini.

Terapkan perubahan dengan memulai ulang daemon (**Save & restart** di WebUI melakukan ini).

## Umum

| Key | Default | Makna |
|-----|---------|---------|
| `ENABLED` | `1` | Mulai daemon saat boot. `0` menonaktifkannya sepenuhnya. |
| `START_IN_BFU` | `0` | `0`: mulai hanya setelah first unlock (AFU); secret tetap di penyimpanan credential-encrypted (CE). `1`: mulai juga sebelum first unlock (BFU); secret berpindah ke penyimpanan device-encrypted (DE), dapat dibaca sebelum unlock. |
| `PORT` | `2222` | Port pendengaran default (port per-bind dapat menggantikannya di `LISTEN_ADDRESSES`). |

## Pendengaran / bind (dapat digabung)

Kombinasi apa pun diperbolehkan; bind yang dipilih digabungkan. Jika Anda mengosongkan semuanya, VD
Dropbear melakukan bind ke loopback alih-alih setiap antarmuka.

| Key | Default | Makna |
|-----|---------|---------|
| `LISTEN_LOOPBACK` | `1` | Dengarkan hanya di `127.0.0.1` / `::1`. |
| `LISTEN_ALL` | `0` | Dengarkan di setiap antarmuka (`0.0.0.0` / `::`) - memaparkan perangkat. |
| `LISTEN_IPV4` | `1` | Sertakan bind IPv4. |
| `LISTEN_IPV6` | `1` | Sertakan bind IPv6. |
| `LISTEN_ADDRESSES` | `""` | Bind spesifik tambahan, dipisah koma: `addr` (memakai `PORT`) atau `addr:port`, IPv4 atau IPv6. |

## Identitas

| Key | Default | Makna |
|-----|---------|---------|
| `HIDE_IDENT` | `1` | Kirim banner identitas SSH yang netral agar pemindai tidak bisa mengenali server/versi persisnya. |
| `IDENT_STRING` | `""` | String identitas kustom. Kosong berarti memakai default bawaan yang netral. |

## Autentikasi

Setiap login yang terautentikasi adalah **root**. Kunci adalah default; kata sandi bersifat opsional.

| Key | Default | Makna |
|-----|---------|---------|
| `PUBKEY_AUTH` | `1` | Izinkan login kunci publik (membaca authorized keys di secret store). |
| `PASSWORD_AUTH` | `0` | Izinkan login kata sandi. Saat mati, daemon dimulai dengan autentikasi kata sandi dinonaktifkan. |
| `MAX_AUTH_TRIES` | `3` | Jumlah maksimum percobaan autentikasi per koneksi. |
| `LOGIN_USER` | `root` | Akun untuk login. Harus akun yang dapat dikenali sistem (biasanya `root`). |

## Sesi / environment

| Key | Default | Makna |
|-----|---------|---------|
| `LOGIN_SHELL` | `""` | Shell untuk sesi. Kosong berarti memakai default akun. |
| `HOME_DIR` | `""` | `HOME` untuk sesi. Kosong berarti memakai direktori modul. |
| `EXTRA_ENV` | `""` | Environment tambahan, `K=V;K2=V2`. |
| `IDLE_TIMEOUT` | `0` | Putuskan setelah N detik tidak aktif. `0` menonaktifkan. |
| `KEEPALIVE` | `0` | Kirim keepalive setiap N detik. `0` menonaktifkan. |
| `RECEIVE_WINDOW` | `""` | Ukuran receive window Dropbear. Kosong berarti memakai default. |

## Forwarding (mati secara default)

| Key | Default | Makna |
|-----|---------|---------|
| `ALLOW_LOCAL_FORWARD` | `0` | Izinkan port forwarding lokal (`-L`). |
| `ALLOW_REMOTE_FORWARD` | `0` | Izinkan port forwarding jarak jauh (`-R`). |
| `GATEWAY_PORTS` | `0` | Biarkan port jarak jauh yang di-forward melakukan bind ke semua antarmuka. |

## Host key

| Key | Default | Makna |
|-----|---------|---------|
| `HOSTKEY_TYPE` | `ed25519` | Tipe host key: `ed25519`, `rsa` atau `ecdsa`. Dibuat saat start pertama ke dalam secret store. |

## Secret store

Tidak dikonfigurasi di sini - ditentukan dari `START_IN_BFU`:

- **AFU (default):** `/data/misc_ce/0/vddropbear/secret` - credential-encrypted, hanya tersedia setelah
  Anda membuka kunci perangkat.
- **BFU:** `/data/adb/vddropbear/secret` - device-encrypted, dapat dibaca sebelum first unlock.

Store ini menyimpan host key, `authorized_keys`, dan berkas hash `passwd`. Lihat
[BUILDING.md](../BUILDING.md) untuk format hash kata sandi.
