<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk - no invasive ADB exposure.
   Contributing guide.

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

# Contributing to VD Dropbear

Thanks for your interest. This is a small, security-sensitive project (it hands out root), so changes
are reviewed with that in mind.

## Repository layout

```
module/     the installable KernelSU / Magisk module (scripts, WebUI, config, installer)
patches/    the patch set applied on top of upstream Dropbear (the only changes to the SSH server)
src/        where CI unpacks upstream Dropbear to build (not committed)
scripts/    build and maintenance helpers
.github/    CI workflows and issue/PR templates
docs/       documentation (mirrored to the wiki)
```

## Building

The binary is produced by CI from **upstream [mkj/dropbear](https://github.com/mkj/dropbear)** plus the
patches in `patches/`. To build locally you need the Android NDK:

```sh
scripts/build.sh            # fetches the tracked upstream, applies patches, builds arm64 + arm32
```

The patch set is intentionally minimal and auditable: a neutral/configurable identity string,
config-driven paths for `authorized_keys` and the password file, the Android `openpty` fix, and runtime
configuration. Please keep new patches small, documented, and justified in the PR.

## Pull requests

- One logical change per PR; describe the motivation and the security impact.
- Match the existing shell style (POSIX `sh` / Android `mksh`; no bashisms).
- Every file carries a short SPDX header - keep it.
- Update [`CHANGELOG.md`](CHANGELOG.md) under `[Unreleased]` for any real, user-visible change.
- By submitting a PR you agree to license your contribution under the project's [Apache-2.0](LICENSE) license.

## Translations

The README and docs are maintained in many languages (`README.<lang>.md`). English is the source of
truth; translations follow it. If you improve a translation or add a language, keep the structure and
section anchors identical to the English version.

## Reporting bugs and security issues

Use the issue templates for bugs and feature requests. For anything that could compromise a device,
follow [`SECURITY.md`](SECURITY.md) and report privately instead of opening a public issue.
