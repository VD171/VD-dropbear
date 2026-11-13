<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk - no invasive ADB exposure.
   User guide.

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

> **Languages:** [English](../USER-GUIDE.md) · [العربية](../ar/USER-GUIDE.md) · [Čeština](../cs/USER-GUIDE.md) · [Deutsch](../de/USER-GUIDE.md) · [Español](../es/USER-GUIDE.md) · [فارسی](../fa/USER-GUIDE.md) · [Français](../fr/USER-GUIDE.md) · [हिन्दी](../hi/USER-GUIDE.md) · Bahasa Indonesia · [Italiano](../it/USER-GUIDE.md) · [日本語](../ja/USER-GUIDE.md) · [한국어](../ko/USER-GUIDE.md) · [Nederlands](../nl/USER-GUIDE.md) · [Polski](../pl/USER-GUIDE.md) · [Português](../pt/USER-GUIDE.md) · [Русский](../ru/USER-GUIDE.md) · [Svenska](../sv/USER-GUIDE.md) · [ไทย](../th/USER-GUIDE.md) · [Türkçe](../tr/USER-GUIDE.md) · [Українська](../uk/USER-GUIDE.md) · [Tiếng Việt](../vi/USER-GUIDE.md) · [中文](../zh/USER-GUIDE.md)

---

# Panduan pengguna

VD Dropbear memberi perangkat ter-root Anda sebuah server SSH privat. Panduan ini membawa Anda dari
pemasangan hingga koneksi yang berfungsi, termasuk transfer berkas dan mode before-first-unlock (BFU).

> **Setiap koneksi yang terautentikasi mendapatkan shell root.** Utamakan kunci daripada kata sandi,
> lakukan bind hanya ke jaringan yang Anda percayai, dan jangan pernah memaparkan port ke Internet terbuka tanpa alasan.

## 1. Pasang

Flash zip modul di manajer **KernelSU**, **APatch** atau **Magisk** (atau dari shell dengan
`ksud module install` / `apd module install`), lalu buka **WebUI** modul tersebut.

## 2. Tambahkan kunci (disarankan)

Di WebUI, pada **Authorized keys**, tempel kunci publik Anda (`ssh-ed25519 AAAA... you@host`) dan tekan
**Add key**. Kunci adalah default dan cara masuk yang paling aman.

Untuk membuat kunci di komputer Anda, jika belum punya:

```sh
ssh-keygen -t ed25519 -C "you@host"
cat ~/.ssh/id_ed25519.pub     # paste this into the WebUI
```

## 3. Atau atur kata sandi

Login kata sandi mati secara default (setiap login adalah root, jadi kunci lebih diutamakan). Untuk
mengaktifkannya, nyalakan **Password login** di pengaturan, lalu pada **Password accounts** atur kata
sandi untuk pengguna login. Hash dihitung di browser Anda dengan PBKDF2; kata sandinya sendiri tidak
pernah keluar dari halaman.

## 4. Pilih port dan tempat mendengarkan

Pada **Settings**, atur **Port** dan pilih bind-nya. Secara default VD Dropbear hanya mendengarkan di
**loopback**; untuk menjangkaunya dari LAN atau VPN Anda, aktifkan antarmuka yang Anda inginkan. Hindari
**Listen on all interfaces** kecuali Anda memahami paparannya.

Tekan **Save & restart** untuk menerapkan, lalu **Start** jika belum berjalan.

## 5. Sambungkan

```sh
ssh -p 2222 root@<device-ip>
sftp -P 2222 root@<device-ip>
scp -P 2222 file root@<device-ip>:/sdcard/
rsync -e 'ssh -p 2222' -av ./dir/ root@<device-ip>:/sdcard/dir/
```

`sftp-server`, `scp` dan `rsync` disertakan, sehingga SFTP, `sshfs`, klien GUI, dan pencadangan semua
berfungsi lewat koneksi yang sama.

## 6. Sebelum first unlock (BFU)

Secara default daemon hanya mulai **setelah** Anda membuka kunci perangkat sekali (AFU), karena
secret-nya berada di penyimpanan credential-encrypted. Jika Anda butuh SSH **sebelum** first unlock -
misalnya untuk membuka kunci perangkat dari jarak jauh setelah reboot - nyalakan **Start before first
unlock (BFU)**. Secret kemudian berpindah ke penyimpanan device-encrypted, yang dapat dibaca sebelum
unlock: sebuah trade-off yang disengaja dan terdokumentasi. Lihat [Security model](#) di README.

## 7. Mengendalikan daemon

- **WebUI:** Start / Stop / Restart, dan status langsung (berjalan, PID, port, mode, fingerprint host key).
- **Tombol Action manajer:** (men)jalankan ulang daemon.
- Ia juga mulai otomatis saat boot (kecuali Anda menonaktifkannya).

## Pemecahan masalah

- **Tidak mau mulai.** Periksa `/data/adb/vddropbear/state/daemon.log`. Pastikan **Enabled** menyala
  dan sebuah host key dapat dibuat.
- **Kunci ditolak.** Pastikan baris kunci publik persis seperti yang ditawarkan klien Anda, dan bahwa
  pengguna login adalah yang dapat dikenali sistem (biasanya `root`).
- **Tidak bisa tersambung dari mesin lain.** Anda mungkin masih melakukan bind hanya ke loopback -
  aktifkan antarmuka yang Anda perlukan dan mulai ulang.
- **SFTP/scp gagal tetapi shell berfungsi.** Pastikan `sftp-server` yang disertakan dikirim untuk ABI
  Anda; status WebUI menampilkan ABI yang terdeteksi.
