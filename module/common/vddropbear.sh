#!/system/bin/sh
# ======================================================================
#  VD Dropbear  ::  standalone, configurable rooted SSH daemon
#  A private SSH server for KernelSU/APatch/Magisk. No invasive ADB exposure.
#  Core library: config, secret-store resolution, daemon lifecycle, argv builder.
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
# Sourced by service.sh / action.sh / the WebUI backend.
# POSIX sh (Android mksh). No external deps beyond the shipped binaries + toybox.
#
# Responsibilities:
#   - locate the module, the persistent config and the secret store (DE vs CE, per BFU/AFU mode)
#   - load configuration (shipped defaults, then the user's persistent overrides)
#   - manage exactly ONE daemon instance (start / stop / status / restart)
#   - turn the configuration into a dropbear argument vector
#
# Security model (see README):
#   - settings are not secret and live on DE storage (readable at boot).
#   - secrets (host keys, authorized_keys, password hashes) live on CE storage
#     (/data/misc_ce, unlocked only after the user unlocks the device) UNLESS the user
#     opts into START_IN_BFU, in which case they live on DE storage and are readable
#     before first unlock, a deliberate, documented exposure trade-off.

VDDB_NAME="vddropbear"
VDDB_PROC="vddropbear"          # argv[0] the daemon runs under (status/stop match this exactly)

# --- locations -------------------------------------------------------------
# MODDIR is passed by the caller when known; fall back to the standard module path.
[ -n "$MODDIR" ] || MODDIR="/data/adb/modules/$VDDB_NAME"
# Pick the binary dir for this device/emulator ABI. ro.product.cpu.abi already
# reports one of arm64-v8a / armeabi-v7a / x86_64 / x86, which are exactly our dir
# names; fall back to armeabi-v7a if that ABI was not shipped.
VDDB_ABI="$(getprop ro.product.cpu.abi 2>/dev/null)"
[ -d "$MODDIR/bin/$VDDB_ABI" ] || VDDB_ABI="armeabi-v7a"
VDDB_BIN_DIR="$MODDIR/bin/$VDDB_ABI"
# The server binary is shipped under the name "vddropbear" so its process name
# (comm) is exactly that: mksh has no `exec -a`, so this is how pgrep -x matches it.
VDDB_DROPBEAR="$VDDB_BIN_DIR/vddropbear"
VDDB_KEYGEN="$VDDB_BIN_DIR/dropbearkey"
# setsid puts the daemon in its own session so the KSU manager's Action does not
# block on the action's process group. Prefer the shipped toybox, else the system one.
if [ -x "$VDDB_BIN_DIR/toybox" ]; then VDDB_TOYBOX="$VDDB_BIN_DIR/toybox"; else VDDB_TOYBOX="/system/bin/toybox"; fi

# Persistent DE store: settings + runtime state + (only in BFU mode) secrets.
# Lives outside the module dir so it survives module updates/removal.
VDDB_DATA="/data/adb/$VDDB_NAME"
VDDB_CONFIG="$VDDB_DATA/config"
VDDB_STATE="$VDDB_DATA/state"
VDDB_LOG="$VDDB_STATE/daemon.log"
VDDB_DE_SECRET="$VDDB_DATA/secret"          # used only when START_IN_BFU=1

# Credential-encrypted store: the secure default home for secrets (AFU only).
VDDB_CE_SECRET="/data/misc_ce/0/$VDDB_NAME/secret"

# --- small helpers ---------------------------------------------------------
vddb_log() { echo "$(date '+%Y-%m-%d %H:%M:%S') $*" >> "$VDDB_LOG" 2>/dev/null; }

# True once user 0's credential-encrypted storage is available (i.e. after unlock).
vddb_ce_ready() { [ "$(getprop sys.user.0.ce_available 2>/dev/null)" = "true" ]; }

# --- configuration ---------------------------------------------------------
# Defaults are defined here so a missing/partial config file can never leave a
# value unset. The shipped common/config.default documents every key for users;
# this block is the authoritative fallback.
vddb_defaults() {
    ENABLED=1
    START_IN_BFU=0
    PORT=2222
    # Listening is composable: any combination of the toggles below is allowed,
    # and they are merged into one set of binds. LISTEN_IPV4/IPV6 filter the family
    # of the loopback/all binds; specific addresses carry their own family and may
    # carry their own ":port". If nothing is selected we fall back to loopback.
    LISTEN_LOOPBACK=1           # localhost only (127.0.0.1 / ::1)
    LISTEN_ALL=0               # every interface (0.0.0.0 / ::), exposes the device
    LISTEN_IPV4=1
    LISTEN_IPV6=1
    LISTEN_ADDRESSES=""        # extra specific binds: "addr" (uses PORT) or "addr:port", comma-separated
    HIDE_IDENT=1
    IDENT_STRING=""             # empty => neutral built-in (set by the patched binary)
    PASSWORD_AUTH=0             # every login is ROOT: keys are strongly preferred
    PUBKEY_AUTH=1
    MAX_AUTH_TRIES=3
    LOGIN_SHELL=""
    HOME_DIR=""
    EXTRA_ENV=""
    IDLE_TIMEOUT=0
    KEEPALIVE=0
    ALLOW_LOCAL_FORWARD=0
    ALLOW_REMOTE_FORWARD=0
    GATEWAY_PORTS=0
    RECEIVE_WINDOW=""
    HOSTKEY_TYPE="ed25519"
}

