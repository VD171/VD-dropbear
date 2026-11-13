<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk - no invasive ADB exposure.
   Architecture.

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

> **Languages:** English · [العربية](ar/ARCHITECTURE.md) · [Čeština](cs/ARCHITECTURE.md) · [Deutsch](de/ARCHITECTURE.md) · [Español](es/ARCHITECTURE.md) · [فارسی](fa/ARCHITECTURE.md) · [Français](fr/ARCHITECTURE.md) · [हिन्दी](hi/ARCHITECTURE.md) · [Bahasa Indonesia](in/ARCHITECTURE.md) · [Italiano](it/ARCHITECTURE.md) · [日本語](ja/ARCHITECTURE.md) · [한국어](ko/ARCHITECTURE.md) · [Nederlands](nl/ARCHITECTURE.md) · [Polski](pl/ARCHITECTURE.md) · [Português](pt/ARCHITECTURE.md) · [Русский](ru/ARCHITECTURE.md) · [Svenska](sv/ARCHITECTURE.md) · [ไทย](th/ARCHITECTURE.md) · [Türkçe](tr/ARCHITECTURE.md) · [Українська](uk/ARCHITECTURE.md) · [Tiếng Việt](vi/ARCHITECTURE.md) · [中文](zh/ARCHITECTURE.md)

---

# Architecture

VD Dropbear is a KernelSU / APatch / Magisk module that runs exactly one Dropbear SSH daemon, driven
entirely by configuration. Nothing about the SSH server is hard-coded to one device; everything
specific is runtime config or a secret.

## Pieces

- `module/common/vddropbear.sh` - the core library: load config (with safe built-in defaults),
  resolve the secret store, ensure a host key, build the Dropbear argument vector, and manage a single
  daemon instance (start / stop / status / restart).
- `module/service.sh` - boot entry. Honours the BFU/AFU start policy; in AFU mode it waits for
  credential-encrypted storage to unlock without stalling boot.
- `module/action.sh` - the manager's **Action** button: (re)launch the daemon. It never reads stdin
  and detaches the daemon into its own session, so the manager does not hang.
- `module/common/vddb-webui.sh` + `module/webroot/index.html` - the WebUI backend and page.
- `patches/` - small, auditable patches applied to upstream Dropbear at build time.
- `scripts/build.sh`, `scripts/build-bundles.sh`, `.github/workflows/build.yml` - the build.

## Daemon lifecycle (single instance)

`vddb_start` loads the config, stops any running instance, ensures a host key exists, then spawns one
daemon. The binary is shipped as `vddropbear`, so its process name matches `pgrep -x` exactly (Android
`mksh` has no `exec -a`). It is launched with `setsid` so it detaches from the caller's process group -
that is what keeps the manager's Action from blocking.

## The secret store (CE vs DE, BFU vs AFU)

Settings are not secret and live on device-encrypted storage (`/data/adb/vddropbear`), readable at
boot. Secrets - host key, `authorized_keys`, password hashes - default to **credential-encrypted**
storage (`/data/misc_ce/0/vddropbear`), which only unlocks after the user authenticates. Turning on
`START_IN_BFU` moves the secrets to device-encrypted storage so the daemon can run before first
unlock, at the cost of those secrets being readable earlier. The module computes which store to use at
each boot stage.

## The patch set

The SSH server stays upstream Dropbear; our changes are a few reviewable patches (see
[patches/README.md](../patches/README.md)):

- a neutral, runtime-configurable identity banner;
- `authorized_keys` read from an environment-set path (so keys live in the secret store);
- password auth against a PBKDF2 hash file instead of the system `crypt()`/shadow, which Android
  lacks (see [BUILDING.md](BUILDING.md)).

## The WebUI

A static page in the manager's WebUI (KernelSU / APatch / WebUI-X). It drives
`module/common/vddb-webui.sh` through the `ksu.exec` bridge: status, start/stop/restart, config
read/write, and management of keys and password accounts. All data crosses the bridge base64-encoded,
so the shell never interprets it; password hashes are computed in the browser with WebCrypto, so the
clear-text password never leaves the page.
