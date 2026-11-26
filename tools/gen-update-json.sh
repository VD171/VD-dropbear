#!/usr/bin/env sh
# ======================================================================
#  VD Dropbear  ::  standalone, configurable rooted SSH daemon
#  A private SSH server for KernelSU/APatch/Magisk. No invasive ADB exposure.
#  Generate module/update.json from module.prop (single source of version).
#
#  Copyright (C) 2026  VD171
#  SPDX-License-Identifier: Apache-2.0
#
#  Licensed under the Apache License, Version 2.0; you may obtain a copy at
#  http://www.apache.org/licenses/LICENSE-2.0
#
#  Site           : https://vd171.ru
#  Site           : https://vd.priv8.ru
#  Source         : https://github.com/VD171/VD-dropbear
#  GitHub         : @VD171 https://github.com/VD171
#  XDA-Developers : @VD171 https://xdaforums.com/m/vd171.4699873/
#  XDA thread     : https://xdaforums.com/t/VD-Dropbear.4808524/
#  Telegram       : @VD_Priv8 https://t.me/VD_Priv8
#  Channel        : @Priv8_VD https://t.me/Priv8_VD
#  Discord        : @VD.Priv8 https://discord.com/users/1296831918989639721
#  E-mail         : vd.priv8@pm.me
# ======================================================================

# Generate module/update.json from module.prop (single source of version/versionCode).
# Run it in the release ritual: bump module.prop, run this, then publish the GitHub release.
set -e
cd "$(dirname "$0")/.."
ver=$(grep '^version=' module/module.prop | cut -d= -f2)
vc=$(grep '^versionCode=' module/module.prop | cut -d= -f2)
cat > module/update.json <<EOF
{
  "version": "$ver",
  "versionCode": $vc,
  "zipUrl": "https://github.com/VD171/VD-dropbear/releases/download/$ver/VD-dropbear-$ver.zip",
  "changelog": "https://raw.githubusercontent.com/VD171/VD-dropbear/main/CHANGELOG.md"
}
EOF
echo "module/update.json generated: $ver ($vc)"