vddb_load_config() {
    vddb_defaults
    # shellcheck disable=SC1090
    [ -f "$VDDB_CONFIG" ] && . "$VDDB_CONFIG"
    # Normalise a couple of things the daemon depends on.
    [ "$PORT" -gt 0 ] 2>/dev/null || PORT=2222
}

# Resolve the active secret directory for the CURRENT boot stage + mode.
# BFU mode  -> DE store (readable before unlock, exposed: documented trade-off).
# AFU mode  -> CE store (unlocked only after the user authenticates).
vddb_secret_dir() {
    if [ "$START_IN_BFU" = "1" ]; then
        echo "$VDDB_DE_SECRET"
    else
        echo "$VDDB_CE_SECRET"
    fi
}

# --- host key --------------------------------------------------------------
vddb_hostkey_path() { echo "$(vddb_secret_dir)/hostkey_${HOSTKEY_TYPE}"; }

vddb_ensure_hostkey() {
    _d="$(vddb_secret_dir)"; _k="$(vddb_hostkey_path)"
    mkdir -p "$_d" 2>/dev/null; chmod 700 "$_d" 2>/dev/null
    if [ ! -s "$_k" ]; then
        vddb_log "generating $HOSTKEY_TYPE host key at $_k"
        "$VDDB_KEYGEN" -t "$HOSTKEY_TYPE" -f "$_k" >/dev/null 2>&1
        chmod 600 "$_k" 2>/dev/null
    fi
    [ -s "$_k" ]
}

# --- argument vector -------------------------------------------------------
# Emits the dropbear argv (one token per line) from the loaded config.
# The patched binary honours DROPBEAR_AUTHKEYS / DROPBEAR_PASSWD_FILE / DROPBEAR_IDENT
# via the environment (exported by vddb_export_env), so paths stay config-driven.
vddb_build_args() {
    _sdir="$(vddb_secret_dir)"
    # host key
    printf '%s\n' -r "$(vddb_hostkey_path)"
    # composable listen binds: any mix of all / loopback / specific, filtered by family
    _bound=0
    if [ "$LISTEN_ALL" = "1" ]; then
        [ "$LISTEN_IPV4" = "1" ] && { printf '%s\n' -p "0.0.0.0:$PORT"; _bound=1; }
        [ "$LISTEN_IPV6" = "1" ] && { printf '%s\n' -p "[::]:$PORT";    _bound=1; }
    elif [ "$LISTEN_LOOPBACK" = "1" ]; then
        [ "$LISTEN_IPV4" = "1" ] && { printf '%s\n' -p "127.0.0.1:$PORT"; _bound=1; }
        [ "$LISTEN_IPV6" = "1" ] && { printf '%s\n' -p "[::1]:$PORT";     _bound=1; }
    fi
    for _b in $(echo "$LISTEN_ADDRESSES" | tr ',' ' '); do
        [ -n "$_b" ] || continue
        case "$_b" in
            *]:[0-9]*)  : ;;                  # [ipv6]:port already complete
            \[*\])      _b="$_b:$PORT" ;;      # [ipv6] without a port
            *:*:*)      _b="[$_b]:$PORT" ;;    # bare ipv6 -> bracket it and add the port
            *:[0-9]*)   : ;;                  # ipv4:port already complete
            *)          _b="$_b:$PORT" ;;      # ipv4 without a port
        esac
        printf '%s\n' -p "$_b"; _bound=1
    done
    # Safety net: if the user cleared every option, bind loopback rather than
    # letting dropbear fall back to listening on every interface.
    [ "$_bound" = "1" ] || printf '%s\n' -p "127.0.0.1:$PORT"
    # foreground + log to stderr (captured by service.sh); no pid file in the module dir
    printf '%s\n' -F -P /dev/null
    # auth policy
    [ "$PASSWORD_AUTH" = "1" ] || printf '%s\n' -s          # -s disables password auth
    [ "$MAX_AUTH_TRIES" -gt 0 ] 2>/dev/null && printf '%s\n' -T "$MAX_AUTH_TRIES"
    # forwarding (vectors): off by default
    [ "$ALLOW_LOCAL_FORWARD" = "1" ]  || printf '%s\n' -j
    [ "$ALLOW_REMOTE_FORWARD" = "1" ] || printf '%s\n' -k
    [ "$GATEWAY_PORTS" = "1" ] && printf '%s\n' -a
    # session timers
    [ "$IDLE_TIMEOUT" -gt 0 ] 2>/dev/null && printf '%s\n' -I "$IDLE_TIMEOUT"
    [ "$KEEPALIVE" -gt 0 ] 2>/dev/null && printf '%s\n' -K "$KEEPALIVE"
    [ -n "$RECEIVE_WINDOW" ] && printf '%s\n' -W "$RECEIVE_WINDOW"
}

