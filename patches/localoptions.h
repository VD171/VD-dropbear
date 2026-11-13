/* ======================================================================
 *  VD Dropbear  ::  standalone, configurable rooted SSH daemon
 *  A private SSH server for KernelSU/APatch/Magisk - no invasive ADB exposure.
 *  Build options - overrides the upstream default_options.h.
 *  Kept minimal and auditable (see patches/README.md). Runtime behaviour
 *  (port, binds, auth toggles, paths, identity) is configuration, not a build option.
 *
 *  Copyright (C) 2026  VD171
 *  SPDX-License-Identifier: Apache-2.0
 *
 *  Licensed under the Apache License, Version 2.0; you may obtain a copy at
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Site           : https://vd171.ru
 *  Site           : https://vd.priv8.ru
 *  Source         : https://github.com/VD171/VD-dropbear
 *  GitHub         : @VD171 https://github.com/VD171
 *  XDA-Developers : @VD171 https://xdaforums.com/m/vd171.4699873/
 *  XDA thread     : https://xdaforums.com/t/VD-dropbear.4808524/
 *  Telegram       : @VD_Priv8 https://t.me/VD_Priv8
 *  Channel        : @Priv8_VD https://t.me/Priv8_VD
 *  Discord        : @VD.Priv8 https://discord.com/users/1296831918989639721
 *  E-mail         : vd.priv8@pm.me
 * ======================================================================
 */

/* Server + keygen only; no SSH client is shipped. */
#define DROPBEAR_CLIENT 0

/* Public-key auth is the secure default. Password auth is provided by the
 * 0003 password-file patch (DROPBEAR_PASSWD_FILE + PBKDF2-HMAC-SHA256), which
 * replaces the system crypt()/shadow dependency that Android lacks. PAM stays
 * off (Android has no PAM). Password auth is OFF at runtime by default anyway
 * (PASSWORD_AUTH in the config), so a user opts in before any password is set. */
#define DROPBEAR_SVR_PUBKEY_AUTH   1
#define DROPBEAR_SVR_PASSWORD_AUTH 1
#define DROPBEAR_SVR_PAM_AUTH      0

/* authorized_keys options (from/command/…) are honoured. */
#define DROPBEAR_SVR_PUBKEY_OPTIONS 1

/* A sane default PATH for the login shell on Android. The first entry is the
 * module's stable bin dir, where vddropbear.sh symlinks the bundled tools
 * (scp, rsync, sftp-server) for the running ABI - so scp/rsync work remotely. */
#define DEFAULT_PATH "/data/adb/vddropbear/bin:/system/bin:/system/xbin:/data/adb/ksu/bin:/sbin"
/* Root logins use DEFAULT_ROOT_PATH, not DEFAULT_PATH - and on this module every
 * login is root, so this is the one that actually applies. Without it the session
 * keeps upstream's /usr/sbin:/usr/bin:... (nonexistent on Android) and scp/rsync
 * are not found. */
#define DEFAULT_ROOT_PATH "/data/adb/vddropbear/bin:/system/bin:/system/xbin:/data/adb/ksu/bin:/sbin"

/* SFTP (and sftp-based scp) use an external sftp-server. bionic has no
 * /usr/libexec, so point it at the same stable symlink. */
#define DROPBEAR_SFTPSERVER 1
#define SFTPSERVER_PATH "/data/adb/vddropbear/bin/sftp-server"

/* openpty() is forced on at build time (build.sh / CI) because the
 * cross-compile configure cannot probe the Android target for it; bionic
 * provides openpty() from API 23. Without it, interactive PTY sessions fail. */
