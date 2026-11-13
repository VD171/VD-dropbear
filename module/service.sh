#!/system/bin/sh
# ======================================================================
#  VD Dropbear  ::  standalone configurable SSH server (gives ROOT)
#  Boot entry point (run by the module system at late_start).
#  Copyright (C) 2026  VD171 - SPDX-License-Identifier: MIT
#  https://github.com/VD171/VD-dropbear
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
