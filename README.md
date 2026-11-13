<!--
  VD Dropbear :: standalone configurable SSH server (gives ROOT) for KernelSU/Magisk
  Copyright (C) 2026  VD171 - SPDX-License-Identifier: MIT
  https://github.com/VD171/VD-dropbear
-->

# VD Dropbear

<p>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-1a7f37" alt="License"></a>
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

Most people get an on-device SSH server by piggy-backing on a larger root-hiding module. That couples
the SSH daemon to that module's lifecycle: if its Zygisk component is disabled or fails, the SSH
daemon never starts, and you lose remote access for a reason that has nothing to do with SSH. VD
Dropbear is a single-purpose module, so the daemon's uptime depends only on the daemon.

## Features

- **One daemon, always.** Start / restart at boot or from the manager's **Action** button; never
  more than one instance.
- **Everything is configurable** from the WebUI (or `/data/adb/vddropbear/config`):
  - port, and bind to loopback / all / IPv4 / IPv6 / specific addresses
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

**MIT** - see [LICENSE](LICENSE). VD Dropbear bundles [Dropbear SSH](https://matt.ucc.asn.au/dropbear/)
by Matt Johnston, distributed under its own MIT-style license.

## Trademarks

VD Dropbear is an independent, unofficial project, not affiliated with or endorsed by any third party.
"Android" is a trademark of Google LLC; "SSH" is a registered trademark of SSH Communications Security.
VD Dropbear runs entirely on your device.

## Tags

`SSH` `Dropbear` `KernelSU` `Magisk` `APatch` `root` `sshd` `remote-access` `openssh-alternative` `Android` `BFU` `VD-dropbear`
