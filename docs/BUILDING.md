<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk - no invasive ADB exposure.
   Building the binaries, and the Android crypto/crypt() story.

   Copyright (C) 2026  VD171
   SPDX-License-Identifier: Apache-2.0

   Licensed under the Apache License, Version 2.0; you may obtain a copy at
   http://www.apache.org/licenses/LICENSE-2.0

   Site           : https://vd171.ru
   Site           : https://vd.priv8.ru
   Source         : https://github.com/VD171/VD-dropbear
   GitHub         : @VD171 https://github.com/VD171
   XDA-Developers : @VD171 https://xdaforums.com/m/vd171.4699873/
   XDA thread     : https://xdaforums.com/t/VD-dropbear.4808524/
   Telegram       : @VD_Priv8 https://t.me/VD_Priv8
   Channel        : @Priv8_VD https://t.me/Priv8_VD
   Discord        : @VD.Priv8 https://discord.com/users/1296831918989639721
   E-mail         : vd.priv8@pm.me
  ======================================================================
-->

# Building VD Dropbear

VD Dropbear ships **upstream [Dropbear](https://github.com/mkj/dropbear)** - the tag pinned in
[`UPSTREAM_VERSION`](../UPSTREAM_VERSION) - plus the small, auditable patch set in
[`patches/`](../patches/). CI builds it; you can reproduce it locally.

## Quick start

```sh
# one-time: an Android NDK (r27 or newer)
export NDK=/path/to/android-ndk

# build every ABI (arm64-v8a armeabi-v7a x86 x86_64)
./scripts/build.sh

# or just one, to iterate fast
ABIS="arm64-v8a" ./scripts/build.sh
```

`scripts/build.sh` clones the pinned upstream tag, applies `patches/*.patch` and `localoptions.h`,
then cross-compiles **static** `vddropbear` and `dropbearkey` into `module/bin/<abi>/`. The output is
a **static-PIE** ELF (`file` reports `static-pie executable, ARM aarch64 … for Android 24`), which is
the form Android's bionic accepts for a standalone root binary.

The binaries are **not committed** - they are built by CI on every tag and attached to the release.
See [`.gitignore`](../.gitignore).

---

## The crypt()/libcrypto story (why password auth needed real work)

Dropbear's password authentication is written for a normal Unix host with `crypt()` and
`/etc/shadow`. Android has **neither**, and that collides with the build in three separate places.
This section documents every one of them, because it is exactly the kind of thing that is painful to
rediscover. All of it is handled by patch
[`0003-password-file.patch`](../patches/0003-password-file.patch); nothing below is left to chance at
runtime.

### 1. bionic has no usable `crypt()`

Android's C library (bionic) does not provide `crypt()`, `crypt_r()`, or a shadow database. The NDK
exposes no `<crypt.h>`. So the stock Dropbear password path - which calls `crypt(password, salt)` and
compares against `/etc/shadow` - simply cannot be built or run on Android. There is also no
`libcrypt` to link against, and pulling in OpenSSL's `libcrypto` just for a password hash would be a
large, awkward dependency for a static binary.

**Our answer:** don't use `crypt()` at all. Password auth verifies the presented password with
**PBKDF2-HMAC-SHA256** against a hash file (`DROPBEAR_PASSWD_FILE`), a public, standard, salted,
iterated KDF. The file format is documented in [`patches/README.md`](../patches/README.md).

### 2. The compile-time guard in `sysoptions.h`

Even before any code runs, Dropbear refuses to build:

```c
#if DROPBEAR_SVR_PASSWORD_AUTH && !HAVE_CRYPT
    #error "DROPBEAR_SVR_PASSWORD_AUTH requires `crypt()'."
#endif
```

With `HAVE_CRYPT` unset (always, on bionic) and password auth enabled, this is a hard `#error`.
Because our verifier never calls `crypt()`, patch `0003` **removes this guard**. (It leaves the
"at least one auth method must be enabled" check intact.)

### 3. The libtomcrypt trap: PBKDF2 is compiled *out*

Dropbear bundles a trimmed **libtomcrypt**, which *does* contain PBKDF2 (`pkcs_5_alg2`,
`src/misc/pkcs5/pkcs_5_2.c`). The obvious fix is to call it. It does not work, for two compounding
reasons:

- **The prototype is hidden.** `pkcs_5_alg2` is declared only inside `#ifdef LTC_PKCS_5` in
  `tomcrypt_pkcs.h`. Dropbear's *own* source files are not compiled with `LTC_PKCS_5` defined, so the
  declaration is invisible and the compiler errors with *implicit function declaration*.
- **The symbol does not exist.** Worse, the *body* of `pkcs_5_alg2` is itself behind `#ifdef
  LTC_PKCS_5`. Dropbear's libtomcrypt build does not define it, so `pkcs_5_2.o` compiles to an
  **empty object** - it is in `libtomcrypt.a`, but it contains no `pkcs_5_alg2` symbol. The link
  fails with `undefined symbol: pkcs_5_alg2`.

You can see this for yourself:

```sh
# the object exists but is empty (no T pkcs_5_alg2):
llvm-nm build/dropbear-*/libtomcrypt/src/misc/pkcs5/pkcs_5_2.o
# -> only a data marker, no pkcs_5_alg2

# HMAC, by contrast, is fully compiled (Dropbear uses it for SSH MACs):
llvm-nm build/dropbear-*/libtomcrypt/src/mac/hmac/hmac_memory.o
# -> defines hmac_memory
```

**Our answer:** build PBKDF2 ourselves on the primitives Dropbear *does* compile. `hmac_memory` and
the registered `sha256` hash are both present and linkable, so patch `0003` implements
PBKDF2-HMAC-SHA256 directly (RFC 2898; a single 32-byte output block, since `dkLen == hLen` for
SHA-256). We declare `hmac_memory` ourselves (same hidden-prototype issue as above) and the object is
pulled from `libtomcrypt.a` at link time. The result is standard PBKDF2 and therefore interoperable:
the hash the WebUI computes with the browser's **WebCrypto** `deriveBits` is byte-identical to what
the server computes - verified against Python's `hashlib.pbkdf2_hmac` as a third, independent
implementation.

> **In short:** Android gives you no `crypt()`, and Dropbear's bundled PBKDF2 is compiled to nothing.
> Password auth here is a from-scratch PBKDF2-HMAC-SHA256 over libtomcrypt's HMAC, with the crypt()
> build guard removed. No OpenSSL/`libcrypto`, no obfuscation, no system shadow.

---

## static-PIE, bionic, and why you can't smoke-test with qemu-user

The release binary is **static-PIE**. Two things are worth knowing:

- A **static, non-PIE** build is rejected by bionic at exec time:
  `executable's TLS segment is underaligned … needs to be at least 64 for ARM64 Bionic`. Static-PIE
  is the correct form, and what `build.sh` produces.
- **`qemu-aarch64` (qemu-user) cannot run these binaries.** It segfaults on Android static-PIE
  executables (a known qemu-user limitation), and the static non-PIE variant is refused by bionic as
  above. So a host-side `qemu-user` smoke test is not meaningful - **run the binary on a real arm64
  Android device or a full system emulator** instead. The build itself (compile + link + correct ELF
  type) is validated in CI.

## openpty (planned `0004`)

Interactive PTY sessions use `openpty()`, which bionic provides but Dropbear's cross-`configure` does
not always detect. The planned `0004-android-openpty.patch` (or a `config.h` override in the build)
forces it on. Non-interactive use (exec, SFTP, rsync, port-forwarding) does not depend on it.

## Bundled tools: sftp-server, scp, rsync

`scripts/build-bundles.sh` cross-compiles the file-transfer tools as static-PIE
binaries into `module/bin/<abi>/`. CI runs it right after `build.sh`.

- **rsync** (with bundled popt + zlib) builds cleanly once you tell its configure
  that bionic has no `lutimes` (`ac_cv_func_lutimes=no`).
- **sftp-server** and **scp** come from **OpenSSH portable**, built
  `--without-openssl` (OpenSSH's built-in crypto is enough for these two), with a
  small static **zlib** this script builds first.

OpenSSH on Android is as finicky as the crypt() story above, because its
`configure` mis-detects several libc functions when cross-compiling. The script
encodes the fix; for the record, the pieces are:

1. **A cache seed of functions bionic lacks** but configure thinks it has, so the
   compat versions get compiled instead: `recallocarray`, `close_range`,
   `getentropy`, `getrandom`, `nl_langinfo`, `setpwent`/`getpwent`/`endpwent`,
   `crypt`, `futimes`, `lutimes`, `strtonum`, `pledge`, `explicit_bzero`.
2. **`-DHAVE_ATTRIBUTE__SENTINEL__=1 -DHAVE_ATTRIBUTE__NONNULL__=1`.** Without
   these, OpenSSH's `defines.h` does `#define __sentinel__` (empty) - which then
   mangles bionic's own `__attribute__((__sentinel__(1)))` in `<unistd.h>` and
   every compile fails with `expected ')'`.
3. **An `explicit_bzero` compat that uses `memset`.** bionic's `bzero` is a
   function-like macro (not a real symbol), so OpenSSH's default compat - which
   takes `&bzero` as a function pointer - does not compile. bionic has no
   `explicit_bzero` of its own.
4. **Dropping `xcrypt.o` and `getrrsetbyname.o`** from the compat library.
   `xcrypt.c` calls `getpwent()`/`crypt()` unconditionally (bionic has neither),
   and `getrrsetbyname.c` uses resolver internals bionic doesn't expose. Neither
   is used by `sftp-server` or `scp`.
5. **`-Wl,--allow-multiple-definition`.** `reallocarray` is the mirror image of
   the functions in (1): bionic doesn't *declare* it at API 24, so OpenSSH
   compiles its own compat - but the **symbol** does exist in `libc.a`, so the
   two collide at link time. Allowing the duplicate takes bionic's, which is fine.

Pinned versions live at the top of `scripts/build-bundles.sh`
(`ZLIB_VERSION`, `RSYNC_VERSION`, `OPENSSH_VERSION`).

## Reproducing a single ABI by hand

```sh
git clone --depth 1 --branch "$(cat UPSTREAM_VERSION)" https://github.com/mkj/dropbear /tmp/db
cp patches/localoptions.h /tmp/db/localoptions.h
for p in patches/*.patch; do patch -p1 -d /tmp/db < "$p"; done
cd /tmp/db
TC="$NDK/toolchains/llvm/prebuilt/linux-x86_64/bin"
./configure --host=aarch64-linux-android --disable-zlib --disable-syslog \
    CC="$TC/aarch64-linux-android24-clang"
make PROGRAMS="dropbear dropbearkey" STATIC=1 -j"$(nproc)"
file ./dropbear   # -> static-pie executable, ARM aarch64, for Android 24
```
