<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/Magisk - no invasive ADB exposure.
   Patch set overview.

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

# Dropbear patch set

VD Dropbear ships **upstream [Dropbear](https://github.com/mkj/dropbear)** (pinned in
[`../UPSTREAM_VERSION`](../UPSTREAM_VERSION)) with the small, auditable patches below. The goal is to
keep changes to the SSH server minimal, reviewable, and easy to re-apply when upstream moves - the
build (`scripts/build.sh` and the CI workflow) applies every `*.patch` here plus `localoptions.h`.

Everything specific to *your* device (port, keys, password, paths) is runtime configuration, never a
patch - these patches only make the server **able** to be configured on Android.

| Patch | What it does | Why |
|-------|--------------|-----|
| `0001-neutral-configurable-ident.patch` | Default the SSH identity banner to a neutral string, overridable at runtime via `DROPBEAR_IDENT`. | The SSH protocol requires a banner; this one reveals no product or version, so scanners cannot fingerprint and target a known version. |
| `0002-authorized-keys-path.patch` | Read `authorized_keys` from `DROPBEAR_AUTHKEYS` when set (falls back to the account default). | Lets the module place keys on credential-encrypted (CE) or device-encrypted (DE) storage, independent of Android's account model. |
| `0003-password-file.patch` | Verify passwords against a hash file given by `DROPBEAR_PASSWD_FILE`, using a bundled standard hash, instead of the system shadow. | Android's bionic has no usable `crypt()`/shadow; this is a clean, documented replacement (no obfuscation). |
| `0004-android-openpty.patch` | Use `openpty()` for PTY allocation. | Bionic exposes `openpty()`; without this, interactive PTY sessions fail on Android. |

## Build options

`localoptions.h` enables the server, public-key auth and password auth, disables the client and PAM,
and sets Android-appropriate defaults. It overrides `default_options.h` in the upstream tree.

## Runtime contract (honoured by the patches)

The module's `common/vddropbear.sh` sets these before launching the daemon:

- `DROPBEAR_IDENT` - the identity banner (omitted to use the neutral built-in default).
- `DROPBEAR_AUTHKEYS` - absolute path to `authorized_keys`.
- `DROPBEAR_PASSWD_FILE` - absolute path to the password hash file.

Port, binds, auth toggles, forwarding, timeouts and the host key are passed as ordinary command-line
options, so they need no patches at all.
