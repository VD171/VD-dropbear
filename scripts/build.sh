#!/usr/bin/env bash
# ======================================================================
#  VD Dropbear  ::  standalone, configurable rooted SSH daemon
#  A private SSH server for KernelSU/Magisk - no invasive ADB exposure.
#  Build the server binary for every Android ABI.
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
#  XDA thread     : https://xdaforums.com/t/VD-dropbear.4808524/
#  Telegram       : @VD_Priv8 https://t.me/VD_Priv8
#  Channel        : @Priv8_VD https://t.me/Priv8_VD
#  Discord        : @VD.Priv8 https://discord.com/users/1296831918989639721
#  E-mail         : vd.priv8@pm.me
# ======================================================================
#
# Fetches upstream Dropbear at the tag in ../UPSTREAM_VERSION, applies the
# auditable patch set in ../patches/, and cross-compiles a STATIC `dropbear`
# and `dropbearkey` for all four Android ABIs:
#     arm64-v8a  armeabi-v7a  x86  x86_64
# Outputs land in ../module/bin/<abi>/ as `vddropbear` and `dropbearkey`.
#
# Requirements: Android NDK (r27+), git, make, patch. Set NDK to its path.
#   NDK=/path/to/android-ndk ./scripts/build.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
: "${NDK:?set NDK to your Android NDK path}"
: "${API:=24}"                          # minimum supported Android API (openpty needs >=23)
VERSION="$(tr -d ' \n' < "$ROOT/UPSTREAM_VERSION")"
ABIS="${ABIS:-arm64-v8a armeabi-v7a x86 x86_64}"
PROGRAMS="dropbear dropbearkey"

WORK="$ROOT/build"
SRC="$WORK/dropbear-$VERSION"
TOOLCHAIN="$NDK/toolchains/llvm/prebuilt/$(uname | tr '[:upper:]' '[:lower:]')-x86_64/bin"

triple() {
  case "$1" in
    arm64-v8a)   echo aarch64-linux-android ;;
    armeabi-v7a) echo armv7a-linux-androideabi ;;
    x86)         echo i686-linux-android ;;
    x86_64)      echo x86_64-linux-android ;;
    *) echo "unknown ABI: $1" >&2; exit 1 ;;
  esac
}

echo "==> upstream Dropbear $VERSION"
mkdir -p "$WORK"
if [ ! -d "$SRC" ]; then
  git clone --depth 1 --branch "$VERSION" https://github.com/mkj/dropbear "$SRC"
fi

echo "==> applying patch set"
git -C "$SRC" stash -u >/dev/null 2>&1 || true   # start from a clean tree each run
git -C "$SRC" checkout -- . 2>/dev/null || true
cp "$ROOT/patches/localoptions.h" "$SRC/localoptions.h"
for p in "$ROOT"/patches/*.patch; do
  [ -e "$p" ] || continue
  echo "    - $(basename "$p")"
  patch -p1 -d "$SRC" < "$p"
done

for ABI in $ABIS; do
  TGT="$(triple "$ABI")"
  echo "==> building $ABI ($TGT, API $API, static)"
  export CC="$TOOLCHAIN/${TGT}${API}-clang"
  export AR="$TOOLCHAIN/llvm-ar" RANLIB="$TOOLCHAIN/llvm-ranlib" STRIP="$TOOLCHAIN/llvm-strip"
  ( cd "$SRC"
    make clean >/dev/null 2>&1 || true
    ./configure --host="$TGT" --disable-zlib --disable-syslog CC="$CC" >/dev/null
    make -j"$(nproc)" PROGRAMS="$PROGRAMS" STATIC=1 >/dev/null
    "$STRIP" dropbear dropbearkey
  )
  OUT="$ROOT/module/bin/$ABI"; mkdir -p "$OUT"
  cp "$SRC/dropbear"    "$OUT/vddropbear"
  cp "$SRC/dropbearkey" "$OUT/dropbearkey"
  chmod 0755 "$OUT/vddropbear" "$OUT/dropbearkey"
done

echo "==> done. Binaries in module/bin/<abi>/"
