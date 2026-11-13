#!/system/bin/sh
# VD Dropbear - uninstall hook. Stop the running daemon.
#
# The persistent config and the secret stores are intentionally LEFT in place so
# a reinstall keeps your settings and keys. To wipe them completely, remove by hand:
#   rm -rf /data/adb/vddropbear /data/misc_ce/0/vddropbear
pkill -x vddropbear 2>/dev/null
exit 0
