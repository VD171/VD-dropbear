# VD Dropbear

A **standalone, fully configurable Dropbear SSH server** packaged as a KernelSU / Magisk
module. It launches on its own and depends on no other module.

> ⚠️ **Every connection that authenticates receives a ROOT shell.** Treat this like the
> keys to the device. Prefer public keys over passwords, and keep the port off the public
> Internet.

## Why

Most people get an on-device SSH server by piggy-backing on a larger root-hiding module. That
couples the SSH daemon to that module's lifecycle: if its Zygisk component is disabled or fails,
the SSH daemon never starts - and you lose remote access for a reason that has nothing to do with
SSH. VD Dropbear is a single-purpose module so the daemon's uptime depends only on the daemon.

## Features

- **One daemon, always.** Start / restart from boot or the manager's **Action** button; never
  more than one instance.
- **Everything is configurable** (from the WebUI, or `/data/adb/vddropbear/config`):
  - port, and bind to loopback / all / IPv4 / IPv6 / specific addresses
  - public-key and/or password authentication, max auth tries
  - login user, shell, `HOME`, extra environment
  - idle timeout, keepalive, receive window
  - local / remote port forwarding and gateway ports (all **off** by default)
  - host-key type (ed25519 / rsa / ecdsa)
- **Hidden version banner.** The SSH protocol requires *a* banner, so it cannot be removed, but
  VD Dropbear replaces it with an uninformative one so scanners cannot fingerprint the exact
  server or version and target known-version attacks.
- **Secrets stored sensibly** (see below).
- **Bring your own credentials.** Add sets of `user + key` and `user + password`; the WebUI
  enforces a minimum password strength and never stores a password in clear text.

## Security model

### Where secrets live: BFU vs AFU

`/data/adb` is **device-encrypted (DE)** storage - it is decrypted *before* the user unlocks the
phone (Before First Unlock), so anything there is readable pre-unlock. `/data/misc_ce` is
**credential-encrypted (CE)** - Android keeps it encrypted until the user unlocks (After First
Unlock).

- **AFU mode (default, `START_IN_BFU=0`):** the daemon waits for unlock and reads its host key,
  `authorized_keys` and password hashes from CE storage. Maximum protection; SSH works only after
  the device has been unlocked once since boot.
- **BFU mode (`START_IN_BFU=1`):** the daemon starts before unlock so you can SSH in early (for
  example to unlock the device remotely). Its secrets then live on DE storage and are readable
  before unlock - a deliberate, documented trade-off. Enable it only if you need pre-unlock SSH.

We do **not** add our own encryption on top of CE. CE is already encrypted with the user's
credential; layering another cipher would need a key that has to live somewhere - on DE it would
be exposed, and deriving it from the user credential just re-implements CE. Extra encryption there
would be effort that buys a false sense of security, not real protection.

### Passwords

Password login is **off by default** - because every login is root, keys are strongly preferred.
When you do set a password, the WebUI enforces a minimum strength and stores only a hash.

## Install

Flash the module zip in the KernelSU or Magisk manager (or `ksud module install`), then open the
module's **WebUI** to set the port and add your keys, and reboot (or press **Action** to start it
immediately).

## Build

The server binary is built by CI from **upstream [mkj/dropbear](https://github.com/mkj/dropbear)**
with a small, auditable patch set (see [`patches/`](patches/)): a configurable/neutral identity
string, config-driven paths for `authorized_keys` and the password file, and the Android
`openpty` fix for interactive PTYs. A scheduled workflow tracks upstream and rebuilds so the
module stays current. See [`.github/workflows/`](.github/workflows/).

## Credits & license

SSH server: [Dropbear](https://matt.ucc.asn.au/dropbear/dropbear.html) by Matt Johnston, under its
own (MIT-style) license. The VD Dropbear module scripts, WebUI and patches are MIT licensed - see
[`LICENSE`](LICENSE).
