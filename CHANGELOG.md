<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk - no invasive ADB exposure.
   Changelog.

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

# Changelog

All notable, real and significant changes to **VD Dropbear** are recorded here.
The format follows [Keep a Changelog](https://keepachangelog.com/); versions are tagged in the
module (`module.prop`) and on GitHub Releases.

## [v1.01] - 2026-11-13

### Fixed
- **SFTP, sftp-based scp and rsync now work over the connection.** The server pointed its SFTP
  subsystem at `/usr/libexec/sftp-server` (which does not exist on Android), and the bundled tools were
  not on the session `PATH`, so `scp`/`sftp` failed. The build now compiles `SFTPSERVER_PATH` and the
  module's own `bin` dir into both `DEFAULT_PATH` **and `DEFAULT_ROOT_PATH`** (every login here is root,
  so the root path is the one that applies), and the launcher symlinks the ABI's
  `sftp-server`/`scp`/`rsync` there at start.

## [v1.00] - 2026-11-13

First public release.

### Added
- Initial module scaffold - a config-driven, single-daemon launcher, independent of any other module.
- Core library (`common/vddropbear.sh`): configuration load with safe built-in defaults; secret-store
  resolution (credential-encrypted `/data/misc_ce` by default, device-encrypted `/data/adb` only in the
  opt-in BFU mode); single-instance daemon lifecycle (start / stop / status / restart); and a Dropbear
  argument vector built entirely from the configuration.
- `service.sh`: boot entry that honours the BFU/AFU start policy and, in AFU mode, waits for the user's
  credential-encrypted storage to unlock without stalling boot.
- `action.sh`: manager "Action" (re)launch that never blocks on stdin and spawns the daemon in its own
  session so the manager returns.
- Installer (`customize.sh` + `META-INF`), `uninstall.sh`, and a fully documented default config.
- Public-repository scaffolding: family-format `README`, Apache-2.0 `LICENSE`, this changelog,
  `SECURITY.md`, `CONTRIBUTING.md`, and an SPDX header on every file.
- **Four-ABI support** - `arm64-v8a`, `armeabi-v7a`, `x86`, `x86_64` - covering every device and
  emulator.
- Build pipeline: `scripts/build.sh` and `scripts/build-bundles.sh` cross-compile **dynamic** binaries
  (linked against bionic) for all ABIs; a CI workflow rebuilds, packages the module zip, names the
  artifact with the version, publishes a GitHub Release on a `v*` tag (with a per-file sha256 list),
  and tracks upstream. The auditable patch set is documented in `patches/`.
- **Composable listen/bind model** - loopback, all interfaces, IPv4/IPv6 family filters and specific
  addresses (each with an optional per-bind port) can be mixed freely; a safety net binds loopback
  rather than every interface if the user clears all options.
- **Bundled file-transfer tools** - `sftp-server`, `scp` and `rsync`, so SFTP, sshfs, GUI clients and
  backups work over the same connection.
- `THIRD-PARTY-NOTICES.md` documenting every bundled component's license and the GPL-3.0 compliance
  for rsync (mere aggregation: the Apache-2.0 module is unaffected).
- **Auditable patch set** against upstream Dropbear:
  - `0001` - neutral, configurable SSH identity (`DROPBEAR_IDENT`), so scanners cannot fingerprint the
    exact server or version.
  - `0002` - read `authorized_keys` from `DROPBEAR_AUTHKEYS`, decoupling keys from Android's account
    model and letting them live on CE or DE storage.
  - `0003` - password auth against a hash file (`DROPBEAR_PASSWD_FILE`) using **PBKDF2-HMAC-SHA256**
    (Dropbear's own libtomcrypt), replacing the system `crypt()`/shadow that bionic lacks - a public,
    documented format with no obfuscation.
- **WebUI** (`module/webroot/index.html` + `common/vddb-webui.sh` backend): live status and daemon
  **start / stop / restart**, the **BFU/AFU start toggle**, every setting, authorized-key management,
  and password accounts whose PBKDF2 hashes are computed in the page with WebCrypto - the clear-text
  password never leaves the browser. Data crosses the `ksu.exec` bridge base64-encoded.
- **AI-agents use case** documented: a standing SSH root endpoint lets an autonomous agent operate the
  device over the network, with none of ADB's tether or self-exposing debug flags.
- Project logos (`webroot/assets/logo-{icon,wordmark}.svg`).
- **Documentation**: a `docs/` set (User guide, Configuration, Architecture, File structure, AI agents,
  Building), a Code of Conduct and GitHub issue/PR templates; the README and docs are translated into
  **21 languages**, and the project wiki is kept in sync from `docs/` automatically.

### Security
- Password login is disabled at runtime by default; keys are the default. When enabled, only a salted,
  high-iteration PBKDF2 hash is stored - never the password.
- Secrets default to credential-encrypted storage; the device-encrypted fallback is opt-in (BFU) and
  documented as an exposure trade-off.

### Notes
- Runs on KernelSU, APatch and Magisk.
- Binaries are **dynamic** (linked against bionic); static-PIE binaries SIGSEGV on-device. Interactive
  PTYs need no patch (`openpty` is auto-detected), and the `-E` flag is dropped (the server is built
  `--disable-syslog`). Validated end-to-end on a real arm64 device: password login succeeds and a wrong
  password is rejected.
