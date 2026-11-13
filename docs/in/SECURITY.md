<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk - no invasive ADB exposure.
   Security policy.

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

> **Languages:** [English](../../SECURITY.md) · [العربية](../ar/SECURITY.md) · [Čeština](../cs/SECURITY.md) · [Deutsch](../de/SECURITY.md) · [Español](../es/SECURITY.md) · [فارسی](../fa/SECURITY.md) · [Français](../fr/SECURITY.md) · [हिन्दी](../hi/SECURITY.md) · Bahasa Indonesia · [Italiano](../it/SECURITY.md) · [日本語](../ja/SECURITY.md) · [한국어](../ko/SECURITY.md) · [Nederlands](../nl/SECURITY.md) · [Polski](../pl/SECURITY.md) · [Português](../pt/SECURITY.md) · [Русский](../ru/SECURITY.md) · [Svenska](../sv/SECURITY.md) · [ไทย](../th/SECURITY.md) · [Türkçe](../tr/SECURITY.md) · [Українська](../uk/SECURITY.md) · [Tiếng Việt](../vi/SECURITY.md) · [中文](../zh/SECURITY.md)

---

# Kebijakan Keamanan

## Satu hal yang perlu dipahami

VD Dropbear menjalankan server SSH, dan **setiap koneksi yang berhasil terautentikasi menerima shell
root**. Karena itu, keamanan perangkat Anda setara dengan keamanan konfigurasi dan kredensial server
ini. Mohon:

- **Utamakan kunci publik daripada kata sandi.** Login kata sandi mati secara default.
- Jika Anda harus memakai kata sandi, gunakan yang kuat - WebUI menetapkan batas minimum dan hanya menyimpan hash.
- **Jangan paparkan port ke Internet publik.** Lakukan bind ke loopback atau LAN tepercaya, atau
  jangkau lewat VPN / tunnel.
- Pahami **trade-off BFU**: mengaktifkan start-before-unlock menempatkan host key dan kredensial di
  penyimpanan device-encrypted, yang dapat dibaca sebelum perangkat dibuka kuncinya. Biarkan mati
  kecuali Anda memang perlu SSH sebelum unlock.
- Biarkan forwarding mati kecuali Anda memerlukannya (mati secara default).

## Apa yang dilakukan VD Dropbear untuk membantu

- Banner versi yang netral dan tak informatif agar pemindai jaringan tidak bisa mengenali server dan
  versi persisnya.
- Kredensial di penyimpanan credential-encrypted secara default (didekripsi hanya setelah Anda unlock).
- Tanpa telemetri, tanpa panggilan jaringan sendiri, tanpa analitik. Ia berjalan sepenuhnya di perangkat Anda.

## Versi yang didukung

Perbaikan keamanan masuk ke rilis terbaru. Binary server mengikuti Dropbear upstream; rilis keamanan
upstream dibangun ulang dan dikirim segera setelah CI mengambilnya.

## Melaporkan kerentanan

Mohon laporkan masalah keamanan secara pribadi, bukan di issue publik:

- **E-mail:** vd.priv8@pm.me
- **Telegram:** [@VD_Priv8](https://t.me/VD_Priv8)

Sertakan versi, deskripsi, dan (idealnya) langkah reproduksi. Anda akan menerima tanda terima, dan kami
akan menyelaraskan jadwal perbaikan dan pengungkapan bersama Anda. Untuk kerentanan di Dropbear itu
sendiri, mohon laporkan juga ke upstream di <https://matt.ucc.asn.au/dropbear/>.
