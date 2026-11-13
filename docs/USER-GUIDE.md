<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk. No invasive ADB exposure.
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

> **Languages:** English · [العربية](ar/USER-GUIDE.md) · [Čeština](cs/USER-GUIDE.md) · [Deutsch](de/USER-GUIDE.md) · [Español](es/USER-GUIDE.md) · [فارسی](fa/USER-GUIDE.md) · [Français](fr/USER-GUIDE.md) · [हिन्दी](hi/USER-GUIDE.md) · [Bahasa Indonesia](in/USER-GUIDE.md) · [Italiano](it/USER-GUIDE.md) · [日本語](ja/USER-GUIDE.md) · [한국어](ko/USER-GUIDE.md) · [Nederlands](nl/USER-GUIDE.md) · [Polski](pl/USER-GUIDE.md) · [Português](pt/USER-GUIDE.md) · [Русский](ru/USER-GUIDE.md) · [Svenska](sv/USER-GUIDE.md) · [ไทย](th/USER-GUIDE.md) · [Türkçe](tr/USER-GUIDE.md) · [Українська](uk/USER-GUIDE.md) · [Tiếng Việt](vi/USER-GUIDE.md) · [中文](zh/USER-GUIDE.md)

---

# User guide

VD Dropbear gives your rooted device a private SSH server. This guide takes you from install to a
working connection, including file transfer and the before-first-unlock (BFU) mode.

> **Every authenticated connection gets a root shell.** Prefer keys over passwords, bind only to
> networks you trust, and never expose the port to the open Internet without a reason.

## 1. Install

Flash the module zip in the **KernelSU**, **APatch** or **Magisk** manager (or from a shell with
`ksud module install` / `apd module install`), then open the module's **WebUI**.

## 2. Add a key (recommended)

In the WebUI, under **Authorized keys**, paste your public key (`ssh-ed25519 AAAA... you@host`) and
press **Add key**. Keys are the default and the safest way in.

To generate a key on your computer, if you do not have one:

```sh
ssh-keygen -t ed25519 -C "you@host"
cat ~/.ssh/id_ed25519.pub     # paste this into the WebUI
```

## 3. Or set a password

Password login is off by default (every login is root, so keys are preferred). To enable it, turn on
**Password login** in the settings, then under **Password accounts** set a password for the login
user. The hash is computed in your browser with PBKDF2; the password itself never leaves the page.

## 4. Pick a port and where to listen

Under **Settings**, set the **Port** and choose the binds. By default VD Dropbear listens only on
**loopback**; to reach it from your LAN or a VPN, enable the interfaces you want. Avoid
**Listen on all interfaces** unless you understand the exposure.

Press **Save & restart** to apply, then **Start** if it is not already running.

## 5. Connect

```sh
ssh -p 2222 root@<device-ip>
sftp -P 2222 root@<device-ip>
scp -P 2222 file root@<device-ip>:/sdcard/
rsync -e 'ssh -p 2222' -av ./dir/ root@<device-ip>:/sdcard/dir/
```

`sftp-server`, `scp` and `rsync` are bundled, so SFTP, `sshfs`, GUI clients and backups all work over
the same connection.

## 6. Before first unlock (BFU)

By default the daemon starts only **after** you unlock the device once (AFU), because its secrets live
on credential-encrypted storage. If you need SSH **before** first unlock (for example to unlock a
device remotely after a reboot), turn on **Start before first unlock (BFU)**. The secrets then move to
device-encrypted storage, which is readable before unlock: a deliberate, documented trade-off. See
[Security model](#) in the README.

## 7. Controlling the daemon

- **WebUI:** Start / Stop / Restart, and live status (running, PID, port, mode, host-key fingerprint).
- **Manager Action button:** (re)launches the daemon.
- It also starts automatically at boot (unless you disable it).

## Troubleshooting

- **It will not start.** Check `/data/adb/vddropbear/state/daemon.log`. Make sure **Enabled** is on
  and a host key could be generated.
- **Key rejected.** Confirm the public key line is exactly as your client offers it, and that the
  login user is one the system resolves (usually `root`).
- **Can't connect from another machine.** You are probably still bound to loopback only; enable the
  interface you need and restart.
- **SFTP/scp fails but shell works.** Make sure the bundled `sftp-server` shipped for your ABI; the
  WebUI status shows the detected ABI.
