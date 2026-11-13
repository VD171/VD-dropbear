#!/system/bin/sh
# ======================================================================
#  VD Dropbear  ::  standalone configurable SSH server (gives ROOT)
#  Manager "Action" button: (re)launch the single daemon.
#  Copyright (C) 2026  VD171 - SPDX-License-Identifier: MIT
#  https://github.com/VD171/VD-dropbear
# ======================================================================
# Never reads stdin (the KSU manager keeps it open and would hang here), and
# the daemon is spawned in its own session so the manager's action tree drains.

exec 0</dev/null
MODDIR=${0%/*}
. "$MODDIR/common/vddropbear.sh"

echo "VD Dropbear - (re)launching the daemon..."
vddb_restart

vddb_load_config
if vddb_is_running; then
    echo "OK - running"
    echo "  pid    : $(vddb_pid)"
    echo "  port   : $PORT"
    echo "  listen : $LISTEN"
    echo "  mode   : $([ "$START_IN_BFU" = 1 ] && echo 'BFU (secrets on DE storage)' || echo 'AFU (secrets on CE storage)')"
else
    echo "FAILED - the daemon is not running."
    echo "  see the log: $VDDB_LOG"
fi
