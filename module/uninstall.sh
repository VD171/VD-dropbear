#!/system/bin/sh
# ======================================================================
#  VD Dropbear  ::  standalone configurable SSH server (gives ROOT)
#  Uninstall hook - stop the running daemon.
#  Copyright (C) 2026  VD171 - SPDX-License-Identifier: Apache-2.0
#  https://github.com/VD171/VD-dropbear
# ======================================================================
#
# The persistent config and the secret stores are intentionally LEFT in place so
# a reinstall keeps your settings and keys. To wipe them completely, remove by hand:
#   rm -rf /data/adb/vddropbear /data/misc_ce/0/vddropbear
pkill -x vddropbear 2>/dev/null
exit 0
