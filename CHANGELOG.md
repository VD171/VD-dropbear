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
- Public-repository scaffolding: family-format `README`, `MIT` `LICENSE`, this changelog.

### Notes
- The server binary (upstream Dropbear + an auditable patch set), the WebUI, and the CI build workflow
  are in progress.
