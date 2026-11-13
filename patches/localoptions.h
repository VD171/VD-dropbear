/* ======================================================================
 *  VD Dropbear  ::  build options (overrides default_options.h)
 *  Copyright (C) 2026  VD171 - SPDX-License-Identifier: Apache-2.0
 *  https://github.com/VD171/VD-dropbear
 * ======================================================================
 * Kept minimal and auditable - see patches/README.md. Runtime behaviour
 * (port, binds, auth toggles, paths, identity) is configuration, not build
 * options; only build-time choices live here.
 */

/* Server + keygen only; no SSH client is shipped. */
#define DROPBEAR_CLIENT 0

/* Public-key auth is the secure default. Password auth is provided by the
 * config-file password patch (DROPBEAR_PASSWD_FILE) - which also removes the
 * system crypt()/shadow dependency that Android lacks - and is enabled together
 * with that patch; until then it stays off so the tree builds cleanly. */
#define DROPBEAR_SVR_PUBKEY_AUTH   1
#define DROPBEAR_SVR_PASSWORD_AUTH 0
#define DROPBEAR_SVR_PAM_AUTH      0

/* authorized_keys options (from/command/…) are honoured. */
#define DROPBEAR_SVR_PUBKEY_OPTIONS 1

/* A sane default PATH for the login shell on Android. */
#define DEFAULT_PATH "/system/bin:/system/xbin:/data/adb/ksu/bin:/sbin"

/* openpty() is forced on at build time (build.sh / CI) because the
 * cross-compile configure cannot probe the Android target for it; bionic
 * provides openpty() from API 23. Without it, interactive PTY sessions fail. */
