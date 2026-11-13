<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk - no invasive ADB exposure.
   File structure.

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

> **Languages:** [English](../FILE-STRUCTURE.md) · [العربية](../ar/FILE-STRUCTURE.md) · [Čeština](../cs/FILE-STRUCTURE.md) · [Deutsch](../de/FILE-STRUCTURE.md) · [Español](../es/FILE-STRUCTURE.md) · [فارسی](../fa/FILE-STRUCTURE.md) · [Français](../fr/FILE-STRUCTURE.md) · [हिन्दी](../hi/FILE-STRUCTURE.md) · [Bahasa Indonesia](../in/FILE-STRUCTURE.md) · [Italiano](../it/FILE-STRUCTURE.md) · [日本語](../ja/FILE-STRUCTURE.md) · [한국어](../ko/FILE-STRUCTURE.md) · [Nederlands](../nl/FILE-STRUCTURE.md) · [Polski](../pl/FILE-STRUCTURE.md) · [Português](../pt/FILE-STRUCTURE.md) · [Русский](../ru/FILE-STRUCTURE.md) · Svenska · [ไทย](../th/FILE-STRUCTURE.md) · [Türkçe](../tr/FILE-STRUCTURE.md) · [Українська](../uk/FILE-STRUCTURE.md) · [Tiếng Việt](../vi/FILE-STRUCTURE.md) · [中文](../zh/FILE-STRUCTURE.md)

---

# Filstruktur

## I förvaret

```
module/                     the installable module
  module.prop               id, name, version
  service.sh                boot entry (BFU/AFU start policy)
  action.sh                 manager Action: (re)launch the daemon
  customize.sh              install-time setup
  uninstall.sh              stop the daemon on removal
  common/
    vddropbear.sh           core library (config, secret store, daemon, argv)
    vddb-webui.sh           WebUI backend (the verbs the page drives)
    config.default          shipped default configuration (documented)
  webroot/
    index.html              the WebUI
    assets/                 logos
  bin/<abi>/                CI-built binaries (not committed)
  META-INF/                 Magisk/KSU installer stub
patches/                    auditable patches vs upstream Dropbear + localoptions.h
scripts/
  build.sh                  build the daemon for all ABIs
  build-bundles.sh          build sftp-server, scp, rsync for all ABIs
docs/                       documentation (this folder) + per-language subdirs
.github/workflows/build.yml CI: build, assemble, track upstream, release
UPSTREAM_VERSION            the pinned upstream Dropbear tag
```

## Vid körning (på enheten, inte i förvaret)

```
/data/adb/vddropbear/
  config                    the live configuration you (or the WebUI) edit
  state/daemon.log          the daemon log
  secret/                   secrets, ONLY when START_IN_BFU=1 (device-encrypted)

/data/misc_ce/0/vddropbear/
  secret/                   secrets by default (credential-encrypted, AFU only)
    hostkey_<type>          the host key
    authorized_keys         public keys
    passwd                  password hashes (PBKDF2)
```

Körtidskonfigurationen och hemligheterna behålls avsiktligt när du avinstallerar, så att en
ominstallation behåller dina inställningar och nycklar. För att radera dem, ta bort de katalogerna för
hand.
