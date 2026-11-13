#!/system/bin/sh
# ======================================================================
#  VD Dropbear  ::  standalone configurable SSH server (gives ROOT)
#  Install-time setup (sourced by the KSU/Magisk module installer).
#  Copyright (C) 2026  VD171 - SPDX-License-Identifier: MIT
#  https://github.com/VD171/VD-dropbear
# ======================================================================
SKIPUNZIP=0

VER=$(grep_prop version "$MODPATH/module.prop")
ui_print " "
ui_print "  VD Dropbear $VER"
ui_print " "
ui_print "  ********************* WARNING *********************"
ui_print "   Every connection that AUTHENTICATES gets a ROOT shell."
ui_print "   Prefer keys over passwords. Keep the port off the"
ui_print "   public Internet. Configure it from the WebUI."
ui_print "  **************************************************"
ui_print " "

# Executable bits on the shipped binaries and scripts.
set_perm_recursive "$MODPATH/bin" 0 0 0755 0755
set_perm "$MODPATH/service.sh"            0 0 0755
set_perm "$MODPATH/action.sh"             0 0 0755
set_perm "$MODPATH/common/vddropbear.sh"  0 0 0755

# Persistent data dir (lives outside the module so it survives updates/removal).
VDDB_DATA="/data/adb/vddropbear"
mkdir -p "$VDDB_DATA/state" 2>/dev/null
if [ ! -f "$VDDB_DATA/config" ]; then
    cp "$MODPATH/common/config.default" "$VDDB_DATA/config"
    ui_print "- Default config written to $VDDB_DATA/config"
else
    ui_print "- Existing config kept ($VDDB_DATA/config)"
fi
chmod 700 "$VDDB_DATA" 2>/dev/null

ui_print "- Done. Open the WebUI to set port/keys, then reboot (or use Action)."
