<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk. No invasive ADB exposure.
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
   XDA thread     : https://xdaforums.com/t/VD-Dropbear.4808524/
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

## [v1.09] (2026-11-17)

### Security
- **Hardened the flashless updater's manifest verification.** The signature-profile check now fails closed on
  any unexpected value (a corrupted or malformed `profile` no longer degrades to best-effort verification), and
  every manifest is now bound to its own module id, so a manifest signed for a different module cannot be applied
  to this one. The normal update path was already signature-checked; these close edge cases around a corrupted
  config value and cross-module or MITM feed scenarios.

### Added
- **`PASS_ENV` setting (on by default) - the SSH session inherits the daemon's environment.** With it on
  (dropbear `-e`), a login session sees the platform environment the module service was started with, so tools
  run over SSH that shell out to the Android framework (`am`, `content`, `pm`) work instead of failing silently
  with empty output. Turn it off for a leaner, bare login environment. Settable from the WebUI Settings tab.

### Fixed
- The WebUI no longer interrupts an in-progress update to prompt for a reboot.
- Network-type classification now handles IPv6-only Wi-Fi (464XLAT) correctly, so such a link is no longer
  misread as mobile data.

## [v1.08] (2026-11-17)

### Fixed
- **Number inputs are legible again in the WebUI.** The boot-retry fields in the Updates tab used unstyled
  number inputs that rendered with poor contrast on some devices; they now match the other form controls.

### Changed
- Added an Apache-2.0 SPDX and copyright header to the flashless updater engine and the WebUI widget, in
  line with the rest of the project. No behaviour change.

## [v1.07] (2026-11-16)

### Added
- **Choose which networks the flashless updater may download on.** A new `net_policy` setting (and a selector
  in the WebUI Updates tab) decides when the updater is allowed to fetch: `any` (Wi-Fi or mobile, the default
  and the previous behaviour), `wifi` (only on Wi-Fi), or `mobile` (only on mobile data). It classifies the
  active route with a kernel routing-table lookup, so it costs no packet and wakes no radio, and it gates only
  the download (and the boot retry probe); checking for a new version still works on any network, and a fetch
  on a disallowed network is simply deferred and resumed later.

### Changed
- **`net_policy` replaces `allow_metered`.** The old `allow_metered` flag was never actually consulted by the
  updater; `net_policy` is the real, three-way control that supersedes it.

## [v1.06] (2026-11-16)

### Changed
- **The boot update retry is now patient and battery-friendly.** When the device boots offline, the flashless
  updater waits for the network without holding anything: no lock (a manual check or update stays unblocked)
  and no wakelock, so it costs essentially no battery while it waits. It only spends a fetch once a cheap
  routing-table probe shows the network is actually up (no blind radio wake-ups), and a connect timeout keeps
  it from hanging on a captive portal. Because nothing is pinned, the cap is now generous: **`boot_retry_minutes`
  defaults to 1440** (24 hours of awake-time, so it simply catches you the next time you connect; `0` still
  turns it off). `boot_retry_interval` stays 30s.

## [v1.05] (2026-11-16)

### Fixed
- **Public-key login now works in the default (AFU) mode.** Dropbear checks the ownership and permissions of
  every parent directory of `authorized_keys` and rejects any that is group-writable or not owned by root;
  Android's `/data` tree is system-owned and group-writable (`0771`), so a keys file stored there (where the
  module keeps its secrets, on credential- or device-encrypted storage) was rejected and every key was
  refused with `Permission denied (publickey)`, while password login still worked. The daemon now reaches the
  keys through a root-owned, `0700` shim on `/dev` (tmpfs), so the directory chain Dropbear walks is clean
  while the real key file's own ownership and permissions are still enforced. Reported in #1; thanks for the
  precise diagnosis and the minimal reproducer.

### Added
- **Boot update retry-until-online.** If the device boots offline, the flashless updater keeps retrying the
  update check instead of giving up until the next boot. It only retries a genuine network failure (never a
  bad manifest, signature or downgrade), sleeps between tries so it never busies the CPU, and runs in the
  background so boot is never delayed. Two new options on the Updates tab set the pace: **Boot retry every**
  (seconds between tries, default 30) and **Boot retry up to** (minutes, default 15; `0` turns it off).

