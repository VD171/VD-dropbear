<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk. No invasive ADB exposure.
   Third-party notices and GPL compliance.

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

# Third-party notices

VD Dropbear's own code (the module scripts, WebUI, patches and configuration) is licensed under
**Apache-2.0**: see [`LICENSE`](LICENSE). The module distribution also bundles the third-party binaries
below, each under its own license. Those licenses, and the compliance obligations they carry, are
listed here; the full license texts ship alongside the binaries (in `module/licenses/`).

| Component | Role | License | Source |
|-----------|------|---------|--------|
| **Dropbear** (`dropbear`, `dropbearkey`) | the SSH server | MIT-style | <https://github.com/mkj/dropbear> |
| libtomcrypt, libtommath | crypto, used by Dropbear | public domain / Unlicense | (vendored in Dropbear) |
| **sftp-server**, **scp** | file transfer (OpenSSH) | BSD-style | <https://github.com/openssh/openssh-portable> |
| **rsync** | file sync over SSH | **GPL-3.0-or-later** | <https://github.com/RsyncProject/rsync> |

## GPL compliance (rsync)

`rsync` is licensed under the GNU GPL v3. It is a **separate program** bundled alongside VD Dropbear
(mere aggregation): it is not linked into, and does not relicense, VD Dropbear's Apache-2.0 code. To comply
with the GPL we:

- ship the full **GPL-3.0** text with the binary (`module/licenses/rsync-COPYING`),
- build rsync from a pinned upstream release recorded in CI, and
- provide the **corresponding source**: the exact upstream commit/tag and our build recipe are in the
  build workflow, and a copy of the source is available on request at the contact in
  [`SECURITY.md`](SECURITY.md) / the project's contacts for three years from distribution.

If you prefer a fully permissive distribution, rsync can be left out at build time (the SSH server and
the OpenSSH file-transfer tools are all permissively licensed); the module works without it.
