<!--
SPDX-License-Identifier: Apache-2.0
Copyright (C) 2026  VD171
-->
# VDLU release step (VD Dropbear)

VD Dropbear ships the **[VDLiveUpdate](https://github.com/VD171/VDLiveUpdate) (VDLU)** flashless updater in `module/vdlu/` (engine `update.sh` + `vdlu-verify` +
`keyring/`) with the **hardened** profile: a signed manifest is mandatory, and an unsigned, tampered or
downgraded manifest is refused. Producing a release means packing the assembled module tree into a
content addressed store, signing the manifest, and publishing it to the module feed. The flashable
`.zip` stays the install and fallback path; VDLU is additive.

The producer tools live in the VDLiveUpdate repo (https://github.com/VD171/VDLiveUpdate) (`producer/vdlu-pack`, `producer/vdlu-sign`,
`producer/vdlu-keygen`). They run on the PC, never on device.

## Prerequisites

* `python3` and `openssl` 3.x on the build host.
* The ed25519 signing key `vd-2026.pem`. It **stays with the release operator**, never committed, never
  pushed, never placed on a device. Only the public half `vd-2026.pub` is vendored, in
  `module/vdlu/keyring/`.

## Steps

Bump the version first with the canonical bumper. **VD-dropbear uses the `minor` scheme** (`major*10000 +
minor`, e.g. v1.09 = 10009 -> v1.10 = 10010), not the fleet `*100+patch` one, so pass `SCHEME=minor`:

```sh
SCHEME=minor .github/scripts/version.sh bump   # feature bump; rewrites module/module.prop + module/update.json
```

1. Build the module exactly as for a normal release so `module/` is the final flashable tree (same tree
   the `.zip` carries, bins included):

   ```sh
   NDK=/path/to/ndk bash scripts/build.sh
   NDK=/path/to/ndk bash scripts/build-bundles.sh
   ```

2. Pack and sign the tree. **Preferred: `scripts/repack-baseline.sh`** does steps 2-3 in one command -
   it exports the tree with git's canonical modes, copies the license notices and forces them back to
   0644 (a recurring umask bug otherwise shipped them 0664 and drifted the baseline from the zip), packs,
   signs, verifies the signature on the PC, and writes `module/vdlu/baseline.json`:

   ```sh
   scripts/repack-baseline.sh [--prev prev/manifest.json] [--out feed_dir]
   ```

   It reads the version from `module/module.prop`; `--out` also stages the feed (`manifest.json` + `blobs/`).

   The manual equivalent (`<versionCode>` is `versionCode` from `module.prop`; monotonic, hardened blocks
   downgrades; `--prev` is the previous release manifest so paths gone since then land in `delete[]`):

   ```sh
   vdlu-pack  module  out  vddropbear  <versionCode> \
              --version-name <version> --channel stable \
              [--prev prev/manifest.json]
   # Output: out/manifest.json (unsigned, canonical) + out/blobs/<sha256>[.gz]
   vdlu-sign  out/manifest.json  /path/to/keys/vd-2026.pem  vd-2026
   ```

4. Publish `out/manifest.json` and `out/blobs/` to the feed, which is the `source` seeded in
   `config.default`:

   ```
   https://vd171.github.io/VD-Modules/VD-dropbear/
   ```

   Write the blobs first and the `manifest.json` last so the engine never reads a manifest that points
   at a missing blob. Push to the VD-Modules Pages repo in one spaced batch, never a burst (GitHub spam
   flag).

## Retention (prune orphan blobs)

Blobs are content-addressed and immutable: the packer dedups by sha256 and only ever ADDS, so `blobs/`
grows every release. Keep the feed (and the Pages site) small with `vdlu-gc`, which removes blobs that NO
retained manifest references. Archive each signed manifest first so the GC has version history, then prune
(dry-run by default, `--apply` to delete):

```sh
FEED=<the feed dir produced above>              # manifest.json + blobs/
VDLU=../../VDLiveUpdate                          # canonical producer
mkdir -p "$FEED/manifests"
cp "$FEED/manifest.json" "$FEED/manifests/<versionCode>.json"   # archive the SIGNED manifest
"$VDLU/producer/vdlu-gc" "$FEED" --keep-last 3                  # dry-run: lists orphans
"$VDLU/producer/vdlu-gc" "$FEED" --keep-last 3 --apply          # delete them
```

Retention is by REFERENCE, not age: GC keeps the union of sha256 over the current manifest plus the last 3
archived versions, and never removes a blob a retained release still needs (fail-safe: it refuses to run
with no retained manifest). Deleting a blob frees the Pages site but not git history - keep the public feed
on a dedicated, squashable/orphan branch; blobs are reproducible from the tagged commit by `vdlu-pack`, so
resetting the feed branch loses nothing.

## Key rotation

The keyring is a directory of `<key_id>.pub` PEM files. To rotate, generate a new key
(`vdlu-keygen vd-2027 keys`), add `vd-2027.pub` next to `vd-2026.pub` in `module/vdlu/keyring/` (keep the
old one so installs that predate the rotation still verify), and sign new manifests with the new
`key_id`. No engine change.

## Device runtime tools (hardened)

The engine self-locates its tools. The **slim** profile ships no on-device crypto toolchain of its own; it
leans on one tiny vendored verifier, the system toybox, and a static `curl` fetched on demand:

| tool | used for | where it comes from |
|---|---|---|
| `ed25519-mini` | ed25519 signature verify (mandatory under hardened) | **vendored**: `module/vdlu/verify/<abi>/ed25519-mini` (committed, TweetNaCl, provenance in `module/vdlu/verify/PROVENANCE.json`) |
| `gzip` | decompress a blob when `enc=gz` | system `toybox gzip` |
| `sha256sum` / `toybox` | per blob hash (always) | system toybox |
| `curl` | fetch over the `https://` source | fetched once from the signed tools-feed (fetch-bootstrap), cached in `vdlu-tools/<abi>/` |

The verifier is vendored, so hardened verify always runs on device with no build-time toolchain. If it is
ever missing, hardened verify is unavailable and the update aborts cleanly (it never applies anything
unverified), so the failure mode is a no op, never a corrupted module. The static `curl` is not in the
`.zip`: the engine fetches it once from the signed, content-addressed tools-feed (same ed25519 trust root)
and caches it under `vdlu-tools/<abi>/`. Covers `arm64-v8a`, `armeabi-v7a`, `x86_64` and `x86`.

> The slim release also seeds `module/vdlu/baseline.json` (a copy of the signed manifest, so a fresh
> install is born "current" and never phantom-regresses to a full download); the packer excludes
> `baseline.json` from the manifest. The authoritative producer steps live in the canonical
> `VDLiveUpdate` repo (`producer/README.md`); follow them when cutting the feed.

## Packaging

Nothing to wire: the release zip is the whole `module/` tree (`.github/workflows/release.yml`), so
`vdlu/` and `webroot/vdlu.js` + `webroot/vdlu.css` ship automatically.

---

_Generated with Claude._