## [v1.04] (2026-11-16)

### Added
- **The WebUI is organised into tabs.** Status, Settings, Keys, Passwords and Updates each live on their
  own tab instead of one long scroll, so the page is easier to read on a phone. The root-shell warning
  stays pinned above the tabs.

### Fixed
- **The Updates panel no longer gets stuck on "preparing updater".** A finished update run that left no
  terminal journal entry kept the progress toast spinning; the updater widget now detects a stalled run and
  clears it or offers to resume.
- **A check no longer reports "check failed" when the device is newer than the feed.** Being ahead of the
  published update is a benign state; the updater now shows "newer than the feed" instead of an error (more
  visible now that the open-the-WebUI check is on by default).

### Changed
- **Checking for updates when the WebUI opens is now on by default.** New installs enable
  `auto_on_webui_open`, so the module looks for a flashless update each time you open its WebUI; existing
  installs keep whatever they had. Turn it off in the config if you prefer manual checks.

## [v1.03] (2026-11-15)

### Added
- **Flashless incremental updates (VD Live Update).** Between releases the module can update itself by
  fetching only the files that changed, each verified against a signed manifest, without reflashing the
  full zip. The signature check uses a tiny vendored `ed25519-mini` verifier (TweetNaCl); blobs are
  decompressed with the device's toybox `gzip`; the one network tool, a static `curl`, is fetched on
  demand from a signed tools-feed rather than shipped. The flashable zip stays the install and fallback
  path, so the updater is always optional.

### Changed
- **The README set is paired across all 22 languages.** The Documentation section now links the wiki
  (translations point at their language-prefixed pages) instead of the in-repo markdown, with a top
  navigation bar and a bold language switcher, matching the layout of the other modules.

## [v1.02] (2026-11-13)

### Added
- The bundled components' license texts now ship inside the flashable module (`module/licenses/`), along
  with the module's `LICENSE`, `NOTICE` and `THIRD-PARTY-NOTICES.md`, so the GPL-3.0 `rsync` binary travels
  with its license as the GPL requires.

### Fixed
- **SFTP no longer crashes the session (the bundled `sftp-server` SIGSEGV'd at startup).** On Android,
  bionic's `getpwuid()` returns a `NULL` `pw_gecos`, and OpenSSH's `pwcopy()` guards `pw_passwd` but
  not `pw_gecos`, so `sftp-server` hit `xstrdup(NULL)` the moment a session opened. (`scp` over the
  legacy protocol was unaffected: its path never calls `pwcopy`.) The bundle build now patches
  `pwcopy()` to null-coalesce `pw_gecos`.
- **The public-key login toggle now takes effect.** With `PUBKEY_AUTH` off, no `authorized_keys` file is
  exported, so no key authenticates; before, the toggle did nothing.
- **Config values are validated before they reach the daemon.** `HOSTKEY_TYPE` and `RECEIVE_WINDOW` are
  checked (type against the allowed set, window numeric), so a value with a space can no longer split
  into extra daemon flags.
- The manager Action and the daemon log now print a real listen summary, and `add-key` keeps only the
  first line of a pasted key.

### Changed
- **Login privilege is a choice.** A session runs as the account you authenticate as: **root** by default,
  or a lower-privilege Android account (`shell`, `system`). The README set (22 languages), the docs, the
  WebUI and the release notes now say so, instead of claiming that every login is root.
- **WebUI: simpler, safer credential forms.** The PBKDF2 iteration count is no longer a user field. It
  is fixed at a safe 600000 (OWASP 2023 floor for PBKDF2-HMAC-SHA256), computed in the page as before;
  older hashes keep verifying because the server reads the iteration count stored in each hash. The
  password-account **User** is now a dropdown of the accounts Android resolves (`root`, `shell`, `system`,
  default `root`) instead of free text.

### Removed
- **`LOGIN_USER` setting.** It never reached the daemon (the session account follows the SSH login name
  the client presents, resolved via `getpwnam`), so it was a no-op knob. Removed from the config, the
  WebUI and the docs; the account is set by the password/key entry and the username on connection.

## [v1.01] (2026-11-13)

### Fixed
- **SFTP, sftp-based scp and rsync now work over the connection.** The server pointed its SFTP
  subsystem at `/usr/libexec/sftp-server` (which does not exist on Android), and the bundled tools were
  not on the session `PATH`, so `scp`/`sftp` failed. The build now compiles `SFTPSERVER_PATH` and the
  module's own `bin` dir into both `DEFAULT_PATH` **and `DEFAULT_ROOT_PATH`** (every login here is root,
  so the root path is the one that applies), and the launcher symlinks the ABI's
  `sftp-server`/`scp`/`rsync` there at start.

