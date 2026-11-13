<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk - no invasive ADB exposure.
   AI agents on your device.

   Copyright (C) 2026  VD171
   SPDX-License-Identifier: Apache-2.0

   Licensed under the Apache License, Version 2.0; you may obtain a copy at
   http://www.apache.org/licenses/LICENSE-2.0

   Site           : https://vd171.ru
   Site           : https://vd.priv8.ru
   Source         : https://github.com/VD171/VD-dropbear
   GitHub         : @VD171 https://github.com/VD171
   XDA-Developers : @VD171 https://xdaforums.com/m/vd171.4699873/
   XDA thread     : https://xdaforums.com/t/VD-Dropbear.4808524/
   Telegram       : @VD_Priv8 https://t.me/VD_Priv8
   Channel        : @Priv8_VD https://t.me/Priv8_VD
   Discord        : @VD.Priv8 https://discord.com/users/1296831918989639721
   E-mail         : vd.priv8@pm.me
  ======================================================================
-->

> **Languages:** English · [العربية](ar/AI-AGENTS.md) · [Čeština](cs/AI-AGENTS.md) · [Deutsch](de/AI-AGENTS.md) · [Español](es/AI-AGENTS.md) · [فارسی](fa/AI-AGENTS.md) · [Français](fr/AI-AGENTS.md) · [हिन्दी](hi/AI-AGENTS.md) · [Bahasa Indonesia](in/AI-AGENTS.md) · [Italiano](it/AI-AGENTS.md) · [日本語](ja/AI-AGENTS.md) · [한국어](ko/AI-AGENTS.md) · [Nederlands](nl/AI-AGENTS.md) · [Polski](pl/AI-AGENTS.md) · [Português](pt/AI-AGENTS.md) · [Русский](ru/AI-AGENTS.md) · [Svenska](sv/AI-AGENTS.md) · [ไทย](th/AI-AGENTS.md) · [Türkçe](tr/AI-AGENTS.md) · [Українська](uk/AI-AGENTS.md) · [Tiếng Việt](vi/AI-AGENTS.md) · [中文](zh/AI-AGENTS.md)

---

# AI agents on your device

A standing SSH endpoint turns your phone into something an **autonomous AI agent can operate
directly**. Any agent that can drive a shell or an SSH connection - Claude Code, aider, an
LLM-in-the-loop script, your own automation - gets a real root session on the device, over the
network, with no USB tether and none of ADB's self-exposing debug flags.

This page expands on the idea introduced in the README.

## Why SSH, not ADB, for agents

ADB announces itself: `adb_enabled` and `development_settings_enabled` are world-readable, the
connection is logged, and there is no supported way to hide that debugging is (or was) on. An agent
working over ADB leaves that trail on the device for any app or anti-fraud SDK to read. VD Dropbear is
the private alternative - a normal SSH login, with credentials you control and a banner that reveals
nothing.

## What an agent can do

Over one connection, an agent sees a normal Linux-like shell and can:

- read and edit files, flip settings, and manage modules, packages and services;
- triage logs, pull artifacts, and run diagnostics or forensics on demand;
- move and sync files both ways over `scp` / `sftp` / `rsync` - backups, migrations, provisioning;
- drive a whole fleet of rooted devices from one place, each reachable by its own key.

Because the project is built to be **AI-friendly** - a documented configuration file, an explicit
runtime [env contract](../patches/README.md), predictable paths and plain-text status - an agent can
discover how to use it without guesswork.

## Doing it safely

This is root, so treat it like root:

- give the agent a **dedicated user and key**, not your personal one;
- scope the binds to networks you trust - loopback or a VPN rather than the open Internet
  (see [Configuration](CONFIGURATION.md));
- keep password auth off; a key is revocable and never typed;
- you can revoke a key or stop the daemon at any time from the WebUI;
- remember every connection is a full root session - give the agent only the reach it needs.

## A minimal setup

1. Generate a key pair just for the agent.
2. Add its public key in the WebUI (**Authorized keys**).
3. Bind to loopback or your VPN only, on a non-default port.
4. Point the agent's SSH config at the device and let it work.
