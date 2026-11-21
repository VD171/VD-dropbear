#!/bin/sh
# ======================================================================
#  VD Dropbear  ::  standalone, configurable rooted SSH daemon
#  A private SSH server for KernelSU/APatch/Magisk. No invasive ADB exposure.
#  Deterministically re-pack + sign module/vdlu/baseline.json from the current
#  module/ tree. One command, so the signed baseline always matches the shipped
#  zip. Built because the manual re-pack kept re-introducing the umask mode bug:
#  the license notices were copied AFTER the mode normalization and shipped 0664,
#  drifting the baseline from the CI zip. Here the notices are chmod'd 0644 after
#  the copy and a guard fails the run if any group-writable file survives.
#  Run on the PC with the VDLiveUpdate producer repo + signing key.
#
#  Copyright (C) 2026  VD171
#  SPDX-License-Identifier: Apache-2.0
#
#  Site           : https://vd171.ru
#  Source         : https://github.com/VD171/VD-dropbear
#  GitHub         : @VD171 https://github.com/VD171
#  Telegram       : @VD_Priv8 https://t.me/VD_Priv8
#  Channel        : @Priv8_VD https://t.me/Priv8_VD
# ======================================================================
set -eu

REPO=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$REPO"

# Private producer tools + signing key (override via env for a different setup).
VDLU=${VDLU:-"$REPO/../VDLiveUpdate"}
PACK=${VDLU_PACK:-"$VDLU/producer/vdlu-pack"}
SIGN=${VDLU_SIGN:-"$VDLU/producer/vdlu-sign"}
KEY=${VDLU_KEY:-"$VDLU/keys/vd-2026.pem"}
KEY_ID=${VDLU_KEY_ID:-vd-2026}
MODID=vddropbear

PREV=""
FEED_OUT=""
while [ $# -gt 0 ]; do
  case "$1" in
    --prev) PREV=$2; shift 2 ;;      # previous release manifest, for the delete[] set
    --out)  FEED_OUT=$2; shift 2 ;;  # also copy the feed (manifest.json + blobs/) here
    -h|--help) echo "usage: repack-baseline.sh [--prev <manifest.json>] [--out <feed_dir>]"; exit 0 ;;
    *) echo "repack: unknown arg: $1" >&2; exit 2 ;;
  esac
done

for _t in "$PACK" "$SIGN" "$KEY"; do
  [ -e "$_t" ] || { echo "repack: missing $_t (need the VDLiveUpdate producer repo + key)" >&2; exit 2; }
done

VER=$(sed -n 's/^version=//p'     module/module.prop)
VC=$(sed -n 's/^versionCode=//p'  module/module.prop)
[ -n "$VER" ] && [ -n "$VC" ] || { echo "repack: no version/versionCode in module.prop" >&2; exit 2; }

WORK=$(mktemp -d "${TMPDIR:-/tmp}/vddb-repack.XXXXXX")
trap 'rm -rf "$WORK"' EXIT INT TERM

# 1. Export the current module/ tree (HEAD + working changes) with git's canonical
#    file modes. git only records 0644/0755, so this is the source of truth.
idx="$WORK/index"
GIT_INDEX_FILE="$idx" git read-tree HEAD
GIT_INDEX_FILE="$idx" git add -A
tree=$(GIT_INDEX_FILE="$idx" git write-tree)
git archive --format=tar "$tree" module/ | tar -x -C "$WORK"

# 2. tar honours the caller's umask, so force git's modes back (0664/0775 in the
#    baseline is the recurring bug this script exists to prevent).
find "$WORK/module" -type d -exec chmod 0755 {} +
find "$WORK/module" -type f -exec chmod 0644 {} +
git ls-files -s module/ | awk '$1=="100755"{print $4}' | while IFS= read -r f; do
  chmod 0755 "$WORK/module/${f#module/}" 2>/dev/null || true
done

# 3. Ship the license notices inside the zip, exactly as the CI does - then chmod
#    0644 AFTER the copy (they inherit the caller's umask otherwise: THE bug).
cp LICENSE NOTICE THIRD-PARTY-NOTICES.md "$WORK/module/"
chmod 0644 "$WORK/module/LICENSE" "$WORK/module/NOTICE" "$WORK/module/THIRD-PARTY-NOTICES.md"

# guard: no umask leak may survive into the pack
_leak=$(find "$WORK/module" -type f -perm -0020 | wc -l | tr -d ' ')
[ "$_leak" = 0 ] || { echo "repack: $_leak group-writable file(s) survived normalization" >&2; exit 1; }

# 4. Pack + sign.
out="$WORK/out"
set -- "$WORK/module" "$out" "$MODID" "$VC" --version-name "$VER" --channel stable
[ -n "$PREV" ] && set -- "$@" --prev "$PREV"
python3 "$PACK" "$@"
"$SIGN" "$out/manifest.json" "$KEY" "$KEY_ID"

# 5. Verify the signature on the PC (catches canon/newline/key bugs and stray
#    modes before they ever reach a device).
python3 - "$out/manifest.json" "module/vdlu/keyring/${KEY_ID}.pub" <<'PY'
import sys, base64, hashlib, json
from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PublicKey
raw = open(sys.argv[1]).read().rstrip('\n')          # the signer uses $(cat), which strips the trailing newline
d = json.loads(raw)
pre = raw.split('"sig":"')[0]
tail = raw.split('"sig":"')[1].split('",', 1)[1]
msg = hashlib.sha256((pre + tail).encode()).hexdigest()   # ed25519 signs the 64-char hex STRING
Ed25519PublicKey.from_public_bytes(open(sys.argv[2], 'rb').read()).verify(base64.b64decode(d['sig']), msg.encode())
bad = [f['path'] for f in d['files'] if f['mode'] not in ('0644', '0755')]
assert not bad, f'anomalous file modes: {bad}'
print(f"repack: signature OK, {len(d['files'])} files, canon {msg[:12]}")
PY

# 6. Install the signed manifest as the shipped baseline; optionally stage the feed.
cp "$out/manifest.json" module/vdlu/baseline.json
if [ -n "$FEED_OUT" ]; then
  rm -rf "$FEED_OUT"
  mkdir -p "$(dirname -- "$FEED_OUT")"
  cp -r "$out" "$FEED_OUT"
  echo "repack: baseline.json -> $VER ($VC); feed staged at $FEED_OUT (manifest.json + blobs/)"
else
  echo "repack: baseline.json -> $VER ($VC)"
fi
