<!--
  VD Dropbear - Changelog
  Copyright (C) 2026  VD171 - SPDX-License-Identifier: MIT
-->

# Changelog

All notable, real and significant changes to **VD Dropbear** are recorded here.
The format follows [Keep a Changelog](https://keepachangelog.com/); versions are tagged in the
module (`module.prop`) and on GitHub Releases.

## [Unreleased]

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
- Public-repository scaffolding: family-format `README`, `MIT` `LICENSE`, this changelog,
  `SECURITY.md`, `CONTRIBUTING.md`, and an SPDX header on every file.
- **Four-ABI support** - `arm64-v8a`, `armeabi-v7a`, `x86`, `x86_64` - covering every device and
  emulator.
- Build pipeline: `scripts/build.sh` (fetches the pinned upstream Dropbear, applies the patch set,
  cross-compiles static binaries for all ABIs) and a CI workflow that rebuilds, assembles the module
  zip, and tracks upstream for new releases. The auditable patch set is documented in `patches/`.
- **Composable listen/bind model** - loopback, all interfaces, IPv4/IPv6 family filters and specific
  addresses (each with an optional per-bind port) can be mixed freely; a safety net binds loopback
  rather than every interface if the user clears all options.
- **Bundled file-transfer tools** - `sftp-server`, `scp` and `rsync`, so SFTP, sshfs, GUI clients and
  backups work over the same connection.
- `THIRD-PARTY-NOTICES.md` documenting every bundled component's license and the GPL-3.0 compliance
  for rsync (mere aggregation: the MIT module is unaffected).

### Notes
- The patch set source (`patches/*.patch`, `localoptions.h`), the WebUI and the first built release
  are in progress.
