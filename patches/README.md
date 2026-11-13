<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk. No invasive ADB exposure.
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
   XDA thread     : https://xdaforums.com/t/VD-Dropbear.4808524/
   Telegram       : @VD_Priv8 https://t.me/VD_Priv8
   Channel        : @Priv8_VD https://t.me/Priv8_VD
   Discord        : @VD.Priv8 https://discord.com/users/1296831918989639721
   E-mail         : vd.priv8@pm.me
  ======================================================================
-->

# Dropbear patch set

VD Dropbear ships **upstream [Dropbear](https://github.com/mkj/dropbear)** (pinned in
[`../UPSTREAM_VERSION`](../UPSTREAM_VERSION)) with the small, auditable patches below. The goal is to
keep changes to the SSH server minimal, reviewable, and easy to re-apply when upstream moves; the
build (`scripts/build.sh` and the CI workflow) applies every `*.patch` here plus `localoptions.h`.

Everything specific to *your* device (port, keys, password, paths) is runtime configuration, never a
patch; these patches only make the server **able** to be configured on Android.

| Patch | What it does | Why |
|-------|--------------|-----|
| `0001-neutral-configurable-ident.patch` | Default the SSH identity banner to a neutral string, overridable at runtime via `DROPBEAR_IDENT`. | The SSH protocol requires a banner; this one reveals no product or version, so scanners cannot fingerprint and target a known version. |
| `0002-authorized-keys-path.patch` | Read `authorized_keys` from `DROPBEAR_AUTHKEYS` when set (falls back to the account default). | Lets the module place keys on credential-encrypted (CE) or device-encrypted (DE) storage, independent of Android's account model. |
| `0003-password-file.patch` | Verify passwords against a hash file given by `DROPBEAR_PASSWD_FILE` using **PBKDF2-HMAC-SHA256** (Dropbear's own libtomcrypt), instead of the system shadow. | Android's bionic has no usable `crypt()`/shadow; this is a clean, documented replacement: a public, standard KDF, **no obfuscation**. |

Interactive PTY sessions need no patch: bionic declares `openpty()` in `<pty.h>`, and Dropbear's
cross-`configure` detects it (`HAVE_OPENPTY`) with the NDK, so PTYs work out of the box.

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

## Password file format (`DROPBEAR_PASSWD_FILE`)

Password auth (`0003`) reads a small, shadow-like file. One account per line:

```
<user>:pbkdf2-sha256$<iterations>$<salt_hex>$<hash_hex>
```

- the hash is `PBKDF2-HMAC-SHA256(password, salt, iterations)`, lower-case hex;
- the salt is random, lower-case hex (16 bytes is plenty);
- `iterations` is a decimal integer (the WebUI uses a high default);
- blank lines and lines starting with `#` are ignored;
- the password itself is **never** stored - only its hash.

This is a public, interoperable format: any standard PBKDF2 implementation produces the same hash.
The **WebUI** creates these lines in the browser with the WebCrypto API
(`crypto.subtle.deriveBits` + `crypto.getRandomValues`), so the clear-text password never leaves the
page, and writes the file into the secret store (CE by default, DE when `START_IN_BFU=1`).

> Note: like public-key auth in Dropbear, password auth only applies to an account the system can
> resolve (typically `root`), which is the username the client presents on the connection.
