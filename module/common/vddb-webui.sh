#!/system/bin/sh
# ======================================================================
#  VD Dropbear  ::  standalone, configurable rooted SSH daemon
#  A private SSH server for KernelSU/APatch/Magisk - no invasive ADB exposure.
#  WebUI backend - the verbs index.html drives through ksu.exec().
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
# Contract: every verb prints machine-readable output and exits 0 on success,
# non-zero on failure (with an "err: <reason>" line). Data that may contain any
# byte (config values, key lines, password hashes) crosses the ksu.exec boundary
# base64-encoded, so nothing is ever interpreted by the shell command string.
#
#   status                 -> k=v lines (running/pid/port/mode/ce_ready/abi/...)
#   get-config             -> KEY<TAB>base64(value) lines
#   set-config   < b64     -> write whitelisted KEY=VALUE pairs (values re-quoted)
#   start | stop | restart -> act, then print status
#   list-keys              -> idx<TAB>base64(authorized_keys line)
#   add-key      < b64     -> append one public key
#   del-key <idx>          -> remove the key at that 1-based index
#   list-pw                -> base64(username) lines
#   set-pw  <user> < b64   -> upsert "<user>:<pbkdf2 spec>" (spec made by the WebUI)
#   del-pw  <user>         -> remove that account's line

MODDIR=${0%/*/*}
. "$MODDIR/common/vddropbear.sh"
vddb_load_config

b64()   { printf '%s' "$1" | base64 2>/dev/null | tr -d '\n'; }
unb64() { base64 -d 2>/dev/null; }
die()   { echo "err: $1"; exit 1; }

# Secret store: make sure it exists with tight perms before writing to it.
_secret_ready() {
    _d="$(vddb_secret_dir)"
    mkdir -p "$_d" 2>/dev/null || return 1
    chmod 700 "$_d" 2>/dev/null
    echo "$_d"
}

# --- config whitelist ------------------------------------------------------
# Only these keys may be written. Everything else from the UI is dropped.
VDDB_KEYS="ENABLED START_IN_BFU PORT LISTEN_LOOPBACK LISTEN_ALL LISTEN_IPV4 \
LISTEN_IPV6 LISTEN_ADDRESSES HIDE_IDENT IDENT_STRING PASSWORD_AUTH PUBKEY_AUTH \
MAX_AUTH_TRIES LOGIN_SHELL HOME_DIR EXTRA_ENV IDLE_TIMEOUT KEEPALIVE \
ALLOW_LOCAL_FORWARD ALLOW_REMOTE_FORWARD GATEWAY_PORTS RECEIVE_WINDOW HOSTKEY_TYPE"

_is_key() { for _k in $VDDB_KEYS; do [ "$1" = "$_k" ] && return 0; done; return 1; }

# single-quote a value so the config stays safe to `.` (source): ' -> '\''
_sq() { printf "'%s'" "$(printf '%s' "$1" | sed "s/'/'\\\\''/g")"; }

case "$1" in
# ---------------------------------------------------------------- status ----
  status)
    _run=0; _pid="$(vddb_pid)"; [ -n "$_pid" ] && _run=1
    _mode=AFU; [ "$START_IN_BFU" = "1" ] && _mode=BFU
    _ce=0; vddb_ce_ready && _ce=1
    echo "running=$_run"
    echo "pid=${_pid:-}"
    echo "enabled=$ENABLED"
    echo "port=$PORT"
    echo "mode=$_mode"
    echo "ce_ready=$_ce"
    echo "abi=$VDDB_ABI"
    echo "secret_dir=$(vddb_secret_dir)"
    echo "password_auth=$PASSWORD_AUTH"
    echo "pubkey_auth=$PUBKEY_AUTH"
    echo "version=$(grep '^version=' "$MODDIR/module.prop" 2>/dev/null | cut -d= -f2)"
    # host-key fingerprint (informational; empty if not generated yet)
    _hk="$(vddb_hostkey_path)"
    if [ -s "$_hk" ]; then
      echo "hostkey_fp=$("$VDDB_KEYGEN" -y -f "$_hk" 2>/dev/null | grep -i fingerprint | sed 's/^[^:]*: *//')"
    else
      echo "hostkey_fp="
    fi
    ;;
# ------------------------------------------------------------- get-config ----
  get-config)
    for _k in $VDDB_KEYS; do
      eval "_v=\$$_k"
      printf '%s\t%s\n' "$_k" "$(b64 "$_v")"
    done
    ;;