## [v1.00] (2026-11-13)

First public release.

### Added
- Initial module scaffold: a config-driven, single-daemon launcher, independent of any other module.
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
- **Four-ABI support**: `arm64-v8a`, `armeabi-v7a`, `x86`, `x86_64`, covering every device and
  emulator.
- Build pipeline: `scripts/build.sh` and `scripts/build-bundles.sh` cross-compile **dynamic** binaries
  (linked against bionic) for all ABIs; a CI workflow rebuilds, packages the module zip, names the
  artifact with the version, publishes a GitHub Release on a `v*` tag (with a per-file sha256 list),
  and tracks upstream. The auditable patch set is documented in `patches/`.
- **Composable listen/bind model**: loopback, all interfaces, IPv4/IPv6 family filters and specific
  addresses (each with an optional per-bind port) can be mixed freely; a safety net binds loopback
  rather than every interface if the user clears all options.
- **Bundled file-transfer tools**: `sftp-server`, `scp` and `rsync`, so SFTP, sshfs, GUI clients and
  backups work over the same connection.
- `THIRD-PARTY-NOTICES.md` documenting every bundled component's license and the GPL-3.0 compliance
  for rsync (mere aggregation: the Apache-2.0 module is unaffected).
- **Auditable patch set** against upstream Dropbear:
  - `0001`: neutral, configurable SSH identity (`DROPBEAR_IDENT`), so scanners cannot fingerprint the
    exact server or version.
  - `0002`: read `authorized_keys` from `DROPBEAR_AUTHKEYS`, decoupling keys from Android's account
    model and letting them live on CE or DE storage.
  - `0003`: password auth against a hash file (`DROPBEAR_PASSWD_FILE`) using **PBKDF2-HMAC-SHA256**
    (Dropbear's own libtomcrypt), replacing the system `crypt()`/shadow that bionic lacks, a public,
    documented format with no obfuscation.
- **WebUI** (`module/webroot/index.html` + `common/vddb-webui.sh` backend): live status and daemon
  **start / stop / restart**, the **BFU/AFU start toggle**, every setting, authorized-key management,
  and password accounts whose PBKDF2 hashes are computed in the page with WebCrypto; the clear-text
  password never leaves the browser. Data crosses the `ksu.exec` bridge base64-encoded.
- **AI-agents use case** documented: a standing SSH root endpoint lets an autonomous agent operate the
  device over the network, with none of ADB's tether or self-exposing debug flags.
- Project logos (`webroot/assets/logo-{icon,wordmark}.svg`).
- **Documentation**: a `docs/` set (User guide, Configuration, Architecture, File structure, AI agents,
  Building), a Code of Conduct and GitHub issue/PR templates; the README and docs are translated into
  **21 languages**, and the project wiki is kept in sync from `docs/` automatically.

### Security
- Password login is disabled at runtime by default; keys are the default. When enabled, only a salted,
  high-iteration PBKDF2 hash is stored, never the password.
- Secrets default to credential-encrypted storage; the device-encrypted fallback is opt-in (BFU) and
  documented as an exposure trade-off.

### Notes
- Runs on KernelSU, APatch and Magisk.
- Binaries are **dynamic** (linked against bionic); static-PIE binaries SIGSEGV on-device. Interactive
  PTYs need no patch (`openpty` is auto-detected), and the `-E` flag is dropped (the server is built
  `--disable-syslog`). Validated end-to-end on a real arm64 device: password login succeeds and a wrong
  password is rejected.

<!-- doc-footer -->

---

> _This documentation was generated with Claude (Anthropic) and is maintained by VD171. Corrections and improvements are welcome; see [CONTRIBUTING.md](CONTRIBUTING.md)._