# Environment the daemon inherits (and passes to login sessions).
vddb_export_env() {
    _sdir="$(vddb_secret_dir)"
    export HOME="${HOME_DIR:-$MODDIR}"
    # the bundled tools (scp/rsync/sftp-server) live under the module's stable bin dir
    export PATH="$VDDB_DATA/bin:${PATH:-/system/bin:/system/xbin}"
    export DROPBEAR_AUTHKEYS="$_sdir/authorized_keys"   # honoured by the VD patch
    export DROPBEAR_PASSWD_FILE="$_sdir/passwd"         # honoured by the VD patch
    [ "$HIDE_IDENT" = "1" ] && export DROPBEAR_IDENT="${IDENT_STRING:-SSH-2.0-}"
    [ -n "$LOGIN_SHELL" ] && export SHELL="$LOGIN_SHELL"
    # extra "K=V;K2=V2" pairs
    if [ -n "$EXTRA_ENV" ]; then
        _IFS="$IFS"; IFS=';'
        for _kv in $EXTRA_ENV; do [ -n "$_kv" ] && export "$_kv"; done
        IFS="$_IFS"
    fi
}

# --- daemon lifecycle (single instance) ------------------------------------
vddb_pid() { pgrep -x "$VDDB_PROC" 2>/dev/null | head -1; }
vddb_is_running() { [ -n "$(vddb_pid)" ]; }

vddb_stop() {
    _p="$(vddb_pid)"
    [ -n "$_p" ] || return 0
    vddb_log "stopping daemon pid $_p"
    kill "$_p" 2>/dev/null
    # give it a moment, then force
    _i=0; while [ "$_i" -lt 10 ] && vddb_is_running; do _i=$((_i+1)); "$VDDB_TOYBOX" sleep 0.2 2>/dev/null; done
    vddb_is_running && kill -9 "$(vddb_pid)" 2>/dev/null
    ! vddb_is_running
}

# Launch the single daemon in its own session (so the KSU manager's action.sh
# does not block waiting for the process group to drain), detached from stdio.
vddb_spawn() {
    mkdir -p "$VDDB_STATE" 2>/dev/null
    vddb_export_env
    # Word-splitting here is intentional and safe: no argument token contains
    # whitespace (binds are addr:port, the host-key path has none).
    set -- $(vddb_build_args | tr '\n' ' ')
    "$VDDB_TOYBOX" setsid "$VDDB_DROPBEAR" "$@" </dev/null >>"$VDDB_LOG" 2>&1 &
    vddb_log "spawned daemon (port $PORT, listen $LISTEN, mode $([ "$START_IN_BFU" = 1 ] && echo BFU || echo AFU))"
}

# Full (re)start: ensure one instance, secrets present, then spawn.
# Expose the bundled file-transfer tools at a stable, ABI-correct path so the SFTP
# subsystem (SFTPSERVER_PATH) and the login PATH (DEFAULT_PATH) find them. This is
# what makes sftp, sftp-based scp and rsync work over the connection.
vddb_link_tools() {
    mkdir -p "$VDDB_DATA/bin" 2>/dev/null
    for _t in sftp-server scp rsync dropbearconvert; do
        [ -e "$VDDB_BIN_DIR/$_t" ] && ln -sf "$VDDB_BIN_DIR/$_t" "$VDDB_DATA/bin/$_t" 2>/dev/null
    done
}

vddb_start() {
    vddb_load_config
    [ "$ENABLED" = "1" ] || { vddb_log "disabled (ENABLED=0), not starting"; return 0; }
    vddb_stop
    vddb_ensure_hostkey || { vddb_log "FATAL: no host key, aborting"; return 1; }
    vddb_link_tools
    vddb_spawn
}

vddb_restart() { vddb_start; }