# ------------------------------------------------------------- set-config ----
  set-config)
    _new="$VDDB_DATA/config.new.$$"
    mkdir -p "$VDDB_DATA" 2>/dev/null
    {
      echo "# VD Dropbear configuration - written by the WebUI. KEY='value'."
      # Read KEY=VALUE pairs (one per line) from the base64 stdin payload.
      unb64 | while IFS= read -r _line; do
        case "$_line" in *=*) : ;; *) continue ;; esac
        _k=${_line%%=*}; _v=${_line#*=}
        _is_key "$_k" || continue
        # strip any stray CR; values never span lines here
        _v=$(printf '%s' "$_v" | tr -d '\r')
        printf '%s=%s\n' "$_k" "$(_sq "$_v")"
      done
    } > "$_new" 2>/dev/null || die "write failed"
    # must contain at least one real key or we refuse to clobber the config
    grep -q '^[A-Z]' "$_new" || { rm -f "$_new"; die "no valid keys"; }
    mv "$_new" "$VDDB_CONFIG" 2>/dev/null || die "install failed"
    chmod 600 "$VDDB_CONFIG" 2>/dev/null
    echo "ok"
    ;;
# ----------------------------------------------------- daemon lifecycle ----
  start)   vddb_start   >/dev/null 2>&1; exec "$0" status ;;
  stop)    vddb_stop    >/dev/null 2>&1; exec "$0" status ;;
  restart) vddb_restart >/dev/null 2>&1; exec "$0" status ;;
# -------------------------------------------------------- authorized keys ----
  list-keys)
    _f="$(vddb_secret_dir)/authorized_keys"
    [ -f "$_f" ] || exit 0
    _i=0
    while IFS= read -r _line; do
      _i=$((_i+1))
      [ -n "$_line" ] || continue
      case "$_line" in \#*) continue ;; esac
      printf '%s\t%s\n' "$_i" "$(b64 "$_line")"
    done < "$_f"
    ;;
  add-key)
    _d="$(_secret_ready)" || die "secret dir"
    _f="$_d/authorized_keys"
    _key="$(unb64)"
    case "$_key" in
      ssh-ed25519\ *|ssh-rsa\ *|ecdsa-sha2-*\ *|sk-ssh-*\ *|sk-ecdsa-*\ *) : ;;
      *) die "not a public key" ;;
    esac
    # no duplicates
    if [ -f "$_f" ] && grep -qF "$_key" "$_f" 2>/dev/null; then echo "ok"; exit 0; fi
    printf '%s\n' "$_key" >> "$_f" || die "append failed"
    chmod 600 "$_f" 2>/dev/null
    echo "ok"
    ;;
  del-key)
    _f="$(vddb_secret_dir)/authorized_keys"
    _idx="$2"
    case "$_idx" in ''|*[!0-9]*) die "bad index" ;; esac
    [ -f "$_f" ] || die "no keys"
    _tmp="$_f.tmp.$$"; _i=0
    while IFS= read -r _line; do
      _i=$((_i+1)); [ "$_i" = "$_idx" ] && continue
      printf '%s\n' "$_line"
    done < "$_f" > "$_tmp"
    mv "$_tmp" "$_f" 2>/dev/null && chmod 600 "$_f" 2>/dev/null
    echo "ok"
    ;;
# ----------------------------------------------------------- passwords ----
  list-pw)
    _f="$(vddb_secret_dir)/passwd"
    [ -f "$_f" ] || exit 0
    while IFS= read -r _line; do
      case "$_line" in ''|\#*) continue ;; esac
      printf '%s\n' "$(b64 "${_line%%:*}")"
    done < "$_f"
    ;;
  set-pw)
    _user="$2"
    case "$_user" in ''|*[!a-zA-Z0-9_]*) die "bad user" ;; esac
    _spec="$(unb64)"
    case "$_spec" in
      pbkdf2-sha256\$[0-9]*\$*\$*) : ;;
      *) die "bad hash spec" ;;
    esac
    _d="$(_secret_ready)" || die "secret dir"
    _f="$_d/passwd"; _tmp="$_f.tmp.$$"
    # drop any existing line for this user, then add the new one
    if [ -f "$_f" ]; then
      while IFS= read -r _line; do
        case "$_line" in "$_user":*) continue ;; esac
        printf '%s\n' "$_line"
      done < "$_f" > "$_tmp"
    else
      : > "$_tmp"
    fi
    printf '%s:%s\n' "$_user" "$_spec" >> "$_tmp"
    mv "$_tmp" "$_f" 2>/dev/null && chmod 600 "$_f" 2>/dev/null
    echo "ok"
    ;;
  del-pw)
    _user="$2"
    case "$_user" in ''|*[!a-zA-Z0-9_]*) die "bad user" ;; esac
    _f="$(vddb_secret_dir)/passwd"; [ -f "$_f" ] || { echo "ok"; exit 0; }
    _tmp="$_f.tmp.$$"
    while IFS= read -r _line; do
      case "$_line" in "$_user":*) continue ;; esac
      printf '%s\n' "$_line"
    done < "$_f" > "$_tmp"
    mv "$_tmp" "$_f" 2>/dev/null && chmod 600 "$_f" 2>/dev/null
    echo "ok"
    ;;
  *)
    die "unknown verb: ${1:-}"
    ;;
esac
