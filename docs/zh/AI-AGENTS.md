<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk. No invasive ADB exposure.
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

> **Languages:** [English](../AI-AGENTS.md) · [العربية](../ar/AI-AGENTS.md) · [Čeština](../cs/AI-AGENTS.md) · [Deutsch](../de/AI-AGENTS.md) · [Español](../es/AI-AGENTS.md) · [فارسی](../fa/AI-AGENTS.md) · [Français](../fr/AI-AGENTS.md) · [हिन्दी](../hi/AI-AGENTS.md) · [Bahasa Indonesia](../in/AI-AGENTS.md) · [Italiano](../it/AI-AGENTS.md) · [日本語](../ja/AI-AGENTS.md) · [한국어](../ko/AI-AGENTS.md) · [Nederlands](../nl/AI-AGENTS.md) · [Polski](../pl/AI-AGENTS.md) · [Português](../pt/AI-AGENTS.md) · [Русский](../ru/AI-AGENTS.md) · [Svenska](../sv/AI-AGENTS.md) · [ไทย](../th/AI-AGENTS.md) · [Türkçe](../tr/AI-AGENTS.md) · [Українська](../uk/AI-AGENTS.md) · [Tiếng Việt](../vi/AI-AGENTS.md) · 中文

---

# 设备上的 AI 代理

一个常驻的 SSH 端点会把你的手机变成**自主 AI 代理可以直接操作**的对象。任何能够驱动 shell 或 SSH 连接的代理
（Claude Code、aider、带有 LLM 回路的脚本、你自己的自动化）都能通过网络获得设备上真正的 root 会话，无需 USB
连线，也没有 ADB 那种自我暴露的调试标志。

本页对 README 中引入的想法作了进一步展开。

## 为什么给代理用 SSH 而不是 ADB

ADB 会暴露自身：`adb_enabled` 和 `development_settings_enabled` 任何人都可读，连接会被记录，而且没有受支持的办法
隐藏调试已经（或曾经）开启这一事实。通过 ADB 工作的代理会在设备上留下这一痕迹，任何应用或反欺诈 SDK 都能读取。
VD Dropbear 是私密的替代方案：一次普通的 SSH 登录，凭据由你掌控，横幅不透露任何信息。

## 代理能做什么

通过一个连接，代理看到一个普通的类 Linux shell，并且可以：

- 读取和编辑文件、切换设置，以及管理模块、软件包和服务；
- 分类日志、拉取构件，并按需运行诊断或取证；
- 通过 `scp` / `sftp` / `rsync` 双向移动和同步文件：备份、迁移、置备；
- 从一个地方驱动整支 root 设备机群，每台都可用各自的密钥访问。

由于本项目被构建为**对 AI 友好**的（带文档的配置文件、明确的运行时
[env 契约](../../patches/README.md)、可预测的路径以及纯文本状态）代理无需猜测即可发现如何使用它。

## 安全地进行

这是 root，所以要把它当作 root 对待：

- 给代理一个**专用的用户和密钥**，而不是你个人的那套；
- 把绑定范围限定在你信任的网络：loopback 或 VPN，而非开放的互联网
  （见[配置](CONFIGURATION.md)）；
- 保持密码认证关闭；密钥可撤销且从不需要键入；
- 你可以随时从 WebUI 撤销密钥或停止守护进程；
- 记住每个连接都是一次完整的 root 会话：只给代理它所需的触及范围。

## 一套最小配置

1. 专门为代理生成一对密钥。
2. 在 WebUI（**Authorized keys**）中添加它的公钥。
3. 仅绑定到 loopback 或你的 VPN，使用非默认端口。
4. 把代理的 SSH 配置指向该设备，让它去工作。
