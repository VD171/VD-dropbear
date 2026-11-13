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

> **Languages:** English · [العربية](ar/CONFIGURATION.md) · [Čeština](cs/CONFIGURATION.md) · [Deutsch](de/CONFIGURATION.md) · [Español](es/CONFIGURATION.md) · [فارسی](fa/CONFIGURATION.md) · [Français](fr/CONFIGURATION.md) · [हिन्दी](hi/CONFIGURATION.md) · [Bahasa Indonesia](in/CONFIGURATION.md) · [Italiano](it/CONFIGURATION.md) · [日本語](ja/CONFIGURATION.md) · [한국어](ko/CONFIGURATION.md) · [Nederlands](nl/CONFIGURATION.md) · [Polski](pl/CONFIGURATION.md) · [Português](pt/CONFIGURATION.md) · [Русский](ru/CONFIGURATION.md) · [Svenska](sv/CONFIGURATION.md) · [ไทย](th/CONFIGURATION.md) · [Türkçe](tr/CONFIGURATION.md) · [Українська](uk/CONFIGURATION.md) · [Tiếng Việt](vi/CONFIGURATION.md) · [中文](zh/CONFIGURATION.md)

---

# Configuration

Settings live in `/data/adb/vddropbear/config` (seeded from `module/common/config.default` on first
boot). The **WebUI** edits this file for you; you can also edit it by hand. It is sourced as shell, so
use `KEY=value` with no spaces around `=`. Settings are not secret and live on device-encrypted
storage; secrets (host keys, authorized keys, password hashes) live in the secret store, never here.

Apply changes by restarting the daemon (the WebUI's **Save & restart** does this).

## General

| Key | Default | Meaning |
|-----|---------|---------|
| `ENABLED` | `1` | Start the daemon at boot. `0` disables it entirely. |
| `START_IN_BFU` | `0` | `0`: start only after first unlock (AFU); secrets stay on credential-encrypted (CE) storage. `1`: also start before first unlock (BFU); secrets move to device-encrypted (DE) storage, readable before unlock. |
| `PORT` | `2222` | Default listening port (per-bind ports can override it in `LISTEN_ADDRESSES`). |

## Listening / binds (composable)

Any combination is allowed; the selected binds are merged. If you clear everything, VD Dropbear binds
loopback rather than every interface.

| Key | Default | Meaning |
|-----|---------|---------|
| `LISTEN_LOOPBACK` | `1` | Listen on `127.0.0.1` / `::1` only. |
| `LISTEN_ALL` | `0` | Listen on every interface (`0.0.0.0` / `::`) - exposes the device. |
| `LISTEN_IPV4` | `1` | Include IPv4 binds. |
| `LISTEN_IPV6` | `1` | Include IPv6 binds. |
| `LISTEN_ADDRESSES` | `""` | Extra specific binds, comma-separated: `addr` (uses `PORT`) or `addr:port`, IPv4 or IPv6. |

## Identity

| Key | Default | Meaning |
|-----|---------|---------|
| `HIDE_IDENT` | `1` | Send a neutral SSH identity banner so scanners cannot fingerprint the exact server/version. |
| `IDENT_STRING` | `""` | A custom identity string. Empty uses the neutral built-in default. |

## Authentication

Every authenticated login is **root**. Keys are the default; passwords are opt-in.

| Key | Default | Meaning |
|-----|---------|---------|
| `PUBKEY_AUTH` | `1` | Allow public-key login (reads the authorized keys in the secret store). |
| `PASSWORD_AUTH` | `0` | Allow password login. When off, the daemon is started with password auth disabled. |
| `MAX_AUTH_TRIES` | `3` | Maximum authentication attempts per connection. |
| `LOGIN_USER` | `root` | The account to log in as. Must be one the system resolves (usually `root`). |

## Session / environment

| Key | Default | Meaning |
|-----|---------|---------|
| `LOGIN_SHELL` | `""` | Shell for the session. Empty uses the account default. |
| `HOME_DIR` | `""` | `HOME` for the session. Empty uses the module directory. |
| `EXTRA_ENV` | `""` | Extra environment, `K=V;K2=V2`. |
| `IDLE_TIMEOUT` | `0` | Disconnect after N idle seconds. `0` disables. |
| `KEEPALIVE` | `0` | Send a keepalive every N seconds. `0` disables. |
| `RECEIVE_WINDOW` | `""` | Dropbear receive window size. Empty uses the default. |

## Forwarding (off by default)

| Key | Default | Meaning |
|-----|---------|---------|
| `ALLOW_LOCAL_FORWARD` | `0` | Allow local (`-L`) port forwarding. |
| `ALLOW_REMOTE_FORWARD` | `0` | Allow remote (`-R`) port forwarding. |
| `GATEWAY_PORTS` | `0` | Let forwarded remote ports bind to all interfaces. |

## Host key

| Key | Default | Meaning |
|-----|---------|---------|
| `HOSTKEY_TYPE` | `ed25519` | Host-key type: `ed25519`, `rsa` or `ecdsa`. Generated on first start into the secret store. |

## The secret store

Not configured here - resolved from `START_IN_BFU`:

- **AFU (default):** `/data/misc_ce/0/vddropbear/secret` - credential-encrypted, available only after
  you unlock the device.
- **BFU:** `/data/adb/vddropbear/secret` - device-encrypted, readable before first unlock.

It holds the host key, `authorized_keys`, and the `passwd` hash file. See
[BUILDING.md](BUILDING.md) for the password hash format.
