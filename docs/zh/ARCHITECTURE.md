<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk. No invasive ADB exposure.
   Architecture.

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

> **Languages:** [English](../ARCHITECTURE.md) · [العربية](../ar/ARCHITECTURE.md) · [Čeština](../cs/ARCHITECTURE.md) · [Deutsch](../de/ARCHITECTURE.md) · [Español](../es/ARCHITECTURE.md) · [فارسی](../fa/ARCHITECTURE.md) · [Français](../fr/ARCHITECTURE.md) · [हिन्दी](../hi/ARCHITECTURE.md) · [Bahasa Indonesia](../in/ARCHITECTURE.md) · [Italiano](../it/ARCHITECTURE.md) · [日本語](../ja/ARCHITECTURE.md) · [한국어](../ko/ARCHITECTURE.md) · [Nederlands](../nl/ARCHITECTURE.md) · [Polski](../pl/ARCHITECTURE.md) · [Português](../pt/ARCHITECTURE.md) · [Русский](../ru/ARCHITECTURE.md) · [Svenska](../sv/ARCHITECTURE.md) · [ไทย](../th/ARCHITECTURE.md) · [Türkçe](../tr/ARCHITECTURE.md) · [Українська](../uk/ARCHITECTURE.md) · [Tiếng Việt](../vi/ARCHITECTURE.md) · 中文

---

# 架构

VD Dropbear 是一个 KernelSU / APatch / Magisk 模块，仅运行一个 Dropbear SSH 守护进程，完全由配置驱动。SSH 服务器
的任何部分都不会硬编码到某一台设备；一切特定的内容都是运行时配置或某个 secret。

## 组成部分

- `module/common/vddropbear.sh`：核心库：加载配置（带安全的内置默认值）、解析 secret 存储、确保存在 host key、
  构建 Dropbear 参数向量，以及管理单个守护进程实例（start / stop / status / restart）。
- `module/service.sh`：启动入口。遵循 BFU/AFU 启动策略；在 AFU 模式下，它等待 credential-encrypted 存储解锁，
  而不会拖慢启动。
- `module/action.sh`：管理器的 **Action** 按钮：（重新）启动守护进程。它从不读取 stdin，并将守护进程分离到自己
  的会话中，因此管理器不会卡住。
- `module/common/vddb-webui.sh` + `module/webroot/index.html`：WebUI 的后端和页面。
- `patches/`：在构建时应用到 upstream Dropbear 上的小而可审计的补丁。
- `scripts/build.sh`、`scripts/build-bundles.sh`、`.github/workflows/build.yml`：构建。

## 守护进程生命周期（单实例）

`vddb_start` 加载配置、停止任何正在运行的实例、确保 host key 存在，然后生成一个守护进程。二进制文件以
`vddropbear` 名称发布，因此其进程名与 `pgrep -x` 完全匹配（Android `mksh` 没有 `exec -a`）。它以 `setsid`
启动，从而脱离调用者的进程组：这正是让管理器的 Action 不被阻塞的原因。

## secret 存储（CE 与 DE，BFU 与 AFU）

设置并非 secret，存放在 device-encrypted 存储（`/data/adb/vddropbear`）中，启动时即可读取。secret（host key、
`authorized_keys`、密码哈希）默认存放在 **credential-encrypted** 存储（`/data/misc_ce/0/vddropbear`）中，只有在
用户完成认证后才会解锁。开启 `START_IN_BFU` 会把这些 secret 移到 device-encrypted 存储，使守护进程能在首次解锁
之前运行，代价是这些 secret 会更早可读。模块会在每个启动阶段计算应使用哪个存储。

## 补丁集

SSH 服务器仍为 upstream Dropbear；我们的改动只是几个可供审阅的补丁（见
[patches/README.md](../../patches/README.md)）：

- 一个中性的、可在运行时配置的身份横幅；
- `authorized_keys` 从由环境设定的路径读取（因此密钥存放在 secret 存储中）；
- 密码认证针对一个 PBKDF2 哈希文件进行，而非系统的 `crypt()`/shadow，后者 Android 并不具备（见
  [BUILDING.md](../BUILDING.md)）。

## WebUI

管理器 WebUI（KernelSU / APatch / WebUI-X）中的一个静态页面。它通过 `ksu.exec` 桥驱动
`module/common/vddb-webui.sh`：状态、start/stop/restart、配置读写，以及对密钥和密码账户的管理。所有数据都以
base64 编码跨桥传递，因此 shell 从不对其进行解释；密码哈希在浏览器中用 WebCrypto 计算，因此明文密码从不离开
页面。
