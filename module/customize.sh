#!/system/bin/sh
# ======================================================================
#  VD Dropbear  ::  standalone, configurable rooted SSH daemon
#  A private SSH server for KernelSU/APatch/Magisk - no invasive ADB exposure.
#  Install-time setup (sourced by the KSU/APatch/Magisk module installer).
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
