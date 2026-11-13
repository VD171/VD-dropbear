<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/Magisk - no invasive ADB exposure.

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

<p align="center">
  <img src="module/webroot/assets/logo-wordmark.svg" alt="VD Dropbear" width="540">
</p>

# VD Dropbear

<p>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-Apache--2.0-1a7f37" alt="License"></a>
  <img src="https://img.shields.io/badge/KernelSU-%E2%9C%94-635bff" alt="KernelSU">
  <img src="https://img.shields.io/badge/Magisk-%E2%9C%94-00af9c" alt="Magisk">
  <a href="https://github.com/VD171/VD-dropbear/stargazers"><img src="https://img.shields.io/github/stars/VD171/VD-dropbear?color=d29922" alt="Stars"></a>
  <a href="https://github.com/VD171/VD-dropbear/releases"><img src="https://img.shields.io/github/v/release/VD171/VD-dropbear?color=1a7f37" alt="Release"></a>
</p>

A **standalone, fully configurable [Dropbear](https://matt.ucc.asn.au/dropbear/) SSH server**
packaged as a KernelSU / Magisk module. It launches on its own and depends on no other module.

> ⚠️ **Every connection that authenticates receives a ROOT shell.** Treat this like the keys to
> the device: prefer public keys over passwords, and keep the port off the public Internet.

Languages: English · [العربية](README.ar.md) · [Čeština](README.cs.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [فارسی](README.fa.md) · [Français](README.fr.md) · [हिन्दी](README.hi.md) · [Bahasa](README.in.md) · [Italiano](README.it.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Nederlands](README.nl.md) · [Polski](README.pl.md) · [Português](README.pt.md) · [Русский](README.ru.md) · [Svenska](README.sv.md) · [ไทย](README.th.md) · [Türkçe](README.tr.md) · [Українська](README.uk.md) · [Tiếng Việt](README.vi.md) · [中文](README.zh.md)

## Why

Android's built-in way to get a shell on your own phone is ADB (USB debugging), and turning it on is
invasive and self-exposing. `adb_enabled` and `development_settings_enabled` are world-readable
settings - any app, SDK or anti-fraud / RASP library can read them, the connection is logged, and
there is no supported way to hide that ADB is, or ever was, enabled. The exposure follows you even on
a stock, non-rooted phone: to get a shell, you have to announce it.

VD Dropbear is the private alternative. On a rooted device it gives you a real SSH server - root
shell, SFTP and rsync over the network - with no `adb_enabled` tell, no USB-debugging flag, a version
banner that reveals nothing, and credentials you control. Your access stays yours, instead of a
globally-readable "I am being debugged" flag that anything on the device can read.

## Features

- **One daemon, always.** It starts at boot and from the manager's **Action** button, and you can
  **start / stop / restart** it from the WebUI at any time; never more than one instance.
- **Everything is configurable** from the WebUI (or `/data/adb/vddropbear/config`):
  - port, and bind to loopback / all / IPv4 / IPv6 / specific addresses
  - **start before first unlock (BFU) or only after it (AFU)** - a single toggle
  - public-key and/or password authentication, max auth tries
  - login user, shell, `HOME`, extra environment
  - idle timeout, keepalive, receive window
  - local / remote port forwarding and gateway ports (all **off** by default)
  - host-key type (ed25519 / rsa / ecdsa)
- **Hidden version banner.** The SSH protocol requires *a* banner, so it cannot be removed, but VD
  Dropbear replaces it with an uninformative one so scanners cannot fingerprint the exact server or
  version and aim known-version attacks at it.
- **Secrets stored sensibly** (see [Security model](#security-model)).
- **Bring your own credentials.** Add sets of `user + key` and `user + password`; the WebUI enforces
  a minimum password strength and never stores a password in clear text.
- **File transfer and sync built in.** The bundle ships `sftp-server`, `scp` and `rsync`, so SFTP,
  sshfs, GUI clients and backups all work over the same connection.
- **Every device and emulator.** `arm64-v8a`, `armeabi-v7a`, `x86`, `x86_64`.

## AI agents on your device

A standing SSH endpoint turns your phone into something an **autonomous AI agent can operate
directly**. Any agent that can drive a shell or an SSH connection - Claude Code, aider, an
LLM-in-the-loop script, your own automation - gets a real root session on the device, over the
network, with no USB tether and none of ADB's self-exposing debug flags. The agent sees a normal
Linux-like shell and can:

- read and edit files, flip settings, and manage modules, packages and services;
- triage logs, pull artifacts, and run diagnostics or forensics on demand;
- move and sync files both ways over `scp` / `sftp` / `rsync`, for backups, migrations or provisioning;
- drive a whole fleet of rooted devices from one place, each reachable by its own key.

Because the project is built to be **AI-friendly** - a documented configuration file, an explicit
runtime [env contract](patches/README.md), predictable paths and plain-text status - an agent can
discover how to use it without guesswork.

> **This is root, so treat it like root.** Every authenticated connection lands as root (see the
> warning below). When you hand access to an agent, give it a **dedicated user and key**, scope the
> binds to the networks you trust (loopback or a VPN rather than the open internet), keep password
> auth off, and remember you can revoke a key or stop the daemon at any time from the WebUI.

## Install

Flash the module zip in the KernelSU or Magisk manager (or `ksud module install`), open the module's
**WebUI** to set the port and add your keys, then reboot (or press **Action** to start it now).

## Security model

### Where secrets live: BFU vs AFU

`/data/adb` is **device-encrypted (DE)** storage: it is decrypted *before* the user unlocks the phone
(Before First Unlock), so anything there is readable pre-unlock. `/data/misc_ce` is
**credential-encrypted (CE)**: Android keeps it encrypted until the user unlocks (After First Unlock).

- **AFU mode (default, `START_IN_BFU=0`):** the daemon waits for unlock and reads its host key,
  `authorized_keys` and password hashes from CE storage. Maximum protection; SSH works only after the
  device has been unlocked once since boot.
- **BFU mode (`START_IN_BFU=1`):** the daemon starts before unlock so you can SSH in early (for
  example, to unlock the device remotely). Its secrets then live on DE storage and are readable before
  unlock, a deliberate and documented trade-off. Enable it only if you need pre-unlock SSH.

We deliberately do **not** add our own encryption on top of CE: it is already encrypted with the
user's credential, and layering another cipher would need a key that has to live somewhere (on DE it
would be exposed; deriving it from the user credential just re-implements CE). That would buy a false
sense of security, not real protection.

### Passwords

Password login is **off by default**, because every login is root and keys are far safer. When you do
set a password, the WebUI enforces a minimum strength and stores only a hash, never clear text.

## Build

The server binary is built by CI from **upstream [mkj/dropbear](https://github.com/mkj/dropbear)** with
a small, auditable patch set (see [`patches/`](patches/)): a neutral/configurable identity string,
config-driven paths for `authorized_keys` and the password file, and the Android `openpty` fix for
interactive PTYs. A scheduled workflow tracks upstream and rebuilds, so the module stays current. See
[`.github/workflows/`](.github/workflows/) and [`CONTRIBUTING.md`](CONTRIBUTING.md).

## Documentation

<!-- vd-docs -->
Full documentation lives in the [wiki](https://github.com/VD171/VD-dropbear/wiki) and under
[`docs/`](docs/).
<!-- /vd-docs -->

## See also

Sibling projects by the same author:

- **[VDInfos](https://github.com/VD171/VD-Infos)**: a device method debugger that reads each item through every method that can read it and compares them side by side.
- **[VDGoogle](https://github.com/VD171/VD-Google)**: your Google services (RCS, Wallet, Play Integrity attestations), read on your device with no internet.
- **[VDBackup](https://github.com/VD171/VD-Backup)**: full app and data backup and restore as root, driven entirely from a WebUI.
- **[COPG-VD](https://github.com/VD171/COPG-VD)**: a global device fingerprint and build spoofer.

## Contacts

* https://vd171.ru
* https://vd.priv8.ru
* **Telegram:** @VD_Priv8 https://t.me/VD_Priv8
* **Channel:** @Priv8_VD https://t.me/Priv8_VD
* **Discord:** @VD.Priv8 https://discord.com/users/1296831918989639721
* **E-mail:** vd.priv8@pm.me
* **XDA-Developers:** @VD171 https://xdaforums.com/m/vd171.4699873/
* **XDA thread:** _(placeholder - added on first public release)_
* **GitHub:** @VD171 https://github.com/VD171

## License

VD Dropbear's own code is **Apache-2.0** - see [LICENSE](LICENSE). The module also bundles third-party
binaries - [Dropbear](https://matt.ucc.asn.au/dropbear/) (MIT-style), OpenSSH's `sftp-server` and
`scp` (BSD), and `rsync` (GPL-3.0) - each under its own license; see
[THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md), including how we comply with the GPL for rsync. Our
Apache-2.0 code is unaffected (the GPL binary is merely aggregated, not linked).

## Trademarks

VD Dropbear is an independent, unofficial project, not affiliated with or endorsed by any third party.
"Android" is a trademark of Google LLC; "SSH" is a registered trademark of SSH Communications Security.
VD Dropbear runs entirely on your device.

## Tags

`SSH` `Dropbear` `KernelSU` `Magisk` `APatch` `root` `sshd` `remote-access` `openssh-alternative` `Android` `BFU` `VD-dropbear`
