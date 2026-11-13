#!/system/bin/sh
# ======================================================================
#  VD Dropbear  ::  standalone, configurable rooted SSH daemon
#  A private SSH server for KernelSU/Magisk - no invasive ADB exposure.
#  Boot entry point (run by the module system at late_start).
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
#  XDA thread     : https://xdaforums.com/t/VD-dropbear.4808524/
#  Telegram       : @VD_Priv8 https://t.me/VD_Priv8
#  Channel        : @Priv8_VD https://t.me/Priv8_VD
#  Discord        : @VD.Priv8 https://discord.com/users/1296831918989639721
#  E-mail         : vd.priv8@pm.me
# ======================================================================
# Starts exactly one daemon, honouring the BFU/AFU start policy.

MODDIR=${0%/*}
. "$MODDIR/common/vddropbear.sh"

# First boot: materialise the persistent, editable config from the shipped default.
if [ ! -f "$VDDB_CONFIG" ]; then
    mkdir -p "$VDDB_DATA" 2>/dev/null
    cp "$MODDIR/common/config.default" "$VDDB_CONFIG" 2>/dev/null
fi

vddb_load_config
[ "$ENABLED" = "1" ] || exit 0

if [ "$START_IN_BFU" = "1" ]; then
    # Secrets live on device-encrypted storage; readable now.
    vddb_start
else
    # AFU only: wait (in the background, so we never stall boot) for the user's
    # credential-encrypted storage to unlock, then start with CE secrets.
    (
        i=0
        while [ "$i" -lt 900 ] && ! vddb_ce_ready; do
            "$VDDB_TOYBOX" sleep 1 2>/dev/null || sleep 1
            i=$((i + 1))
        done
        vddb_ce_ready && vddb_start
    ) &
fi
