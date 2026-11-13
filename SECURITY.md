<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/Magisk - no invasive ADB exposure.
   Security policy.

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

# Security Policy

## The one thing to understand

VD Dropbear starts an SSH server, and **every connection that successfully authenticates receives a
root shell**. The security of your device therefore equals the security of this server's
configuration and credentials. Please:

- **Prefer public keys over passwords.** Password login is off by default.
- If you must use a password, use a strong one - the WebUI enforces a minimum and stores only a hash.
- **Do not expose the port to the public Internet.** Bind to loopback or a trusted LAN, or reach it
  over a VPN / tunnel.
- Understand the **BFU trade-off**: enabling start-before-unlock places the host key and credentials
  on device-encrypted storage, readable before the device is unlocked. Leave it off unless you need
  pre-unlock SSH.
- Keep forwarding off unless you need it (it is off by default).

## What VD Dropbear does to help

- A neutral, uninformative version banner so network scanners cannot fingerprint the exact server and
  version.
- Credentials on credential-encrypted storage by default (decrypted only after you unlock).
- No telemetry, no network calls of its own, no analytics. It runs entirely on your device.

## Supported versions

Security fixes land on the latest release. The server binary tracks upstream Dropbear; upstream
security releases are rebuilt and shipped as soon as the CI picks them up.

## Reporting a vulnerability

Please report security issues privately, not in a public issue:

- **E-mail:** vd.priv8@pm.me
- **Telegram:** [@VD_Priv8](https://t.me/VD_Priv8)

Include the version, a description, and (ideally) a reproduction. You will get an acknowledgement, and
we will coordinate a fix and disclosure timeline with you. For vulnerabilities in Dropbear itself,
please also report upstream at <https://matt.ucc.asn.au/dropbear/>.
