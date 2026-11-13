<!--
  ======================================================================
   VD Dropbear  ::  standalone, configurable rooted SSH daemon
   A private SSH server for KernelSU/APatch/Magisk - no invasive ADB exposure.
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

> **Languages:** [English](../../SECURITY.md) · [العربية](../ar/SECURITY.md) · [Čeština](../cs/SECURITY.md) · [Deutsch](../de/SECURITY.md) · [Español](../es/SECURITY.md) · [فارسی](../fa/SECURITY.md) · [Français](../fr/SECURITY.md) · [हिन्दी](../hi/SECURITY.md) · [Bahasa Indonesia](../in/SECURITY.md) · [Italiano](../it/SECURITY.md) · [日本語](../ja/SECURITY.md) · [한국어](../ko/SECURITY.md) · [Nederlands](../nl/SECURITY.md) · [Polski](../pl/SECURITY.md) · [Português](../pt/SECURITY.md) · [Русский](../ru/SECURITY.md) · [Svenska](../sv/SECURITY.md) · [ไทย](../th/SECURITY.md) · [Türkçe](../tr/SECURITY.md) · [Українська](../uk/SECURITY.md) · [Tiếng Việt](../vi/SECURITY.md) · 中文

---

# 安全策略

## 唯一需要理解的一点

VD Dropbear 会启动一个 SSH 服务器，而**每一个成功通过认证的连接都会获得一个 root shell**。因此，你设备的安全
等同于这台服务器的配置和凭据的安全。请：

- **优先使用公钥而非密码。** 密码登录默认关闭。
- 如果你必须使用密码，请使用一个强密码 - WebUI 会强制一个最低要求，并且只存储一个哈希。
- **不要把端口暴露到公共互联网。** 绑定到 loopback 或可信的 LAN，或者通过 VPN / 隧道访问它。
- 理解 **BFU 的权衡**：启用解锁前启动会把 host key 和凭据放到 device-encrypted 存储上，在设备解锁之前即可读取。
  除非你需要解锁前的 SSH，否则请保持其关闭。
- 除非需要，否则保持转发关闭（它默认关闭）。

## VD Dropbear 为帮助你所做的

- 一个中性、不透露信息的版本横幅，使网络扫描器无法指纹识别出确切的服务器和版本。
- 凭据默认存放在 credential-encrypted 存储上（只有在你解锁后才解密）。
- 没有遥测、没有自身的网络调用、没有分析统计。它完全在你的设备上运行。

## 受支持的版本

安全修复会落在最新的发布版上。服务器二进制文件跟踪 upstream Dropbear；upstream 的安全发布一经 CI 获取，就会被
重新构建并发布。

## 报告漏洞

请私下报告安全问题，而不是在公开 issue 中：

- **E-mail：** vd.priv8@pm.me
- **Telegram：** [@VD_Priv8](https://t.me/VD_Priv8)

请附上版本、描述，以及（最好有）复现方式。你会收到一份确认，我们会与你协调修复和披露的时间线。对于 Dropbear
本身的漏洞，也请向 upstream 报告：<https://matt.ucc.asn.au/dropbear/>。
